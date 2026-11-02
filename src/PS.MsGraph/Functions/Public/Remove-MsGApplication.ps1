function Remove-MsGApplication {
    <#
    .SYNOPSIS
    Removes app registration from Entra ID.
    .DESCRIPTION
    This function removes a specified app registration from Entra ID, deleting the object.
    .PARAMETER DisplayName
    Display Name of the app registration.
    .PARAMETER AppId
    App/Client Id of the app registration.
    .PARAMETER ObjectId
    Object Id of the app registration.
    .PARAMETER Force
    Bypasses the confirmation check.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Remove-MsGApplication -DisplayName TestApp-01 -Force

    This removes the TestApp-01 app registration from Entra ID.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
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
        # Retrieve object
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
            $application = Invoke-MsGRequest -Method Get -Endpoint $appEndpoint @irmParams
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

        # Delete object
        if (($PSCmdlet.ShouldProcess($application.displayName, 'Remove Application')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove the application '$($application.displayName)' from Entra ID.", 'Are you sure you want to proceed?')))) {
            try {
                $appEndpoint = "applications/{0}" -f $application.id
                Invoke-MsGRequest -Method Delete -Endpoint $appEndpoint @irmParams > $null
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to remove application from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
        }
        # end region
    }
}