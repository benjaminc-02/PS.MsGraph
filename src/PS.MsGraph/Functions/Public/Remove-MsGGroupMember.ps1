function Remove-MsGGroupMember {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 1)][string]$ObjectId,
        [parameter(Mandatory = $false, Position = 2)][string[]]$UserPrincipalName,
        [parameter(Mandatory = $false, Position = 3)][string[]]$DirectoryObjectId,
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

        # Retrieve Members
        try {
            $groupMembers = Get-MsGGroupMember -ObjectId $group.id @irmParams
            $memberIDsToRemove = $groupMembers | Where-Object { $_.userPrincipalName -in $UserPrincipalName -or $_.id -in $DirectoryObjectId } | Select-Object -ExpandProperty id
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to validate group members from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Remove Members
        foreach ($memberId in $memberIDsToRemove) {
            if (($PSCmdlet.ShouldProcess($memberId, 'Remove Group Member')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove '$memberId' as an member from '$($group.displayName)'.", 'Are you sure you would like to proceed?')))) {
                $memberEndpoint = 'groups/{0}/members/{1}/$ref' -f $group.id, $memberId
                try {
                    Invoke-MsGRequest -Method Delete -Endpoint $memberEndpoint -Body $body @irmParams > $null
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = 'Unable to remove {0} as an member from the group. Error: {1}' -f $memberId, $errorMessage
                    Write-Error $errorException
                    continue
                }
            }
        }
        # end region
    }
}