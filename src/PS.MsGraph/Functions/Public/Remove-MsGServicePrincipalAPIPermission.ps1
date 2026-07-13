function Remove-MsGServicePrincipalAPIPermission {
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

        $irmParams = @{
            'Headers'     = $Headers
            'ErrorAction' = 'Stop'
        }
        # end Session Checks
    }
    PROCESS {
        # Retrieve Service Principal from Entra ID
        try {
            switch ($PSCmdlet.ParameterSetName) {
                "Name" {
                    $appEndpoint = "servicePrincipals?`$filter=displayName eq '{0}'" -f $DisplayName
                }
                "AppId" {
                    $appEndpoint = "servicePrincipals?`$filter=appId eq '{0}'" -f $AppId
                }
                "ObjId" {
                    $appEndpoint = "servicePrincipals/{0}" -f $ObjectId
                }
            }
            $servicePrincipal = Invoke-MsGRequest -Method Get -Endpoint $appEndpoint @irmParams
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
        # end region

        # Retrieve existing permissions.
        try {
            $servicePrincipalPermissions = Get-MsGServicePrincipalAPIPermission -ObjectId $servicePrincipal.id @irmParams
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve service principal permissions from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Remove Permission if it exists
        switch ($Type) {
            "Application" {
                foreach ($SpecifiedPermission in $Permission) {
                    $permissionInfo = $null
                    $permissionEndpoint = $null

                    $permissionInfo = $servicePrincipalPermissions | Where-Object { $_.Name -eq $SpecifiedPermission -and $_.ResourceAppId -eq $ResourceAppId -and $_.Type -eq $Type }
                    if ([string]::IsNullOrEmpty($permissionInfo)) {
                        $warningMessage = "{0} permission '{1}' of the '{2}' resource app is not present on this service principal. Nothing to remove." -f $Type, $SpecifiedPermission, $ResourceAppId
                        Write-Warning $warningMessage
                        continue
                    }

                    if (($PSCmdlet.ShouldProcess($SpecifiedPermission, 'Remove Service Principal API Permission')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove [$ResourceAppId] '$SpecifiedPermission' $Type-Level permission from '$($servicePrincipal.displayName)'.", 'Are you sure you would like to proceed?')))) {
                        try {
                            $permissionEndpoint = 'servicePrincipals/{0}/appRoleAssignments/{1}' -f $servicePrincipal.id, $permissionInfo.id
                            Invoke-MsGRequest -Method Delete -Endpoint $permissionEndpoint @irmParams
                        }
                        catch {
                            $errorMessage = Get-MsGErrorMessage $_
                            $errorException = 'Unable to remove {0} permission from the service principal. Error: {1}' -f $SpecifiedPermission, $errorMessage
                            Write-Error $errorException
                            continue
                        }
                    }
                }
            }
            "Delegated" {
                # Retrieve permission id.
                $oauth2PermissionId = $servicePrincipalPermissions | Where-Object { $_.Type -eq 'Delegated' -and $_.ResourceAppId -eq $ResourceAppId } | Select-Object -ExpandProperty Id -Unique
                if (-not([string]::IsNullOrEmpty($oauth2PermissionId))) {
                    try {
                        # Retrieve delegated permission grants.
                        $oauth2PermissionEndpoint = 'oauth2PermissionGrants/{0}' -f $oauth2PermissionId
                        $oauth2PermissionGrants = Invoke-MsGRequest -Method Get -Endpoint $oauth2PermissionEndpoint @irmParams
                        $existingScopeList = $oauth2PermissionGrants.scope.Trim().Split(' ')

                        # Retrieve updated scope list.
                        $permissionScopeList = New-Object -TypeName System.Collections.Generic.List[string]
                        foreach ($existingPermission in $existingScopeList) {
                            if ($existingPermission -notin $Permission) {
                                $permissionScopeList.Add($existingPermission)
                            }
                        }

                        # Update permission list if permissions still remain. Otherwise delete the delegation grants.
                        if (($PSCmdlet.ShouldProcess(($Permission -join ' '), 'Remove Service Principal API Permission')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove [$ResourceAppId] '$($Permission -join ' ')' $Type-Level permission from '$($servicePrincipal.displayName)'.", 'Are you sure you would like to proceed?')))) {
                            if ($permissionScopeList.Count -gt 0) {
                                $scopeString = $permissionScopeList -join ' '
                                $permissionUpdateBody = @{'scope' = $scopeString }
                                Invoke-MsGRequest -Method Patch -Endpoint $oauth2PermissionEndpoint -Body $permissionUpdateBody @irmParams
                            }
                            else {
                                Invoke-MsGRequest -Method Delete -Endpoint $oauth2PermissionEndpoint @irmParams

                            }
                        }
                    }
                    catch {
                        $errorMessage = Get-MsGErrorMessage $_
                        $warningMessage = 'Failed to update delegated permissions. Error: {0}' -f $errorMessage
                        Write-Warning $warningMessage
                    }
                }
            }
        }
        # end region
    }
}