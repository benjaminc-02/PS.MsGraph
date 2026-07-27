function Add-MsGServicePrincipalAPIPermission {
    <#
    .SYNOPSIS
    Adds specified API permission to service principal.
    .DESCRIPTION
    This function adds specified API permissions to an service principal. Both application and delegated permissions can be assigned for any resource application.
    .PARAMETER DisplayName
    Display Name of the service principal.
    .PARAMETER AppId
    App/Client Id of the service principal.
    .PARAMETER ObjectId
    Object Id of the service principal.
    .PARAMETER Permission
    List of permissions to add to the service principal.
    .PARAMETER Type
    Type of permissions to add to the service principal.
    .PARAMETER ResourceAppId
    App/Client Id of the resource application that the permissions are assigned from.
    .PARAMETER Force
    Forces the addition without any prompts.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Add-MsGServicePrincipalAPIPermission -DisplayName TestApp-01 -Permission User.Read.All -Type Application -AdminConsent -Force

    This adds the User.Read.All Application API Permission for Microsoft Graph to the TestApp-01 service principal, allowing it to read user data in the tenant.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
        [parameter(Mandatory = $true, Position = 3)][string[]]$Permission,
        [parameter(Mandatory = $false, Position = 4)][ValidateSet('Application', 'Delegated')][string]$Type = 'Application',
        [parameter(Mandatory = $false)][string]$ResourceAppId = '00000003-0000-0000-c000-000000000000',
        [parameter(Mandatory = $false)][switch]$Force,
        [parameter(Mandatory = $false)][hashtable]$Headers,
        [parameter(Mandatory = $false)][string]$Jwt
    )
    BEGIN {
        # Session Checks
        if ([string]::IsNullOrEmpty($Headers) -and [string]::IsNullOrEmpty($Jwt)) {
            if ($null -ne $myGraphToken) {
                Write-Verbose "Setting Jwt to Global: $myGraphToken"
                $Jwt = $myGraphToken
            }
        }
        if ([string]::IsNullOrEmpty($Headers) -and -not([string]::IsNullOrEmpty($Jwt))) {
            $Headers = @{
                'Authorization' = 'Bearer {0}' -f $Jwt
                'Content-Type'  = 'application/json'
            }
        }
        if ([string]::IsNullOrEmpty($Headers)) {
            $errorMessage = '{0} : Unable to run command. Headers are empty.' -f $MyInvocation.MyCommand.Name
            throw $errorMessage
        }
        # end Session Checks

        # Retrieve Resource Permissions
        try {
            $resourceApp = Get-MsGServicePrincipal -AppId $ResourceAppId -Headers $Headers -ErrorAction 'Stop'
            $applicationPermissionTable = $resourceApp | Select-Object -ExpandProperty 'appRoles' | Group-Object 'value' -AsHashTable -AsString
            $delegatedPermissionTable = $resourceApp | Select-Object -ExpandProperty 'oauth2PermissionScopes' | Group-Object 'value' -AsHashTable -AsString
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve resource tables. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region
    }
    PROCESS {
        # Retrieve Application from Entra ID
        try {
            switch ($PSCmdlet.ParameterSetName) {
                "Name" {
                    $spEndpoint = "servicePrincipals?`$filter=displayName eq '{0}'" -f $DisplayName
                }
                "AppId" {
                    $spEndpoint = "servicePrincipals?`$filter=appId eq '{0}'" -f $AppId
                }
                "ObjId" {
                    $spEndpoint = "servicePrincipals/{0}" -f $ObjectId
                }
            }
            $servicePrincipal = Invoke-MsGRequest -Method Get -Endpoint $spEndpoint -Headers $Headers -ErrorAction 'Stop'
            if ([string]::IsNullOrEmpty($servicePrincipal)) {
                $errorMessage = 'Service Principal not found.'
                throw $errorMessage
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve service principal from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        $appRoleAssignToEndpoint = 'servicePrincipals/{0}/appRoleAssignedTo' -f $servicePrincipal.id
        # end region

        # Apply API Permissions
        switch ($Type) {
            "Application" {
                # Iterate through application permissions.
                foreach ($SpecifiedPermission in $Permission) {
                    $permissionId = $null
                    $permissionBody = $null

                    # Retrieve and validate permission id.
                    $permissionId = $applicationPermissionTable[$SpecifiedPermission].Id
                    if ([string]::IsNullOrEmpty($permissionId)) {
                        $warningMessage = 'Unable to retrieve the id for the {0} permission. This will not be added to the application.' -f $SpecifiedPermission
                        Write-Warning $warningMessage
                        continue
                    }
                    $permissionBody = @{
                        'principalId' = $servicePrincipal.id
                        'resourceId'  = $resourceApp.id
                        'appRoleId'   = $permissionId
                    }

                    # Assign permission to service principal if it exists.
                    if ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Add the '$SpecifiedPermission' Application permission to '$($servicePrincipal.displayName)'.", "Are you sure you would like to proceed with the following?"))) {
                        try {
                            Invoke-MsGRequest -Method Post -Endpoint $appRoleAssignToEndpoint -Body $permissionBody -Headers $Headers -ErrorAction 'Stop'
                        }
                        catch {
                            $errorMessage = Get-MsGErrorMessage $_
                            $warningMessage = 'Unable to assign permission {0} to {1}. Error: {2}' -f $SpecifiedPermission, $servicePrincipal.displayName, $errorMessage
                            Write-Warning $warningMessage
                            continue
                        }
                    }
                }
            }
            "Delegated" {
                # Validate Permission Set
                $validPermissions = New-Object -TypeName System.Collections.Generic.List[string]
                foreach ($SpecifiedPermission in $Permission) {
                    $permissionObj = $null
                    $permissionObj = $delegatedPermissionTable[$SpecifiedPermission]
                    if (-not([string]::IsNullOrEmpty($permissionObj.value))) {
                        $validPermissions.Add($permissionObj.value)
                    }
                }

                # Retrieve current oauth2 permissions for service principal.
                try {
                    $oauth2PermissionsEndpoint = "oauth2PermissionGrants?`$filter=consentType eq 'AllPrincipals' AND resourceId eq '{0}' AND clientId eq '{1}'" -f $resourceApp.id, $servicePrincipal.id
                    $oauth2PermissionGrants = Invoke-MsGRequest -Method Get -Endpoint $oauth2PermissionsEndpoint -Headers $Headers
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = '{0} : Unable to validate delegated permissions for service principal from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                    throw $errorException
                }

                # If none exist, create net new. Otherwise add on to existing permissions
                if ([string]::IsNullOrEmpty($oauth2PermissionGrants)) {
                    # Create new oauth2 permission grants.
                    $scopeString = ($validPermissions | Sort-Object | Select-Object -Unique) -join ' '
                    $oauth2PermissionBody = @{
                        'clientId'    = $servicePrincipal.id
                        'consentType' = 'AllPrincipals'
                        'resourceId'  = $resourceApp.id
                        'scope'       = $scopeString
                    }
                    $endpoint = 'oauth2PermissionGrants'
                    if ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Consent to the following delegated permissions to the '$($servicePrincipal.displayName)' service principal: $scopeString.", "Are you sure you would like to proceed with the following?"))) {
                        try {
                            Invoke-MsGRequest -Method Post -Endpoint $endpoint -Body $oauth2PermissionBody -Headers $Headers -ErrorAction 'Stop'
                        }
                        catch {
                            $errorMessage = Get-MsGErrorMessage $_
                            $errorException = '{0} : Unable to add delegated permissions for service principal from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                            throw $errorException
                        }
                    }
                }
                else {
                    # All Principals permission exists for resource. Adding on to existing scope.
                    $oauth2PermissionGrants.scope.Trim().Split(' ') | ForEach-Object { $validPermissions.Add($_) }
                    $scopeString = ($validPermissions | Sort-Object | Select-Object -Unique) -join ' '

                    # Update existing oauth2 permission grants.
                    if ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Update the scopes for '$($servicePrincipal.displayName)' from '$($oauth2PermissionGrants.scope.Trim())' to '$scopeString'.", "Are you sure you would like to proceed with the following?"))) {
                        try {
                            $endpoint = 'oauth2PermissionGrants/{0}' -f $oauth2PermissionGrants.id
                            $body = @{'scope' = $scopeString }
                            Invoke-MsGRequest -Method Patch -Endpoint $endpoint -Body $body -Headers $Headers -ErrorAction 'Stop'
                        }
                        catch {
                            $errorMessage = Get-MsGErrorMessage $_
                            $errorException = '{0} : Unable to update delegated permissions for service principal from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                            throw $errorException
                        }
                    }
                }
            }
        }
        # end region
    }
}