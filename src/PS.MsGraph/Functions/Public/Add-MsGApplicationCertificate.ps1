function Add-MsGApplicationCertificate {
    <#
    .SYNOPSIS
    Adds a specified certificate to an app registration in Entra ID.
    .DESCRIPTION
    This function adds a specified certificate to an app registration in Entra ID, allowing it to be used for authentication.
    .PARAMETER DisplayName
    Display Name of the app registration.
    .PARAMETER AppId
    App/Client Id of the app registration.
    .PARAMETER ObjectId
    Object Id of the app registration.
    .PARAMETER Path
    Path of the public key certificate.
    .PARAMETER StoreLocation
    Certificate Store location of a stored certificate.
    .PARAMETER Thumbprint
    Thumbprint of the certificate in the stored location.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Add-MsGApplicationCertificate -DisplayName TestApp-01 -Path C:\temp\TestApp-01.cer

    Adds the specified certificate as an authentication certificate to the app registration.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name-Path', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [parameter(Mandatory = $true, ParameterSetName = 'Name-Thumbprint', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DisplayName,

        [parameter(Mandatory = $true, ParameterSetName = 'AppId-Path', Position = 1)]
        [parameter(Mandatory = $true, ParameterSetName = 'AppId-Thumbprint', Position = 1)]
        [string]$AppId,

        [parameter(Mandatory = $true, ParameterSetName = 'ObjId-Path', Position = 2)]
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId-Thumbprint', Position = 2)]
        [string]$ObjectId,

        [parameter(Mandatory = $true, ParameterSetName = 'Name-Path', Position = 3)]
        [parameter(Mandatory = $true, ParameterSetName = 'AppId-Path', Position = 3)]
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId-Path', Position = 3)]
        [string]$Path,

        [parameter(Mandatory = $false, ParameterSetName = 'Name-Path', Position = 4)]
        [parameter(Mandatory = $false, ParameterSetName = 'AppId-Path', Position = 4)]
        [parameter(Mandatory = $false, ParameterSetName = 'ObjId-Path', Position = 4)]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$StoreLocation = 'CurrentUser',

        [parameter(Mandatory = $true, ParameterSetName = 'Name-Thumbprint', Position = 5)]
        [parameter(Mandatory = $true, ParameterSetName = 'AppId-Thumbprint', Position = 5)]
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId-Thumbprint', Position = 5)]
        [string]$Thumbprint,

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
                    $appEndpoint = "applications?`$filter=displayName eq '{0}'&`$select=displayName,appId,id,keyCredentials" -f $DisplayName
                }
                "AppId-*" {
                    $appEndpoint = "applications?`$filter=appId eq '{0}'&`$select=displayName,appId,id,keyCredentials" -f $AppId
                }
                "ObjId-*" {
                    $appEndpoint = "applications/{0}?`$select=displayName,appId,id,keyCredentials" -f $ObjectId
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

        # Set Current Key Credentials
        $updatedKeyCredentials = New-Object -TypeName System.Collections.Generic.List[psobject]
        $application.keyCredentials | ForEach-Object { $updatedKeyCredentials.Add($_) }
        # end region

        # Format key credential to add.
        try {
            switch -Wildcard ($PSCmdlet.ParameterSetName) {
                "*-Path" {
                    $certificateContent = Get-Content -Path $Path -AsByteStream -ErrorAction 'Stop'
                }
                "*-Thumbprint" {
                    $certificateItemPath = 'Cert:\{0}\My\{1}' -f $StoreLocation, $Thumbprint
                    $certificateContent = Get-Item -Path $certificateItemPath | Select-Object -ExpandProperty 'RawData'
                }
            }
            $certificatePublicKey = [convert]::ToBase64String($certificateContent)
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve certificate public key from the given {1}. Error: {2}' -f $MyInvocation.MyCommand.Name, $PSCmdlet.ParameterSetName.Split('-')[-1], $errorMessage
            throw $errorException
        }

        $customKeyCredential = [pscustomobject]@{
            'type'  = 'AsymmetricX509Cert'
            'usage' = 'Verify'
            'key'   = $certificatePublicKey
        }
        $updatedKeyCredentials.Add($customKeyCredential)
        # end region

        # Update application
        if ($PSCmdlet.ShouldProcess($application.displayName, 'Add Application Certificate')) {
            try {
                $endpoint = 'applications/{0}' -f $application.id
                $body = @{
                    'keyCredentials' = $updatedKeyCredentials
                }
                Invoke-MsGRequest -Method Patch -Endpoint $endpoint -Body $body -Headers $Headers -ErrorAction 'Stop' > $null
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to upload certificate to the application in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
        }
        # end region
    }
}