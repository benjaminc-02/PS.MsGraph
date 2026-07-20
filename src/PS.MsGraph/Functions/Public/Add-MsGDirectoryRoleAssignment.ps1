function Add-MsGDirectoryRoleAssignment {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS>
    #>
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

        $displayNameTable = @{}
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
                if ($displayNameTable.Keys -notcontains $userObject.id) {
                    $displayNameTable.Add($userObject.id, $userObject.displayName)
                }
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
                if ($displayNameTable.Keys -notcontains $groupObject.id) {
                    $displayNameTable.Add($groupObject.id, $groupObject.displayName)
                }
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
                if ($displayNameTable.Keys -notcontains $dirObject.id) {
                    $displayNameTable.Add($dirObject.id, $dirObject.displayName)
                }
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
            $roleAssignments = Get-MsGDirectoryRoleAssignment -ObjectId $roleDefinition.id @irmParams
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = "{0} : Unable to retrieve role assignments for '{1}' role. Error: {2}" -f $MyInvocation.MyCommand.Name, $roleDefinition.displayName, $errorMessage
            throw $errorException
        }
        # end region

        # Compare Role Assignments
        $membersToAdd = New-Object -TypeName System.Collections.Generic.List[string]
        if ($roleAssignments.Count -gt 0) {
            $comparison = $roleAssignments.id | Compare-Object -ReferenceObject $memberIDs
            $comparison | Where-Object { $_.SideIndicator -eq '<=' } | ForEach-Object { $membersToAdd.Add($_.InputObject) }
        }
        else {
            $memberIDs | ForEach-Object { $membersToAdd.Add($_) }
        }
        # end region

        # Assign Role
        $endpoint = 'roleManagement/directory/roleAssignments'
        foreach ($memberId in $membersToAdd) {
            $memberDisplayName = $displayNameTable[$memberId]
            $body = @{
                '@odata.type'      = '#microsoft.graph.unifiedRoleAssignment'
                'roleDefinitionId' = $roleDefinition.id
                'principalId'      = $memberId
                'directoryScopeId' = $DirectoryScopeId
            }
            if ($PSCmdlet.ShouldProcess(('{0} [{1}]' -f $memberDisplayName, $memberId), "Add Directory Role Assignment")) {
                try {
                    Invoke-MsGRequest -Method Post -Endpoint $endpoint -Body $body @irmParams
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = "{0} : Unable to assign '{1}' role to {2} [{3}]. Error: {4}" -f $MyInvocation.MyCommand.Name, $roleDefinition.displayName, $memberDisplayName, $memberId, $errorMessage
                    throw $errorException
                }
            }
        }
        # end region
    }
}