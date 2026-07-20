function Get-MsGDirectoryRoleDefinition {
    <#
    .SYNOPSIS
    Retrieves properties of role definitions.
    .DESCRIPTION
    This function retrieves the properties of role definitions.
    .PARAMETER DisplayName
    DisplayName of the role definition.
    .PARAMETER ObjectId
    ObjectId of the role definition.
    .PARAMETER All
    To retrieve all available role definitions from Entra ID.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 1)][string]$ObjectId,
        [parameter(Mandatory = $true, ParameterSetName = 'All', Position = 2)][switch]$All,
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
        $baseEndpoint = 'roleManagement/directory/roleDefinitions'
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
                "ObjId" {
                    $graphEndpoint = '{0}/{1}' -f $baseEndpoint, $ObjectId
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
            $errorException = '{0} : Unable to retrieve role definitions from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
    }
}