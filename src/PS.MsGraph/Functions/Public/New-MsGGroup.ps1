function New-MsGGroup {
    <#
    .SYNOPSIS
    Creates new group in Entra ID.
    .DESCRIPTION
    This function allows you to create new groups in Entra ID. By default groups are Security-Enabled unless stated otherwise.
    .PARAMETER DisplayName
    DisplayName of the group to create.
    .PARAMETER Description
    Description of the group to create.
    .PARAMETER MailEnabled
    Determines whether the group is mail-enabled or not.
    .PARAMETER EmailAddress
    Email address of the group to create.
    .PARAMETER MailNickname
    Mail nickname of the group to create.
    .PARAMETER IsAssignableToRole
    Determines if the group is assignable to a role.
    .PARAMETER MembershipRule
    Membership rule for dynamic group.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> New-MsGGroup -DisplayName FinanceAdmins -Description "Group for admins in the Finance department."

    Creates a Security-Enabled group in Entra ID.
    .EXAMPLE
    PS> New-MsGGroup -DisplayName FinanceMembers -Description "Members of the Finance department." -MembershipRule "(user.department eq 'Finance')"

    Creates a Security-Enabled group in Entra ID that is dynamically populated with users whose Department is 'Finance'.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Security')]
    param(
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Security')]
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'M365')]
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Dynamic')]
        [string]$DisplayName,
        [parameter(Mandatory = $false, Position = 1, ParameterSetName = 'Security')]
        [parameter(Mandatory = $false, Position = 1, ParameterSetName = 'M365')]
        [parameter(Mandatory = $false, Position = 1, ParameterSetName = 'Dynamic')]
        [string]$Description,
        [parameter(Mandatory = $false, ParameterSetName = 'Security')][switch]$IsAssignableToRole,
        [parameter(Mandatory = $true, ParameterSetName = 'M365')][switch]$MailEnabled,
        [parameter(Mandatory = $false, ParameterSetName = 'M365')][string]$EmailAddress,
        [parameter(Mandatory = $false, ParameterSetName = 'M365')][string]$MailNickname,
        [parameter(Mandatory = $false, ParameterSetName = 'Dynamic')][string]$MembershipRule,
        [parameter(Mandatory = $false, ParameterSetName = 'Security')]
        [parameter(Mandatory = $false, ParameterSetName = 'M365')]
        [parameter(Mandatory = $false, ParameterSetName = 'Dynamic')]
        [hashtable]$Headers,
        [parameter(Mandatory = $false, ParameterSetName = 'Security')]
        [parameter(Mandatory = $false, ParameterSetName = 'M365')]
        [parameter(Mandatory = $false, ParameterSetName = 'Dynamic')]
        [string]$Jwt
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
        # Create Body
        $body = @{
            'displayName' = $DisplayName
            'description' = $Description
            'mailEnabled' = $MailEnabled.IsPresent
        }
        if ($PSBoundParameters.ContainsKey('MailNickname')) {
            $body.Add('mailNickname', $MailNickname)
        }
        else {
            $body.Add('mailNickname', $DisplayName)
        }
        switch ($PSCmdlet.ParameterSetName) {
            "Security" {
                $body.Add('securityEnabled', $true)
                if ($PSBoundParameters.ContainsKey('IsAssignableToRole')) {
                    $body.Add('isAssignableToRole', $true)
                }
            }
            "M365" {
                $body.Add('securityEnabled', $false)
                $body.Add('groupTypes', [string[]]@('Unified'))
                if ($PSBoundParameters.ContainsKey('EmailAddress')) {
                    $body.Add('mail', $EmailAddress)
                }
            }
            "Dynamic" {
                $body.Add('securityEnabled', $true)
                $body.Add('groupTypes', [string[]]@('DynamicMembership'))
                $body.Add('membershipRule', $MembershipRule)
                $body.Add('membershipRuleProcessingState', 'On')
            }
        }
        Write-Verbose ($body | ConvertTo-Json -Depth 20)
        # end region

        # Format body
        $bodyParams = @{
            'Method'      = 'Post'
            'Endpoint'    = 'groups'
            'Headers'     = $Headers
            'ErrorAction' = 'Stop'
            'Body'        = $body
        }
        # end region

        # Create Group
        if ($PSCmdlet.ShouldProcess($DisplayName, 'New Group')) {
            try {
                $irmResponse = Invoke-MsGRequest @bodyParams
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to create new group in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
            Write-Output $irmResponse
        }
        # end region
    }
}