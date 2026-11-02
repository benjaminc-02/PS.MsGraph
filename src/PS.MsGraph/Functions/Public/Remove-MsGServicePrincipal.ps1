function Remove-MsGServicePrincipal {
    <#
    .SYNOPSIS
    Removes service principal from Entra ID.
    .DESCRIPTION
    This function removes a specified service principal from Entra ID, deleting the object.
    .PARAMETER DisplayName
    Display Name of the service principal.
    .PARAMETER AppId
    App/Client Id of the service principal.
    .PARAMETER ObjectId
    Object Id of the service principal.
    .PARAMETER Force
    Bypasses the confirmation check.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Remove-MsGServicePrincipal -DisplayName TestApp-01 -Force

    This removes the TestApp-01 service principal from Entra ID.
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

        # Delete object
        if (($PSCmdlet.ShouldProcess($servicePrincipal.displayName, 'Remove Service Principal')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove the service principal '$($servicePrincipal.displayName)' from Entra ID.", 'Are you sure you want to proceed?')))) {
            try {
                $appEndpoint = "servicePrincipals/{0}" -f $servicePrincipal.id
                Invoke-MsGRequest -Method Delete -Endpoint $appEndpoint @irmParams > $null
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to remove service principal from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
        }
        # end region
    }
}