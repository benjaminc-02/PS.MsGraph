function Reset-MsGUserAuthMethod {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][Alias('UserId')][string]$UserPrincipalName,
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

        $resetAuthMethods = @(
            '#microsoft.graph.emailAuthenticationMethod',
            '#microsoft.graph.externalAuthenticationMethod',
            '#microsoft.graph.fido2AuthenticationMethod',
            '#microsoft.graph.microsoftAuthenticatorAuthenticationMethod',
            '#microsoft.graph.phoneAuthenticationMethod',
            '#microsoft.graph.softwareOathAuthenticationMethod',
            '#microsoft.graph.temporaryAccessPassAuthenticationMethod'
        )
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
            $methodsToRemove = $authMethods | Where-Object { $_.'@odata.type' -in $resetAuthMethods }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve user auth methods from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Remove each auth method.
        if (($PSCmdlet.ShouldProcess($user.userPrincipalName, 'Reset User Auth Method')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Reset all $($user.userPrincipalName) MFA methods [$($methodsToRemove | Measure-Object | Select-Object -ExpandProperty 'Count')].", 'Are you sure you would like to proceed?')))) {
            foreach ($method in $methodsToRemove) {
                try {
                    Remove-MsGUserAuthMethod -UserPrincipalName $user.userPrincipalName -AuthMethodId $method.id -Force @irmParams
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $warningMessage = 'Unable to reset {0} [{1}] method in Entra ID. Skipping authentication method. Error: {2}' -f $method.id, $method.'@odata.type', $errorMessage
                    Write-Warning $warningMessage
                    continue
                }
            }
        }
        # end region
    }
}