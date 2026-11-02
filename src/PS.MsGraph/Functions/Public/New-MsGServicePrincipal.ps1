function New-MsGServicePrincipal {
    <#
    .SYNOPSIS
    Create new service principal.
    .DESCRIPTION
    This function creates a new service principal from an existing app registration.
    .PARAMETER AppId
    App/Client Id of the app registration.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> New-MsGServicePrincipal -AppId '98a280f3-4c22-4973-afdc-8d7c12ffefa6'

    Creates a new service principal from the app id.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, Position = 0)][string]$AppId,
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
    }
    PROCESS {
        # Create body
        $bodyParams = @{
            'Method'      = 'Post'
            'Endpoint'    = 'servicePrincipals'
            'Headers'     = $Headers
            'ErrorAction' = 'Stop'
            'Body'        = @{
                'appId' = $AppId
            }
        }
        # end region

        # Create new service principal
        if ($PSCmdlet.ShouldProcess($AppId, 'New Service Principal')) {
            try {
                $irmResponse = Invoke-MsGRequest @bodyParams
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to create new service principal in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
            Write-Output $irmResponse
        }
        # end region
    }
}