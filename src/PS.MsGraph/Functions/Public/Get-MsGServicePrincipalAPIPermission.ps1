function Get-MsGServicePrincipalAPIPermission {
    <#
    .SYNOPSIS
    Retrieves API permissions of service principals.
    .DESCRIPTION
    This function retrieves the API permissions of a specified service principal.
    .PARAMETER DisplayName
    DisplayName of the service principal.
    .PARAMETER AppId
    AppId of the service principal.
    .PARAMETER ObjectId
    ObjectId of the service principal.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
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

        # Permissions
        $resourceAppsTable = @{}
        # end region
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
            $servicePrincipal = Invoke-MsGRequest -Method Get -Endpoint $appEndpoint -Headers $Headers -ErrorAction 'Stop'
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

        # Retrieve API permissions
        $apiPermissions = New-Object -TypeName System.Collections.Generic.List[PS_MsGraph_Application_APIPermission]

        # Delegated
        $delegatedPermissionsEndpoint = "servicePrincipals/{0}/oauth2PermissionGrants" -f $servicePrincipal.id
        $delegatedPermissions = Invoke-MsGRequest -Method Get -Endpoint $delegatedPermissionsEndpoint -Headers $Headers -ErrorAction 'Stop' | Where-Object { $_.consentType -eq 'AllPrincipals' }
        foreach ($delegatedPermission in $delegatedPermissions) {
            $resourceId = $null
            $resourceApp = $null
            $resourceScopeTable = $null
            $permissionList = $null

            $resourceId = $delegatedPermission.resourceId
            $resourceApp = $resourceAppsTable[$resourceId]
            if ([string]::IsNullOrEmpty($resourceApp)) {
                $resourceApp = Get-MsGServicePrincipal -ObjectId $resourceId -Headers $Headers -ErrorAction 'Stop'
                $resourceAppsTable.Add($resourceApp.id, $resourceApp)
            }
            $resourceScopeTable = $resourceApp.oauth2PermissionScopes | Group-Object value -AsHashTable -AsString

            $permissionList = $delegatedPermission.scope.Trim().Split(' ')
            foreach ($permissionName in $permissionList) {
                $permissionInfo = $null
                $permissionInfo = $resourceScopeTable[$permissionName]

                try {
                    $customPermission = New-Object -TypeName 'PS_MsGraph_Application_APIPermission' -ArgumentList ($permissionInfo.id, $permissionInfo.adminConsentDescription, $delegatedPermission.id, $permissionInfo.value, $resourceApp.appId, $resourceApp.displayName, 'Delegated')
                    $apiPermissions.Add($customPermission)
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = 'Failed to add custom permission to output for {0}. Error: {1}' -f $permissionInfo.value, $errorMessage
                    Write-Error $errorException
                    continue
                }
            }
        }

        # Application
        $applicationPermissionsEndpoint = "servicePrincipals/{0}/appRoleAssignments" -f $servicePrincipal.id
        $applicationPermissions = Invoke-MsGRequest -Method Get -Endpoint $applicationPermissionsEndpoint -Headers $Headers -ErrorAction 'Stop'
        $applicationRsApps = $applicationPermissions | Group-Object resourceId
        foreach ($applicationRsApp in $applicationRsApps) {
            $resourceId = $null
            $resourceApp = $null
            $resourceRoleTable = $null

            $resourceId = $applicationRsApp.Name
            $resourceApp = $resourceAppsTable[$resourceId]
            if ([string]::IsNullOrEmpty($resourceApp)) {
                $resourceApp = Get-MsGServicePrincipal -ObjectId $resourceId -Headers $Headers -ErrorAction 'Stop'
                $resourceAppsTable.Add($resourceApp.id, $resourceApp)
            }
            $resourceRoleTable = $resourceApp.appRoles | Group-Object id -AsHashTable -AsString

            foreach ($permission in $applicationRsApp.Group) {
                $permissionId = $permission.appRoleId
                $permissionInfo = $null
                $permissionInfo = $resourceRoleTable[$permissionId]

                try {
                    $customPermission = New-Object -TypeName 'PS_MsGraph_Application_APIPermission' -ArgumentList ($permissionInfo.id, $permissionInfo.description, $permission.id, $permissionInfo.value, $resourceApp.appId, $resourceApp.displayName, 'Application')
                    $apiPermissions.Add($customPermission)
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = 'Failed to add custom permission to output for {0}. Error: {1}' -f $permissionInfo.value, $errorMessage
                    Write-Error $errorException
                    continue
                }
            }
        }
        # end region

        Write-Output $apiPermissions
    }
}