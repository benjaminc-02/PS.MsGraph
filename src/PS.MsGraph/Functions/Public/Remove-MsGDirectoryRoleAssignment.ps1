function Remove-MsGDirectoryRoleAssignment {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$RoleDefinitionName,
        [parameter(Mandatory = $true, ParameterSetName = 'Id', Position = 1)][string]$RoleDefinitionId,
        [parameter(Mandatory = $false, Position = 2)][string]$DirectoryScopeId = '/',
        [parameter(Mandatory = $false, Position = 3)][string[]]$UserPrincipalName,
        [parameter(Mandatory = $false, Position = 4)][string[]]$GroupName,
        [parameter(Mandatory = $false, Position = 5)][string[]]$DirectoryObjectId,
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
        # Retrieve role definition.
        try {
            switch ($PSCmdlet.ParameterSetName) {
                "Name" {
                    $specifiedException = "Unable to retrieve role definition name '{0}' from Entra ID." -f $RoleDefinitionName
                    $roleDefinition = Get-MsGDirectoryRoleDefinition -DisplayName $RoleDefinitionName @irmParams
                }
                "Id" {
                    $specifiedException = "Unable to retrieve role definition id '{0}' from Entra ID." -f $RoleDefinitionId
                    $roleDefinition = Get-MsGDirectoryRoleDefinition -ObjectId $RoleDefinitionId @irmParams
                }
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : {1} Error: {2}' -f $MyInvocation.MyCommand.Name, $specifiedException, $errorMessage
            throw $errorException
        }
        # end region

        # Retrieve IDs
        $memberIDs = New-Object -TypeName System.Collections.Generic.List[string]
        foreach ($UPN in $UserPrincipalName) {
            try {
                $userObject = Get-MsGUser -UserPrincipalName $UPN @irmParams
                $memberIDs.Add($userObject.id)
            }
            catch {
                $warningMessage = "{0} not found. Skipping user." -f $UPN
                Write-Warning $warningMessage
            }
        }
        foreach ($Group in $GroupName) {
            try {
                $groupObject = Get-MsGGroup -DisplayName $Group @irmParams
                if ($groupObject.isAssignableToRole) {
                    $memberIDs.Add($groupObject.id)
                }
                else {
                    $warningMessage = "{0} is not able to be assigned to roles. Skipping group." -f $Group
                    Write-Warning $warningMessage
                }
            }
            catch {
                $warningMessage = "{0} not found. Skipping group." -f $Group
                Write-Warning $warningMessage
            }
        }
        foreach ($dirObjId in $DirectoryObjectId) {
            try {
                $dirObject = Get-MsGDirectoryObject -Id $dirObjId @irmParams
                $memberIDs.Add($dirObject.id)
            }
            catch {
                $warningMessage = "{0} not found. Skipping id." -f $dirObjId
                Write-Warning $warningMessage
            }
        }
        if ($memberIDs.Count -lt 1) {
            $errorException = '{0} : No valid members were found.' -f $MyInvocation.MyCommand.Name
            throw $errorException
        }
        # end region

        # Retrieve current role assignments.
        try {
            $roleAssignments = Get-MsGDirectoryRoleAssignment -ObjectId $roleDefinition.id -DirectoryScopeId $DirectoryScopeId @irmParams
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = "{0} : Unable to retrieve role assignments for '{1}' role. Error: {2}" -f $MyInvocation.MyCommand.Name, $roleDefinition.displayName, $errorMessage
            throw $errorException
        }
        # end region

        # Compare Role Assignments
        $membersToRemove = New-Object -TypeName System.Collections.Generic.List[psobject]
        if ($roleAssignments.Count -gt 0) {
            $roleAssignments | Where-Object { $_.id -in $memberIDs } | ForEach-Object { $membersToRemove.Add($_) }
        }
        else {
            $errorException = '{0} : No users are assigned to {1}.' -f $MyInvocation.MyCommand.Name, $roleDefinition.displayName
            throw $errorException
        }
        # end region

        # Remove Role
        foreach ($member in $membersToRemove) {
            $endpoint = 'roleManagement/directory/roleAssignments/{0}' -f $member.roleAssignmentId
            $memberId = $member.id
            $memberDisplayName = $member.displayName
            if (($PSCmdlet.ShouldProcess(('{0} [{1}]' -f $memberDisplayName, $memberId), 'Remove Directory Role Assignment')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove $('{0} [{1}]' -f $memberDisplayName, $memberId) from the $($roleDefinition.displayName) role in Entra ID.", 'Are you sure you would like to proceed?')))) {
                try {
                    Invoke-MsGRequest -Method Delete -Endpoint $endpoint @irmParams > $null
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = "{0} : Unable to remove '{1}' role from {2} [{3}]. Error: {4}" -f $MyInvocation.MyCommand.Name, $roleDefinition.displayName, $memberDisplayName, $memberId, $errorMessage
                    throw $errorException
                }
            }
        }
        # end region
    }
}