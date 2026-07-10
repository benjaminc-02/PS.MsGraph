function Add-MsGApplicationAPIPermission {
    <#
    .SYNOPSIS
    Adds specified API permission to application.
    .DESCRIPTION
    This function adds specified API permissions to an app registration. Both application and delegated permissions can be assigned for any resource application.
    .PARAMETER DisplayName
    Display Name of the app registration.
    .PARAMETER AppId
    App/Client Id of the app registration.
    .PARAMETER ObjectId
    Object Id of the app registration.
    .PARAMETER Permission
    List of permissions to add to the app registration.
    .PARAMETER Type
    Type of permissions to add to the app registration.
    .PARAMETER AdminConsent
    Specifies whether admin consent is provided to the permissions.
    .PARAMETER ResourceAppId
    App/Client Id of the resource application that the permissions are assigned from.
    .PARAMETER Force
    Forces the addition without any prompts.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Add-MsGApplicationAPIPermission -DisplayName TestApp-01 -Permission User.Read.All -Type Application -AdminConsent -Force

    This adds the User.Read.All Application API Permission for Microsoft Graph to the TestApp-01 app registration, allowing it to read user data in the tenant.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
        [parameter(Mandatory = $true, Position = 3)][string[]]$Permission,
        [parameter(Mandatory = $false, Position = 4)][ValidateSet('Application', 'Delegated')][string]$Type = 'Application',
        [parameter(Mandatory = $false, Position = 5)][switch]$AdminConsent,
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
                    $appEndpoint = "applications?`$filter=displayName eq '{0}'" -f $DisplayName
                }
                "AppId" {
                    $appEndpoint = "applications?`$filter=appId eq '{0}'" -f $AppId
                }
                "ObjId" {
                    $appEndpoint = "applications/{0}" -f $ObjectId
                }
            }
            $application = Invoke-MsGRequest -Method Get -Endpoint $appEndpoint -Headers $Headers -ErrorAction 'Stop'
            if ([string]::IsNullOrEmpty($application)) {
                $errorMessage = 'Application not found.'
                throw $errorMessage
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve application from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Retrieve resource access.
        $appRequiredResourceAccess = $application.requiredResourceAccess
        $updatedRequiredResourceAccess = New-Object -TypeName System.Collections.Generic.List[psobject]

        # If the app already has resources tied to it, make updates.
        if (-not([string]::IsNullOrEmpty($appRequiredResourceAccess))) {
            foreach ($requiredResourceAccess in $appRequiredResourceAccess) {
                if ($requiredResourceAccess.resourceAppId -eq $resourceApp.appId) {
                    # Specific resource is to be added. Iterate through permissions.
                    $ResourceAccess = $requiredResourceAccess.resourceAccess
                    foreach ($SpecifiedPermission in $Permission) {
                        $PermissionId = $null
                        $PermissionType = $null
                        $NewResourceAccess = $null

                        # Retrieve Properties
                        switch ($Type) {
                            "Application" {
                                $PermissionId = $applicationPermissionTable[$SpecifiedPermission].Id
                                $PermissionType = 'Role'
                            }
                            "Delegated" {
                                $PermissionId = $delegatedPermissionTable[$SpecifiedPermission].Id
                                $PermissionType = 'Scope'
                            }
                        }

                        # Check Permission Id
                        if ([string]::IsNullOrEmpty($PermissionId)) {
                            $warningMessage = 'Unable to retrieve the id for the {0} permission. This will not be added to the application.' -f $SpecifiedPermission
                            Write-Warning $warningMessage
                            continue
                        }

                        # Add new permission to resource access object
                        $NewResourceAccess = [pscustomobject]@{
                            'id'   = $PermissionId
                            'type' = $PermissionType
                        }
                        $ResourceAccess += $NewResourceAccess
                    }
                    # Add to required resource access. Group resourceAccess to remove duplicates.
                    $newRequiredResourceAccess = [PSCustomObject]@{
                        'resourceAppId'  = $requiredResourceAccess.resourceAppId
                        'resourceAccess' = $ResourceAccess | Group-Object Id, Type | ForEach-Object { $_.Group[0] }
                    }
                    $updatedRequiredResourceAccess.Add($newRequiredResourceAccess)
                }
                else {
                    # Specific resource is not being changed. Adding to update body and continuing forward.
                    $updatedRequiredResourceAccess.Add($requiredResourceAccess)
                }
            }
        }
        else {
            # Otherwise will need to add the new required resources manually.
            $ResourceAccess = New-Object -TypeName System.Collections.Generic.List[psobject]
            foreach ($SpecifiedPermission in $Permission) {
                $PermissionId = $null
                $PermissionType = $null
                $NewResourceAccess = $null

                # Retrieve Properties
                switch ($Type) {
                    "Application" {
                        $PermissionId = $applicationPermissionTable[$SpecifiedPermission].Id
                        $PermissionType = 'Role'
                    }
                    "Delegated" {
                        $PermissionId = $delegatedPermissionTable[$SpecifiedPermission].Id
                        $PermissionType = 'Scope'
                    }
                }

                # Check Permission Id
                if ([string]::IsNullOrEmpty($PermissionId)) {
                    $warningMessage = 'Unable to retrieve the id for the {0} permission. This will not be added to the application.' -f $SpecifiedPermission
                    Write-Warning $warningMessage
                    continue
                }

                # Add new permission to resource access object
                $NewResourceAccess = [pscustomobject]@{
                    'id'   = $PermissionId
                    'type' = $PermissionType
                }
                $ResourceAccess.Add($NewResourceAccess)
            }

            $newRequiredResourceAccess = [PSCustomObject]@{
                'resourceAppId'  = $resourceApp.appId
                'resourceAccess' = [psobject[]]($ResourceAccess | Group-Object Id, Type | ForEach-Object { $_.Group[0] })
            }
            $updatedRequiredResourceAccess.Add($newRequiredResourceAccess)
        }
        # end region

        # Upload new resource access.
        try {
            $endpoint = 'applications/{0}' -f $application.id
            $body = @{
                'requiredResourceAccess' = $updatedRequiredResourceAccess
            }
            Invoke-MsGRequest -Method Patch -Endpoint $endpoint -Body $body -Headers $Headers -ErrorAction 'Stop' > $null
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to add the {1} API permissions for the following to the application in Entra ID: {2}. Error: {3}' -f $MyInvocation.MyCommand.Name, $Type, ($Permission -join ', '), $errorMessage
            throw $errorException
        }
        # end region

        # Admin Consent Actions
        if ($AdminConsent) {
            # Retrieve Service Principal
            try {
                $servicePrincipal = Get-MsGServicePrincipal -AppId $application.appId -Headers $Headers -ErrorAction 'Stop'
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to retrieve service principal from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
            # end region

            # Apply admin consent
            if ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Provide admin consent to the following permissions on the '$($servicePrincipal.displayName)' app: $($Permission -join ', ').", "Are you sure you would like to proceed with the following?"))) {
                try {
                    Add-MsGServicePrincipalAPIPermission -ObjectId $servicePrincipal.id -Permission $Permission -Type $Type -ResourceAppId $resourceApp.appId -Force -Headers $Headers -ErrorAction 'Stop'
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = '{0} : Unable to consent to permissions in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                    throw $errorException
                }
            }
            # end region
        }
        # end region
    }
}