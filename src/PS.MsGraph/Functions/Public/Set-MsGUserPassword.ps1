function Set-MsGUserPassword {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][Alias('UserId')][string]$UserPrincipalName,
        [parameter(Mandatory = $true, Position = 1)][securestring]$NewPassword,
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

        # Set Update Body
        $credential = [pscredential]::new($UserPrincipalName, $NewPassword)
        $body = @{
            'passwordProfile' = @{
                'forceChangePasswordNextSignIn'        = $false
                'forceChangePasswordNextSignInWithMfa' = $false
                'password'                             = $credential.GetNetworkCredential().Password
            }
        }
        # end region

        # Update Password
        if ($PSCmdlet.ShouldProcess($user.userPrincipalName, 'Set User Password')) {
            try {
                $endpoint = 'users/{0}' -f $user.id
                Invoke-MsGRequest -Method Patch -Endpoint $endpoint -Body $body @irmParams
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to update user password in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
        }
        # end region
    }
}