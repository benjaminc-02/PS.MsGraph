function Add-MsGGroupMember {
    <#
    .SYNOPSIS
    Adds a member to a group in Entra ID.
    .DESCRIPTION
    This function adds a specified member to the group in Entra ID.
    .PARAMETER DisplayName
    Display Name of the group.
    .PARAMETER ObjectId
    Object Id of the group.
    .PARAMETER UserPrincipalName
    The UserPrincipalName of the user to add as a member to the group.
    .PARAMETER DirectoryObjectId
    The Directory Object Id of the principal to add as a member to the group.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Add-MsGGroupMember -DisplayName TestGroup -UserPrincipalName benjamin.cohn@testdomain.com

    Adds the specified user as a member to the group.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 1)][string]$ObjectId,
        [parameter(Mandatory = $false, Position = 2)][string[]]$UserPrincipalName,
        [parameter(Mandatory = $false, Position = 3)][string[]]$DirectoryObjectId,
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
        # Retrieve IDs
        $MemberIDs = New-Object -TypeName System.Collections.Generic.List[string]
        foreach ($UPN in $UserPrincipalName) {
            try {
                $userObject = Get-MsGUser -UserPrincipalName $UPN @irmParams
                $MemberIDs.Add($userObject.id)
            }
            catch {
                $warningMessage = "{0} not found. Skipping user." -f $UPN
                Write-Warning $warningMessage
            }
        }
        foreach ($dirObjId in $DirectoryObjectId) {
            try {
                $dirObject = Get-MsGDirectoryObject -Id $dirObjId @irmParams
                $MemberIDs.Add($dirObject.id)
            }
            catch {
                $warningMessage = "{0} not found. Skipping id." -f $dirObjId
                Write-Warning $warningMessage
            }
        }
        if ($MemberIDs.Count -lt 1) {
            $errorException = '{0} : No valid Members were found.' -f $MyInvocation.MyCommand.Name
            throw $errorException
        }
        # end region

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

        # Compare Members
        try {
            $MemberIDsToAdd = New-Object -TypeName System.Collections.Generic.List[string]
            $groupMembers = Get-MsGGroupMember -ObjectId $group.id @irmParams
            $MemberIDs | Where-Object { $_ -notin $groupMembers.id } | ForEach-Object { $MemberIDsToAdd.Add($_) }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to validate group Members from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Add Members
        $MemberEndpoint = 'groups/{0}/members/$ref' -f $group.id
        foreach ($MemberId in $MemberIDsToAdd) {
            if ($PSCmdlet.ShouldProcess($group.displayName, 'Add Group Member')) {
                $body = @{'@odata.id' = 'https://graph.microsoft.com/v1.0/directoryObjects/{0}' -f $MemberId }
                try {
                    Invoke-MsGRequest -Method Post -Endpoint $MemberEndpoint -Body $body @irmParams > $null
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = 'Unable to add {0} as a member to the group. Error: {1}' -f $MemberId, $errorMessage
                    Write-Error $errorException
                    continue
                }
            }
        }
        # end region
    }
}