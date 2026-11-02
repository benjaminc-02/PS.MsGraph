function New-MsGApplication {
    <#
    .SYNOPSIS
    Creates new app registration in Entra ID.
    .DESCRIPTION
    This function will create a app registration object in Entra ID.
    .PARAMETER DisplayName
    Display name of the app registration.
    .PARAMETER Description
    Description of the app registration.
    .PARAMETER Notes
    Notes of the app registration.
    .PARAMETER SignInAudience
    Specifies the Micrisoft accounts that are supported for the app registration.
    .PARAMETER Tags
    Tags of the app registration.
    .PARAMETER ServicePrincipal
    Determines whether a service principal will be created with the app registration.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> New-MsGApplication -DisplayName 'TestApp-01' -Description 'Test App Creation' -Notes 'This is a test app.' -Tags 'tag:api-created'

    This will create the 'TestApp-01' app registration.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, Position = 0)][string]$DisplayName,
        [parameter(Mandatory = $false)][string]$Description,
        [parameter(Mandatory = $false)][string]$Notes,
        [parameter(Mandatory = $false)][ValidateSet('AzureADMyOrg', 'AzureADMultipleOrgs', 'AzureADandPersonalMicrosoftAccount', 'PersonalMicrosoftAccount')][string]$SignInAudience = 'AzureADMyOrg',
        [parameter(Mandatory = $false)][string[]]$Tags,
        [parameter(Mandatory = $false)][bool]$ServicePrincipal = $true,
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
        $body = @{
            'displayName'    = $DisplayName
            'signInAudience' = $SignInAudience
        }
        # end region

        # Add description
        if ($PSBoundParameters.ContainsKey('Description')) {
            $body.Add('description', $Description)
        }
        # end region

        # Add notes
        if ($PSBoundParameters.ContainsKey('Notes')) {
            $body.Add('notes', $Notes)
        }
        # end region

        # Add tags
        if ($PSBoundParameters.ContainsKey('Tags')) {
            $body.Add('tags', $Tags)
        }
        # end region

        # Create app registration
        $bodyParams = @{
            'Method'      = 'Post'
            'Endpoint'    = 'applications'
            'Headers'     = $Headers
            'ErrorAction' = 'Stop'
            'Body'        = $body
        }

        if ($PSCmdlet.ShouldProcess($DisplayName, 'New Application')) {
            try {
                $irmResponse = Invoke-MsGRequest @bodyParams
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to create new application in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
            Write-Output $irmResponse

            if ($ServicePrincipal) {
                $spBodyParams = @{
                    'Method'      = 'Post'
                    'Endpoint'    = 'servicePrincipals'
                    'Headers'     = $Headers
                    'ErrorAction' = 'Stop'
                    'Body'        = @{
                        'appId' = $irmResponse.appId
                    }
                }

                try {
                    Invoke-MsGRequest @spBodyParams > $null
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = '{0} : Unable to create new service principal in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                    throw $errorException
                }
            }
        }
        # end region
    }
}