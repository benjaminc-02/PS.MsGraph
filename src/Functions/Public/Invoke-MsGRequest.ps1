function Invoke-MsGRequest {
    <#
    .SYNOPSIS
    Issues REST API requests to the Graph API.
    .DESCRIPTION
    This function issues REST API requests to the Microsoft Graph API using the specified method and endpoint.
    .PARAMETER Method
    HTTP Method
    .PARAMETER Endpoint
    Endpoint to call
    .PARAMETER Body
    Request Body
    .PARAMETER Version
    Version of the API to call
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, Position = 0)][ValidateSet('Default', 'Delete', 'Get', 'Head', 'Merge', 'Options', 'Patch', 'Post', 'Put', 'Trace')][string]$Method,
        [parameter(Mandatory = $true, Position = 1)][Alias('Uri')][string]$Endpoint,
        [parameter(Mandatory = $false, Position = 2)][hashtable]$Body,
        [parameter(Mandatory = $false, Position = 3)][ValidateSet('v1.0', 'beta')][string]$Version = 'v1.0',
        [parameter(Mandatory = $false)][hashtable]$Headers,
        [parameter(Mandatory = $false)][string]$Jwt
    )
    BEGIN {

        # https://learn.microsoft.com/en-us/graph/query-parameters?tabs=http - Look into later for additional parameters.

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
        # Create Graph Uri
        $graphUri = 'https://graph.microsoft.com/{0}/{1}' -f $Version, $Endpoint

        # Create Rest Method Body
        $bodyParams = @{
            'Method'      = $Method
            'Headers'     = $Headers
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('Body')) {
            $bodyParams.Add('Body', ($Body | ConvertTo-Json -Depth 100))
        }

        # Invoke Rest Method
        try {
            $irmResponse = Invoke-RestMethod @bodyParams -Uri $graphUri
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to invoke the {1} method against the {2} endpoint. Error: {3}' -f $MyInvocation.MyCommand.Name, $Method, $Endpoint, $errorMessage
            throw $errorException
        }

        if ($Method -eq 'Get') {
            # Determine if this is an entity.
            if ($irmResponse.'@odata.context'.Split('/')[-1] -ne '$entity') {
                $totalResponse = New-Object -TypeName System.Collections.Generic.List[psobject]
                $continue = $true
                while ($continue) {
                    $irmResponse.value | ForEach-Object { $totalResponse.Add($_) }
                    $nextLink = $irmResponse.'@odata.nextLink'
                    if ([string]::IsNullOrEmpty($nextLink)) {
                        $continue = $false
                    }
                    else {
                        Write-Verbose $nextLink
                        try {
                            $irmResponse = Invoke-RestMethod @bodyParams -Uri $nextLink
                        }
                        catch {
                            $warningMessage = 'Unable to retrieve next link for requested endpoint. Outputting current retrieved responses.'
                            Write-Warning $warningMessage
                            $continue = $false
                        }
                        $continue = $true
                    }
                }

                # No more $nextLink. Response can be outputted.
                Write-Output $totalResponse
            }
            else {
                # No other entities. Response can be outputted.
                Write-Output $irmResponse
            }
        }
        else {
            # Not a Get request. Response can be outputted.
            Write-Output $irmResponse
        }
    }
}