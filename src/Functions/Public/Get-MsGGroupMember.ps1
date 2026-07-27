function Get-MsGGroupMember {
    <#
    .SYNOPSIS
    Retrieves members of a group.
    .DESCRIPTION
    This function retrieves the members of a specified group.
    .PARAMETER DisplayName
    DisplayName of the group.
    .PARAMETER ObjectId
    ObjectId of the group.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 1)][string]$ObjectId,
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
        # Retrieve group from Entra ID
        try {
            $group = Get-MsGGroup @PSBoundParameters
            if ([string]::IsNullOrEmpty($group)) {
                $errorMessage = 'Group not found.'
                throw $errorMessage
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve group from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Retrieve group members for group.
        try {
            $graphEndpoint = 'groups/{0}/members' -f $group.id
            $irmResponse = Invoke-MsGRequest -Method Get -Endpoint $graphEndpoint -Version 'v1.0' -Headers $Headers -ErrorAction 'Stop'
            Write-Output $irmResponse
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve group members from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region
    }
}