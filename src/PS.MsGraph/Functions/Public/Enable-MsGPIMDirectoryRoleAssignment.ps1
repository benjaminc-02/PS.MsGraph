function Enable-MsGPIMDirectoryRoleAssignment {
    <#
    .SYNOPSIS
    Actives self PIM role assignment for a specified role.
    .DESCRIPTION
    This function activates a self PIM role assignemnt for a given role for the signed-in user. The justification and timeframe can be provided.
    .PARAMETER RoleDefinitionName
    Name of the role.
    .PARAMETER RoleDefinitionId
    Id of the role.
    .PARAMETER Justification
    Justification for elevating access.
    .PARAMETER Hours
    Timeframe that the assignment is active for.
    .PARAMETER DirectoryScopeId
    Scope id for where to activate the assignment.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> Enable-MsGPIMDirectoryRoleAssignment -RoleDefinitionName 'Global Administrator' -Justification 'Updating conditional access.'

    Activates the 'Global Administrator' role for the signed in user to perform the specified actions.
    #>
    [CmdletBinding()]
    [Alias('epim')]
    param(
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Name')][string]$RoleDefinitionName,
        [parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Id')][string]$RoleDefinitionId,
        [parameter(Mandatory = $true, Position = 2)][string]$Justification,
        [parameter(Mandatory = $false, Position = 3)][ValidateRange(1, 8)][int]$Hours = 1,
        [parameter(Mandatory = $false, Position = 4)][string]$DirectoryScopeId = '/',
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
            'ErrorAction' = 'Stop'
            'Headers'     = $Headers
        }
        # end Session Checks
    }
    PROCESS {
        # Retrieve Current User
        try {
            $currentUser = Invoke-MsGRequest -Method 'Get' -Endpoint 'me' @irmParams
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Failed to retrieve current user. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }

        # Retrieve Role Definition
        $baseRoleDefEndpoint = 'roleManagement/directory/roleDefinitions'
        try {
            switch ($PSCmdlet.ParameterSetName) {
                "Name" {
                    $roleDefEndpoint = "{0}?`$filter=displayName eq '{1}'" -f $baseRoleDefEndpoint, $RoleDefinitionName
                    $retrieveErrorMessage = 'Unable to retrieve role definition with DisplayName {0} from Entra ID.' -f $RoleDefinitionName
                    $roleDefinitionObject = Invoke-MsGRequest -Method Get -Endpoint $roleDefEndpoint @irmParams
                }
                "Id" {
                    $roleDefEndpoint = "{0}/{1}" -f $baseRoleDefEndpoint, $RoleDefinitionName
                    $retrieveErrorMessage = 'Unable to retrieve role definition with Id {0} from Entra ID.' -f $RoleDefinitionId
                    $roleDefinitionObject = Invoke-MsGRequest -Method Get -Endpoint $roleDefEndpoint @irmParams
                }
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : {1}. Error: {2}' -f $MyInvocation.MyCommand.Name, $retrieveErrorMessage, $errorMessage
            throw $errorException
        }

        # Enable PIM Assignment
        try {
            $roleAssignmentEndpoint = 'roleManagement/directory/roleAssignmentScheduleRequests'
            $body = @{
                'action'           = 'selfActivate'
                'principalId'      = $currentUser.id
                'roleDefinitionId' = $roleDefinitionObject.id
                'directoryScopeId' = $DirectoryScopeId
                'justification'    = $Justification
                'scheduleInfo'     = @{
                    'startDateTime' = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'
                    'expiration'    = @{
                        'type'     = 'afterDuration'
                        'duration' = 'PT{0}H' -f $Hours
                    }
                }
            }
            Invoke-MsGRequest -Method Post -Endpoint $roleAssignmentEndpoint -Body $body @irmParams
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Failed to elevate access. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
    }
}