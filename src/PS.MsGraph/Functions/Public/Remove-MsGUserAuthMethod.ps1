function Remove-MsGUserAuthMethod {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][Alias('UserId')][string]$UserPrincipalName,
        [parameter(Mandatory = $false, Position = 1)][string]$AuthMethodId,
        [parameter(Mandatory = $false, Position = 2)][switch]$Force,
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

        $odataTypeTable = @{
            'emailAuthenticationMethod'                   = 'authentication/emailMethods'
            'externalAuthenticationMethod'                = 'authentication/externalAuthenticationMethods'
            'fido2AuthenticationMethod'                   = 'authentication/fido2Methods'
            'microsoftAuthenticatorAuthenticationMethod'  = 'authentication/microsoftAuthenticatorMethods'
            'phoneAuthenticationMethod'                   = 'authentication/phoneMethods'
            'platformCredentialAuthenticationMethod'      = 'authentication/platformCredentialMethods'
            'softwareOathAuthenticationMethod'            = 'authentication/softwareOathMethods'
            'temporaryAccessPassAuthenticationMethod'     = 'authentication/temporaryAccessPassMethods'
            'windowsHelloForBusinessAuthenticationMethod' = 'authentication/windowsHelloForBusinessMethods'
        }
        # end Session Checks
    }
    PROCESS {
        # Retrieve directory object.
        try {
            $user = Get-MsGUser -UserPrincipalName $UserPrincipalName @irmParams
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

        # Retrieve user auth methods.
        try {
            $authMethods = Get-MsGUserAuthMethod -UserPrincipalName $user.userPrincipalName @irmParams
            if ($PSBoundParameters.ContainsKey('AuthMethodId')) {
                $filterScript = { $_.'@odata.type' -ne '#microsoft.graph.passwordAuthenticationMethod' -and $_.id -eq $AuthMethodId }
            }
            else {
                $filterScript = { $_.'@odata.type' -ne '#microsoft.graph.passwordAuthenticationMethod' }
            }
            $methodsToRemove = $authMethods | Where-Object -FilterScript $filterScript
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve user auth methods from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Remove auth method
        foreach ($method in $methodsToRemove) {
            if (($PSCmdlet.ShouldProcess(('{0} [{1}]' -f $method.id, $method.'@odata.type'), 'Remove User Auth Method')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove $('{0} [{1}]' -f $method.id, $method.'@odata.type') authentication method from $UserPrincipalName.", 'Are you sure you would like to proceed?')))) {
                try {
                    $baseEndpoint = $odataTypeTable[$method.'@odata.type'.Split('.')[-1]]
                    $endpoint = 'users/{0}/{1}/{2}' -f $user.id, $baseEndpoint, $method.id
                    Invoke-MsGRequest -Method Delete -Endpoint $endpoint @irmParams > $null
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = '{0} : Unable to remove {1} [{2}] from {3} in Entra ID. Error: {4}' -f $MyInvocation.MyCommand.Name, $method.id, $method.'@odata.type', $UserPrincipalName, $errorMessage
                    throw $errorException
                }
            }
        }
        # end region
    }
}