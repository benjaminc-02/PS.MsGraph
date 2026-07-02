function Get-MsGUserAuthMethod {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('UserId')][string]$UserPrincipalName,

        [parameter(Mandatory = $false, Position = 1)]
        [ValidateSet('All', 'Email', 'External', 'FIDO2', 'MSAuthApp', 'Password', 'Phone', 'PlatformCredential', 'SoftwareOath', 'TAP', 'WHFB')]
        [string]$AuthMethod = 'All',

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

        # Authentication Methods
        $authMethodEndpointTable = @{
            'Email'              = 'authentication/emailMethods'
            'External'           = 'authentication/externalAuthenticationMethods'
            'FIDO2'              = 'authentication/fido2Methods'
            'MSAuthApp'          = 'authentication/microsoftAuthenticatorMethods'
            'Password'           = 'authentication/passwordMethods'
            'Phone'              = 'authentication/phoneMethods'
            'PlatformCredential' = 'authentication/platformCredentialMethods'
            'SoftwareOath'       = 'authentication/softwareOathMethods'
            'TAP'                = 'authentication/temporaryAccessPassMethods'
            'WHFB'               = 'authentication/windowsHelloForBusinessMethods'
        }
        # end region
    }
    PROCESS {
        # Retrieve directory object.
        try {
            $user = Get-MsGUser -UserPrincipalName $UserPrincipalName -Headers $Headers -ErrorAction 'Stop'
            if ([string]::IsNullOrEmpty($user)) {
                $errorMessage = 'User not found.'
                throw $errorMessage
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve user from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Retrieve auth methods
        try {
            if ($AuthMethod -eq 'All') {
                $graphEndpoint = 'users/{0}/authentication/methods' -f $user.id
            }
            else {
                $methodEndpoint = $authMethodEndpointTable[$AuthMethod]
                $graphEndpoint = 'users/{0}/{1}' -f $user.id, $methodEndpoint
            }

            $irmResponse = Invoke-MsGRequest -Method Get -Endpoint $graphEndpoint -Version 'v1.0' -Headers $Headers -ErrorAction 'Stop'
            Write-Output $irmResponse
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve user auth methods from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region
    }
}