function Get-MsGApplicationPassword {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
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
                    $appEndpoint = "applications?`$filter=displayName eq '{0}'&`$select=displayName,appId,id,passwordCredentials" -f $DisplayName
                }
                "AppId" {
                    $appEndpoint = "applications?`$filter=appId eq '{0}'&`$select=displayName,appId,id,passwordCredentials" -f $AppId
                }
                "ObjId" {
                    $appEndpoint = "applications/{0}?`$select=displayName,appId,id,passwordCredentials" -f $DisplayName
                }
            }
            $application = Invoke-MsGRequest -Method Get -Endpoint $appEndpoint -Headers $Headers -ErrorAction 'Stop'
            if ([string]::IsNullOrEmpty($application)) {
                $errorMessage = 'Application not found.'
                throw $errorMessage
            }
            $application.passwordCredentials | Sort-Object endDateTime | Write-Output
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve application from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region
    }
}