function Remove-MsGApplicationAPIPermission {
    <#
    .SYNOPSIS
    Removes specified API permission from application.
    .DESCRIPTION
    This function removes specified API permissions from an app registration. Both application and delegated permissions can be removed for any resource application.
    .PARAMETER DisplayName
    Display Name of the app registration.
    .PARAMETER AppId
    App/Client Id of the app registration.
    .PARAMETER ObjectId
    Object Id of the app registration.
    .PARAMETER Permission
    List of permissions to remove from the app registration.
    .PARAMETER Type
    Type of permissions to remove from the app registration.
    .PARAMETER ResourceAppId
    App/Client Id of the resource application that the permissions are assigned from.
    .PARAMETER Force
    Forces the addition without any prompts.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Remove-MsGApplicationAPIPermission -DisplayName TestApp-01 -Permission User.Read.All -Type Application -Force

    This removes the User.Read.All Application API Permission for Microsoft Graph from the TestApp-01 app registration.
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
            $applicationPermissionTable = $resourceApp | Select-Object -ExpandProperty 'appRoles' | Group-Object 'id' -AsHashTable -AsString
            $delegatedPermissionTable = $resourceApp | Select-Object -ExpandProperty 'oauth2PermissionScopes' | Group-Object 'id' -AsHashTable -AsString
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

        # Update app registration resource access.
        $appRequiredResourceAccess = $application.requiredResourceAccess
        $updatedRequiredResourceAccess = New-Object -TypeName System.Collections.Generic.List[psobject]
        foreach ($requiredResourceAccess in $appRequiredResourceAccess) {
            if ($requiredResourceAccess.resourceAppId -eq $resourceApp.appId) {
                $ResourceAccess = $requiredResourceAccess.resourceAccess
                $UpdatedResourceAccess = New-Object -TypeName System.Collections.Generic.List[psobject]

                foreach ($ExistingPermission in $ResourceAccess) {
                    $permissionName = $null
                    $permissionType = $null

                    switch ($ExistingPermission.type) {
                        "Role" {
                            $permissionName = $applicationPermissionTable[$ExistingPermission.id].value
                            $permissionType = 'Application'
                        }
                        "Scope" {
                            $permissionName = $delegatedPermissionTable[$ExistingPermission.id].value
                            $permissionType = 'Delegated'
                        }
                    }

                    if (($permissionType -ne $Type) -or (-not($permissionName -in $Permission -and $permissionType -eq $Type))) {
                        $UpdatedResourceAccess.Add($ExistingPermission)
                    }
                }

                $newRequiredResourceAccess = [PSCustomObject]@{
                    'resourceAppId'  = $requiredResourceAccess.resourceAppId
                    'resourceAccess' = $UpdatedResourceAccess
                }
                $updatedRequiredResourceAccess.Add($newRequiredResourceAccess)
            }
            else {
                $updatedRequiredResourceAccess.Add($requiredResourceAccess)
            }
        }

        if (($PSCmdlet.ShouldProcess(($Permission -join ' '), 'Remove Application API Permission')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove [$ResourceAppId] '$($Permission -join ' ')' $Type-Level permission from '$($application.displayName)'.", 'Are you sure you would like to proceed?')))) {
            try {
                $endpoint = 'applications/{0}' -f $application.id
                $body = @{
                    'requiredResourceAccess' = $updatedRequiredResourceAccess
                }
                Invoke-MsGRequest -Method Patch -Endpoint $endpoint -Body $body -Headers $Headers -ErrorAction 'Stop' > $null
                Remove-MsGServicePrincipalAPIPermission -AppId $application.appId -Permission $Permission -Type $Type -ResourceAppId $ResourceAppId -Force -Headers $Headers -ErrorAction 'Stop' > $null
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to remove the {1} API permissions for the following from the application in Entra ID: {2}. Error: {3}' -f $MyInvocation.MyCommand.Name, $Type, ($Permission -join ', '), $errorMessage
                throw $errorException
            }
        }
        # end region
    }
}