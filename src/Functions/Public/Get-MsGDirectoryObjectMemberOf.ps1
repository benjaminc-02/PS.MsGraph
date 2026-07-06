function Get-MsGDirectoryObjectMemberOf {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][Alias('ObjectId')][string]$Id,
        [parameter(Mandatory = $false, Position = 1)][bool]$SecurityEnabledOnly = $true,
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
        # Retrieve directory object.
        try {
            $directoryObject = Get-MsGDirectoryObject -Id $Id @irmParams
            if ([string]::IsNullOrEmpty($directoryObject)) {
                $errorMessage = 'Directory object not found.'
                throw $errorMessage
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve directory object from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Retrieve group memberships of directory object.
        try {
            $graphEndpoint = 'directoryObjects/{0}/getMemberGroups' -f $directoryObject.id
            $irmResponse = Invoke-MsGRequest -Method Post -Endpoint $graphEndpoint -Body @{'securityEnabledOnly' = $SecurityEnabledOnly } -Version 'v1.0' @irmParams
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve directory object group ids from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Retrieve groups from the IDs.
        foreach ($groupId in $irmResponse.value) {
            $groupObj = $null
            try {
                $groupObj = Get-MsGGroup -ObjectId $groupId @irmParams
                Write-Output $groupObj
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                Write-Warning $errorMessage
                continue
            }
        }
        # end region
    }
}