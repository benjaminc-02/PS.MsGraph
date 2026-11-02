function Remove-MsGGroup {
    <#
    .SYNOPSIS
    Removes a group from Entra ID.
    .DESCRIPTION
    This function removes a specified group from Entra ID.
    .PARAMETER DisplayName
    Display Name of the group.
    .PARAMETER ObjectId
    Object Id of the group.
    .PARAMETER Force
    Bypasses the confirmation check.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Remove-MsGGroup -DisplayName FinanceTeam -Force

    Removes the "FinanceTeam" group from Entra ID.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 1)][string]$ObjectId,
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

        $irmParams = @{
            'Headers'     = $Headers
            'ErrorAction' = 'Stop'
        }
        # end Session Checks
    }
    PROCESS {
        # Retrieve group from Entra ID
        try {
            switch ($PSCmdlet.ParameterSetName) {
                "Name" {
                    $groupEndpoint = "groups?`$filter=displayName eq '{0}'" -f $DisplayName
                }
                "ObjId" {
                    $groupEndpoint = "groups/{0}" -f $ObjectId
                }
            }
            $group = Invoke-MsGRequest -Method Get -Endpoint $groupEndpoint @irmParams
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

        # Remove group
        if (($PSCmdlet.ShouldProcess($group.displayName, 'Remove Group')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove the group '$($group.displayName)' from Entra ID.", 'Are you sure you want to proceed?')))) {
            try {
                $endpoint = 'groups/{0}' -f $group.id
                Invoke-MsGRequest -Method Delete -Endpoint $endpoint @irmParams > $null
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to remove group from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
        }
        # end region
    }
}