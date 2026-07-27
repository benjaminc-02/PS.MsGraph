function Remove-MsGApplicationCertificate {
    <#
    .SYNOPSIS
    Removes a specified certificate from an app registration in Entra ID.
    .DESCRIPTION
    This function removes a specified certificate from an app registration in Entra ID, preventing it from be used for authentication.
    .PARAMETER DisplayName
    Display Name of the app registration.
    .PARAMETER AppId
    App/Client Id of the app registration.
    .PARAMETER ObjectId
    Object Id of the app registration.
    .PARAMETER Thumbprint
    Thumbprint of the certificate on the app registration.
    .PARAMETER Force
    Bypasses the confirmation check.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Remove-MsGApplicationCertificate -DisplayName TestApp-01 -Thumbprint A909502DD82AE41433E6F83886B00D4277A32A7B -Force

    This will remove the "A909502DD82AE41433E6F83886B00D4277A32A7B" thumbprint from the TestApp-01 app registration.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
        [parameter(Mandatory = $true, Position = 3)][string]$Thumbprint,
        [parameter(Mandatory = $false)][switch]$Force,
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
                    $appEndpoint = "applications?`$filter=displayName eq '{0}'&`$select=displayName,appId,id,keyCredentials" -f $DisplayName
                }
                "AppId" {
                    $appEndpoint = "applications?`$filter=appId eq '{0}'&`$select=displayName,appId,id,keyCredentials" -f $AppId
                }
                "ObjId" {
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

        # Remove Certificate
        try {
            if ($application.keyCredentials.customKeyIdentifier -contains $Thumbprint) {
                $updatedKeyCredentials = $application.keyCredentials | Where-Object { $_.customKeyIdentifier -ne $Thumbprint }
            }
            else {
                $errorException = '{0} is not tied to the application.' -f $Thumbprint
                throw $errorException
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to remove certificate from the application key credentials. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Update application
        if (($PSCmdlet.ShouldProcess($application.displayName, 'Remove Application Certificate')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove '$Thumbprint' from '$($application.displayName)'.", 'Are you sure you want to proceed?')))) {
            try {
                $endpoint = 'applications/{0}' -f $application.id
                $body = @{
                    'keyCredentials' = $updatedKeyCredentials
                }
                Invoke-MsGRequest -Method Patch -Endpoint $endpoint -Body $body -Headers $Headers -ErrorAction 'Stop' > $null
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to remove certificate from the application in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
        }
        # end region
    }
}