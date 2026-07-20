function Get-MsGServicePrincipal {
    <#
    .SYNOPSIS
    Retrieves properties of service principals.
    .DESCRIPTION
    This function retrieves the properties of service principals.
    .PARAMETER DisplayName
    DisplayName of the service principal.
    .PARAMETER AppId
    AppId of the service principal.
    .PARAMETER ObjectId
    ObjectId of the service principal.
    .PARAMETER Filter
    Filter string for retrieving service principals by property values.
    .PARAMETER AdvancedQuery
    To use when querying using an advanced filter.
    .PARAMETER All
    To retrieve all available service principals from Entra ID.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
        [parameter(Mandatory = $true, ParameterSetName = 'Filter', Position = 3)][string]$Filter,
        [parameter(Mandatory = $false, ParameterSetName = 'Filter', Position = 4)][switch]$AdvancedQuery,
        [parameter(Mandatory = $true, ParameterSetName = 'All', Position = 5)][switch]$All,
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
        $baseEndpoint = 'servicePrincipals'
        # end region
    }
    PROCESS {
        try {
            # Create Query Parameters
            switch ($PSCmdlet.ParameterSetName) {
                "Name" {
                    $filterQuery = "displayName eq '{0}'" -f $DisplayName
                    $graphEndpoint = '{0}?$filter={1}' -f $baseEndpoint, $filterQuery
                }
                "AppId" {
                    $graphEndpoint = "{0}(appId='{1}')" -f $baseEndpoint, $AppId
                }
                "ObjId" {
                    $graphEndpoint = '{0}/{1}' -f $baseEndpoint, $ObjectId
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