function Get-MsGAccessToken {
    [CmdletBinding(DefaultParameterSetName = 'UserAccount')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'ClientSecretCredential')]
        [pscredential]$ServicePrincipalCredential,

        [parameter(Mandatory = $true, ParameterSetName = 'ClientSecret')]
        [parameter(Mandatory = $true, ParameterSetName = 'Certificate')]
        [string]$ClientId,

        [parameter(Mandatory = $true, ParameterSetName = 'ClientSecret')]
        [string]$ClientSecret,

        [parameter(Mandatory = $true, ParameterSetName = 'Certificate')]
        [string]$Thumbprint,

        [parameter(Mandatory = $false, ParameterSetName = 'Certificate')]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$CertificateStore = 'CurrentUser',

        [parameter(Mandatory = $false)]
        [ValidateSet('Graph', 'DevOps', 'Keyvault', 'Management')]
        [string]$ResourceName = 'Graph',

        [parameter(Mandatory = $false, ParameterSetName = 'UserAccount')]
        [string[]]$Scopes = ('User.Read'),

        [parameter(Mandatory = $false)][string]$ResourceUrl = 'https://graph.microsoft.com',
        [parameter(Mandatory = $false)][string]$TenantId = '4de45879-f7de-4a82-8331-0c27309152e6',
        [parameter(Mandatory = $false)][switch]$AsHeaders
    )
    BEGIN {
        # Retrieve ResourceUrl if not present.
        if ($PSBoundParameters.ContainsKey('ResourceName') -eq $true) {
            Write-Verbose "Resource Name: $ResourceName"
            $resourceUrlTable = @{
                'Graph'      = 'https://graph.microsoft.com/'
                'DevOps'     = '499b84ac-1321-427f-aa17-267ca6975798'
                'Keyvault'   = 'https://vault.azure.net/'
                'Management' = 'https://management.azure.com/'
            }
            $ResourceUrl = $resourceUrlTable[$ResourceName]
        }
        # end region
        Write-Verbose $ResourceUrl
    }
    PROCESS {
        # Retrieve Jwt from Azure
        switch ($PSCmdlet.ParameterSetName) {
            "UserAccount" {
                try {
                    if ($ResourceName -eq 'Graph') {
                        $msalToken = Get-MsalToken -ClientId '14d82eec-204b-4c2f-b7e8-296a70dab67e' -Scopes $Scopes -TenantId $TenantId -ErrorAction 'Stop'
                        $jwt = $msalToken.AccessToken
                    }
                    else {
                        Connect-AzAccount -Tenant $TenantId -ErrorAction Stop -WarningAction SilentlyContinue > $null
                        $accessToken = Get-AzAccessToken -ResourceUrl $ResourceUrl -WarningAction SilentlyContinue -ErrorAction 'Stop'
                        $accessTokenCredential = [pscredential]::new('dummyUser', $accessToken.Token)
                        $jwt = $accessTokenCredential.GetNetworkCredential().Password
                    }
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = '{0} : Unable to retrieve user jwt from Entra ID for {1}. Error: {2}' -f $MyInvocation.MyCommand.Name, $ResourceUrl, $errorMessage
                    throw $errorException
                }
            }
            "ClientSecretCredential" {
                $TokenBody = @{
                    'grant_type'    = 'client_credentials'
                    'client_id'     = $ServicePrincipalCredential.UserName
                    'client_secret' = $ServicePrincipalCredential.GetNetworkCredential().Password
                    'scope'         = '{0}/.default' -f $ResourceUrl
                }
                $TokenUri = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token' -f $TenantId
                try {
                    $jwtResults = Invoke-RestMethod -Method Post -Uri $TokenUri -Body $TokenBody -ErrorAction Stop
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = '{0} : Unable to retrieve client credential jwt from Entra ID for {1}. Error: {2}' -f $MyInvocation.MyCommand.Name, $ResourceUrl, $errorMessage
                    throw $errorException
                }
                $jwt = $jwtResults.access_token
            }
            "ClientSecret" {
                $TokenBody = @{
                    'grant_type'    = 'client_credentials'
                    'client_id'     = $ClientId
                    'client_secret' = $ClientSecret
                    'scope'         = '{0}/.default' -f $ResourceUrl
                }
                $TokenUri = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token' -f $TenantId
                try {
                    $jwtResults = Invoke-RestMethod -Method Post -Uri $TokenUri -Body $TokenBody -ErrorAction Stop
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = '{0} : Unable to retrieve client credential jwt from Entra ID for {1}. Error: {2}' -f $MyInvocation.MyCommand.Name, $ResourceUrl, $errorMessage
                    throw $errorException
                }
                $jwt = $jwtResults.access_token
            }
            "Certificate" {
                $CertificatePath = 'Cert:\{0}\My\{1}' -f $CertificateStore, $Thumbprint
                try {
                    $Certificate = Get-Item $CertificatePath -ErrorAction 'Stop'
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = '{0} : Unable to retrieve certificate from {1}. Error: {2}' -f $MyInvocation.MyCommand.Name, $CertificatePath, $errorMessage
                    throw $errorException
                }

                $CertificateBase64Hash = [System.Convert]::ToBase64String($Certificate.GetCertHash())
                $StartDate = (Get-Date "1970-01-01T00:00:00Z" ).ToUniversalTime()
                $JWTExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End (Get-Date).ToUniversalTime().AddMinutes(2)).TotalSeconds
                $JWTExpiration = [math]::Round($JWTExpirationTimeSpan, 0)
                $NotBeforeExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End ((Get-Date).ToUniversalTime())).TotalSeconds
                $NotBefore = [math]::Round($NotBeforeExpirationTimeSpan, 0)
                $JWTHeader = @{
                    alg = "RS256"
                    typ = "JWT"
                    x5t = $CertificateBase64Hash -replace '\+', '-' -replace '/', '_' -replace '='
                }
                $JWTPayLoad = @{
                    aud = 'https://login.microsoftonline.com/{0}/oauth2/token' -f $TenantId
                    exp = $JWTExpiration
                    iss = $ClientID
                    jti = [guid]::NewGuid()
                    nbf = $NotBefore
                    sub = $ClientID
                }
                $JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json))
                $EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte)
                $JWTPayLoadToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json))
                $EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte)
                $JWTToken = $EncodedHeader + "." + $EncodedPayload
                $PrivateKey = ([System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Certificate))
                $RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
                $HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256
                $Signature = [Convert]::ToBase64String(
                    $PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWTToken), $HashAlgorithm, $RSAPadding)
                ) -replace '\+', '-' -replace '/', '_' -replace '='
                $JWTToken = $JWTToken + "." + $Signature

                $tokenBody = @{
                    client_id             = $ClientID
                    client_assertion      = $JWTToken
                    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
                    scope                 = '{0}/.default' -f $ResourceUrl
                    grant_type            = "client_credentials"
                }
                $TokenUri = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token' -f $TenantId
                $tokenHeaders = @{ Authorization = "Bearer $JWTToken" }
                try {
                    $jwtResults = Invoke-RestMethod -Method Post -Uri $TokenUri -Body $tokenBody -Headers $tokenHeaders -ContentType 'application/x-www-form-urlencoded'
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = '{0} : Unable to retrieve client credential jwt from Entra ID for {1}. Error: {2}' -f $MyInvocation.MyCommand.Name, $ResourceUrl, $errorMessage
                    throw $errorException
                }
                $jwt = $jwtResults.access_token
            }
        }
        # end region

        # Write output
        if ($PSBoundParameters.ContainsKey('AsHeaders')) {
            $Headers = @{
                'Authorization' = 'Bearer {0}' -f $jwt
                'Content-Type'  = 'application/json'
            }
            Write-Output $Headers
        }
        else {
            Write-Output $jwt
        }
        # end region
    }
}