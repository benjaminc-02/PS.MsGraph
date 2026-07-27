function Add-MsGApplicationFederatedCredential {
    <#
    .SYNOPSIS
    Adds a specified federated credential to an app registration in Entra ID.
    .DESCRIPTION
    This function adds a specified federated identity credential to an app registration in Entra ID, allowing for external OIDC identity providers to authentication to the application.
    .PARAMETER DisplayName
    Display Name of the app registration.
    .PARAMETER AppId
    App/Client Id of the app registration.
    .PARAMETER ObjectId
    Object Id of the app registration.
    .PARAMETER FCName
    Name of the federated credential.
    .PARAMETER Issuer
    The URL of the external identity provider. Must match the issuer claim of the external token being exchanged.
    .PARAMETER Subject
    The identifier of the external software workload within the external identity provider. Like the audience value, it has no fixed format, as each IdP uses their own - sometimes a GUID, sometimes a colon delimited identifier, sometimes arbitrary strings. The value here must match the sub claim within the token presented to Microsoft Entra ID.
    .PARAMETER ClaimsMatchingExpression
    Enables the use of claims matching expressions against specified claims.
    .PARAMETER Audience
    The audience that can appear in the external token.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Add-MsGApplicationFederatedCredential -DisplayName TestApp-01 -FCName FlexCred-Test -Issuer https://app.terraform.io -Subject 'organization:test-org:project:test-proj:workspace:test-workspace:run_phase:plan'

    Adds the specified federated identity credential for the specified issuer and subject.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name-Subject', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [parameter(Mandatory = $true, ParameterSetName = 'Name-ClaimsMatch', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DisplayName,

        [parameter(Mandatory = $true, ParameterSetName = 'AppId-Subject', Position = 1)]
        [parameter(Mandatory = $true, ParameterSetName = 'AppId-ClaimsMatch', Position = 1)]
        [string]$AppId,

        [parameter(Mandatory = $true, ParameterSetName = 'ObjId-Subject', Position = 2)]
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId-ClaimsMatch', Position = 2)]
        [string]$ObjectId,

        [parameter(Mandatory = $true, Position = 3)][Alias('FederatedCredentialName', 'FedCredName')][string]$FCName,
        [parameter(Mandatory = $true, Position = 4)][string]$Issuer,

        [parameter(Mandatory = $true, ParameterSetName = 'Name-Subject', Position = 4)]
        [parameter(Mandatory = $true, ParameterSetName = 'AppId-Subject', Position = 4)]
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId-Subject', Position = 4)]
        [string]$Subject,

        [parameter(Mandatory = $true, ParameterSetName = 'Name-ClaimsMatch', Position = 5)]
        [parameter(Mandatory = $true, ParameterSetName = 'AppId-ClaimsMatch', Position = 5)]
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId-ClaimsMatch', Position = 5)]
        [string]$ClaimsMatchingExpression,

        [parameter(Mandatory = $false)][string[]]$Audience = 'api://AzureADTokenExchange',
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
            switch -Wildcard ($PSCmdlet.ParameterSetName) {
                "Name-*" {
                    $appEndpoint = "applications?`$filter=displayName eq '{0}'" -f $DisplayName
                }
                "AppId-*" {
                    $appEndpoint = "applications?`$filter=appId eq '{0}'" -f $AppId
                }
                "ObjId-*" {
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
            'Endpoint'    = 'applications/{0}/federatedIdentityCredentials' -f $application.id
            'Headers'     = $Headers
            'ErrorAction' = 'Stop'
        }

        $body = @{
            'name'      = $FCName
            'issuer'    = $Issuer
            'audiences' = $Audience
        }

        switch -Wildcard ($PSCmdlet.ParameterSetName) {
            "*-Subject" {
                $body.Add('subject', $Subject)
                $bodyParams.Add('version', 'v1.0')
            }
            "*-ClaimsMatch" {
                $claimsMatch = @{
                    'languageVersion' = 1
                    'value'           = $ClaimsMatchingExpression
                }
                $body.Add('claimsMatchingExpression', $claimsMatch)
                $bodyParams.Add('version', 'beta')
            }
        }
        $bodyParams.Add('body', $body)
        # end region

        # Create Federated Credential
        if ($PSCmdlet.ShouldProcess($application.displayName, 'Add Application Federated Credential')) {
            try {
                Invoke-MsGRequest @bodyParams
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to add federated credential to the application in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
        }
        # end region
    }
}