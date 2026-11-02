function Remove-MsGUser {
    <#
    .SYNOPSIS
    Removes a specified user from Entra ID.
    .DESCRIPTION
    This function will remove a specified user from Entra ID, deleting the account.
    .PARAMETER UserPrincipalName
    UserPrincipalName of the user to remove.
    .PARAMETER Force
    Bypasses the confirmation check.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Remove-MsGUser -UserPrincipalName test.account01@testdomain.com -Force

    Removes the "test.account01@testdomain.com" account from Entra ID.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][Alias('UserId')][string]$UserPrincipalName,
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

        # Remove user
        if (($PSCmdlet.ShouldProcess($user.userPrincipalName, 'Remove User')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove the user '$($user.userPrincipalName)' from Entra ID.", 'Are you sure you want to proceed?')))) {
            try {
                $endpoint = 'users/{0}' -f $user.id
                Invoke-MsGRequest -Method Delete -Endpoint $endpoint @irmParams > $null
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to remove user from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
        }
        # end region
    }
}