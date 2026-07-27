function New-MsGApplicationPassword {
    <#
    .SYNOPSIS
    Create new application password.
    .DESCRIPTION
    This function creates a new application password/client secret for a given app registration..
    .PARAMETER DisplayName
    Display Name of the app registration.
    .PARAMETER AppId
    App/Client Id of the app registration.
    .PARAMETER ObjectId
    Object Id of the app registration.
    .PARAMETER DaysTillExpiration
    Days till the password expires.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> New-MsGApplicationPassword -DisplayName TestApp-01 -DaysTillExpiration 365

    @odata.context      : https://graph.microsoft.com/v1.0/$metadata#microsoft.graph.passwordCredential
    customKeyIdentifier :
    displayName         : Password uploaded on Mon Jul 27 2026
    endDateTime         : 7/27/2027 2:43:04 PM
    hint                : -gx
    keyId               : b9192cec-a784-4cc3-babe-067df0dab412
    secretText          : -gx8Q~_H1GPUygPDGJl4D.otjdReVx-x0KnvnaGF
    startDateTime       : 7/27/2026 2:43:04 PM

    Creates a brand new application password for the TestApp-01 app registration.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
        [parameter(Mandatory = $false, Position = 3)][ValidateRange(1, 730)][int]$DaysTillExpiration = 365,
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

        # Format body
        $bodyParams = @{
            'Method'      = 'Post'
            'Endpoint'    = 'applications/{0}/addPassword' -f $application.id
            'Headers'     = $Headers
            'ErrorAction' = 'Stop'
            'Body'        = @{
                'passwordCredential' = @{
                    'displayName' = 'Password uploaded on {0}' -f (Get-Date).ToString('ddd MMM dd yyyy')
                    'endDateTime' = (Get-Date).AddDays($DaysTillExpiration).ToString('o')
                }
            }
        }
        # end region

        # Create Federated Credential
        if ($PSCmdlet.ShouldProcess($application.displayName, 'New Application Password')) {
            try {
                $irmResponse = Invoke-MsGRequest @bodyParams
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to add federated credential to the application in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
            Write-Output $irmResponse
        }
        # end region
    }
}