function Get-MsGApplicationAPIPermission {
    <#
    .SYNOPSIS
    Retrieves API permissions of app registrations.
    .DESCRIPTION
    This function retrieves the API permissions of a specified app registration.
    .PARAMETER DisplayName
    DisplayName of the app registration.
    .PARAMETER AppId
    AppId of the app registration.
    .PARAMETER ObjectId
    ObjectId of the app registration.
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
        # Retrieve Application from Entra ID
        try {
            switch ($PSCmdlet.ParameterSetName) {
                "Name" {
                    $appEndpoint = "applications?`$filter=displayName eq '{0}'&`$select=displayName,appId,id,requiredResourceAccess" -f $DisplayName
                }
                "AppId" {
                    $appEndpoint = "applications?`$filter=appId eq '{0}'&`$select=displayName,appId,id,requiredResourceAccess" -f $AppId
                }
                "ObjId" {
                    $appEndpoint = "applications/{0}?`$select=displayName,appId,id,requiredResourceAccess" -f $ObjectId
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

        # Retrieve resource access details
        $apiPermissions = New-Object -TypeName System.Collections.Generic.List[PS_MsGraph_Application_APIPermission]
        foreach ($requiredResourceAccess in $application.requiredResourceAccess) {
            $resourceAppId = $null
            $resourceApp = $null
            $rolesTable = $null
            $scopesTable = $null

            # Validate that the resource app hasn't been identified yet.
            try {
                $resourceAppId = $requiredResourceAccess.resourceAppId
                $resourceApp = $resourceAppsTable[$resourceAppId]
                if ([string]::IsNullOrEmpty($resourceApp)) {
                    $resourceApp = Get-MsGServicePrincipal -AppId $resourceAppId -Headers $Headers -ErrorAction 'Stop'
                    $resourceAppsTable.Add($resourceApp.appId, $resourceApp)
                }
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to retrieve resource application from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }

            # Retrieve the app roles table & oauth2 permissions table.
            $rolesTable = $resourceApp.appRoles | Group-Object id -AsHashTable -AsString
            $scopesTable = $resourceApp.oauth2PermissionScopes | Group-Object id -AsHashTable -AsString

            # Iterate through permissions
            foreach ($resourceAccess in $requiredResourceAccess.resourceAccess) {
                $permissionInfo = $null
                switch ($resourceAccess.type) {
                    "Role" {
                        $permissionType = 'Application'
                        $permissionInfo = $rolesTable[$resourceAccess.id]
                        $permissionDescription = $permissionInfo.description
                    }
                    "Scope" {
                        $permissionType = 'Delegated'
                        $permissionInfo = $scopesTable[$resourceAccess.id]
                        $permissionDescription = $permissionInfo.adminConsentDescription
                    }
                }

                try {
                    $customPermission = New-Object -TypeName 'PS_MsGraph_Application_APIPermission' -ArgumentList ($permissionDescription, $permissionInfo.id, $permissionInfo.value, $resourceApp.appId, $resourceApp.displayName, $permissionType)
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