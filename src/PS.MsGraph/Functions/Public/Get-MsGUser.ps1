function Get-MsGUser {
    <#
    .SYNOPSIS
    Retrieves properties of users.
    .DESCRIPTION
    This function retrieves the properties of users.
    .PARAMETER UserPrincipalName
    UserPrincipalName or ObjectId of the user.
    .PARAMETER Filter
    Filter string for retrieving users by property values.
    .PARAMETER AdvancedQuery
    To use when querying using an advanced filter.
    .PARAMETER All
    To retrieve all available users from Entra ID.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    #>
    [CmdletBinding(DefaultParameterSetName = 'UserName')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'UserName', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('UserId')][string]$UserPrincipalName,

        [parameter(Mandatory = $true, ParameterSetName = 'Filter', Position = 1)][string]$Filter,
        [parameter(Mandatory = $false, ParameterSetName = 'Filter', Position = 2)][switch]$AdvancedQuery,
        [parameter(Mandatory = $true, ParameterSetName = 'All', Position = 3)][switch]$All,

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

        # Function Endpoint
        $baseEndpoint = 'users'
        # end region
    }
    PROCESS {
        try {
            # Create Query Parameters
            switch ($PSCmdlet.ParameterSetName) {
                "UserName" {
                    $graphEndpoint = '{0}/{1}' -f $baseEndpoint, $UserPrincipalName
                }
                "Filter" {
                    $graphEndpoint = '{0}?$filter={1}' -f $baseEndpoint, $Filter
                    if ($AdvancedQuery) {
                        $Headers.Add('consistencyLevel', 'eventual')
                        $graphEndpoint = '{0}&$count=true' -f $graphEndpoint
                    }
                }
                "All" {
                    $graphEndpoint = $baseEndpoint
                }
            }
            # end region

            # Retrieve results.
            $irmResponse = Invoke-MsGRequest -Method 'Get' -Endpoint $graphEndpoint -Version 'v1.0' -Headers $Headers -ErrorAction 'Stop'
            Write-Output $irmResponse
            # end region
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve {1} from Entra ID. Error: {2}' -f $MyInvocation.MyCommand.Name, $baseEndpoint, $errorMessage
            throw $errorException
        }
    }
}