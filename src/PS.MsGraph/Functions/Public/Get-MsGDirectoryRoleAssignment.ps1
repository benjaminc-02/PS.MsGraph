function Get-MsGDirectoryRoleAssignment {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 1)][string]$ObjectId,
        [parameter(Mandatory = $false, Position = 2)][string]$DirectoryScopeId = '/',
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
        # Retrieve role definition.
        $params = @{
            'Headers'     = $Headers
            'ErrorAction' = 'Stop'
        }
        switch ($PSCmdlet.ParameterSetName) {
            "Name" { $params.Add('DisplayName', $DisplayName) }
            "ObjId" { $params.Add('ObjectId', $ObjectId) }
        }
        try {
            $roleDefinition = Get-MsGDirectoryRoleDefinition @params
            if ([string]::IsNullOrEmpty($roleDefinition)) {
                $errorMessage = 'Role definition not found.'
                throw $errorMessage
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve role definitions from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Retrieve role assignments
        try {
            $filterString = "roleDefinitionId eq '{0}' AND directoryScopeId eq '{1}'" -f $roleDefinition.id, $DirectoryScopeId
            $graphEndpoint = 'roleManagement/directory/roleAssignments?$filter={0}&$expand=principal' -f $filterString
            $irmResponse = Invoke-MsGRequest -Method Get -Endpoint $graphEndpoint -Version 'v1.0' -Headers $Headers -ErrorAction 'Stop'

            # Write out principal with relevant details
            foreach ($principalAssignment in $irmResponse) {
                $principal = $null
                $principal = $principalAssignment.principal
                $principal | Add-Member -MemberType NoteProperty -Name 'directoryScopeId' -Value $principalAssignment.directoryScopeId -Force
                $principal | Add-Member -MemberType NoteProperty -Name 'roleDefinitionId' -Value $principalAssignment.roleDefinitionId -Force
                $principal | Add-Member -MemberType NoteProperty -Name 'roleDefinitionName' -Value $roleDefinition.displayName -Force
                $principal | Add-Member -MemberType NoteProperty -Name 'roleAssignmentId' -Value $principalAssignment.id -Force
                Write-Output $principal
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve group members from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region
    }
}