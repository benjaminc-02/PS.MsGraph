function Add-MsGGroupOwner {
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
        $ownerIDs = New-Object -TypeName System.Collections.Generic.List[string]
        foreach ($UPN in $UserPrincipalName) {
            try {
                $userObject = Get-MsGUser -UserPrincipalName $UPN @irmParams
                $ownerIDs.Add($userObject.id)
            }
            catch {
                $warningMessage = "{0} not found. Skipping user." -f $UPN
                Write-Warning $warningMessage
            }
        }
        foreach ($dirObjId in $DirectoryObjectId) {
            try {
                $dirObject = Get-MsGDirectoryObject -Id $dirObjId @irmParams
                $ownerIDs.Add($dirObject.id)
            }
            catch {
                $warningMessage = "{0} not found. Skipping id." -f $dirObjId
                Write-Warning $warningMessage
            }
        }
        if ($ownerIDs.Count -lt 1) {
            $errorException = '{0} : No valid owners were found.' -f $MyInvocation.MyCommand.Name
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

        # Compare Owners
        try {
            $ownerIDsToAdd = New-Object -TypeName System.Collections.Generic.List[string]
            $groupOwners = Get-MsGGroupOwner -ObjectId $group.id @irmParams
            $ownerIDs | Where-Object { $_ -notin $groupOwners.id } | ForEach-Object { $ownerIDsToAdd.Add($_) }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to validate group owners from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Add Owners
        $ownerEndpoint = 'groups/{0}/owners/$ref' -f $group.id
        foreach ($ownerId in $ownerIDsToAdd) {
            if ($PSCmdlet.ShouldProcess($group.displayName, 'Add Group Owner')) {
                $body = @{'@odata.id' = 'https://graph.microsoft.com/v1.0/directoryObjects/{0}' -f $ownerId }
                try {
                    Invoke-MsGRequest -Method Post -Endpoint $ownerEndpoint -Body $body @irmParams > $null
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = 'Unable to add {0} as an owner to the group. Error: {1}' -f $ownerId, $errorMessage
                    Write-Error $errorException
                    continue
                }
            }
        }
        # end region
    }
}