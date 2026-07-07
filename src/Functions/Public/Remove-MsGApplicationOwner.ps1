function Remove-MsGApplicationOwner {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
        [parameter(Mandatory = $false, Position = 3)][string[]]$UserPrincipalName,
        [parameter(Mandatory = $false, Position = 4)][string[]]$DirectoryObjectId,
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
        # Retrieve Application from Entra ID
        try {
            switch ($PSCmdlet.ParameterSetName) {
                "Name" {
                    $appEndpoint = "applications?`$filter=displayName eq '{0}'" -f $DisplayName
                }
                "AppId" {
                    $appEndpoint = "applications?`$filter=appId eq '{0}'" -f $AppId
                }
                "ObjId" {
                    $appEndpoint = "applications/{0}" -f $ObjectId
                }
            }
            $application = Invoke-MsGRequest -Method Get -Endpoint $appEndpoint @irmParams
            if ([string]::IsNullOrEmpty($application)) {
                $errorMessage = 'Application not found.'
                throw $errorMessage
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve application from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Retrieve Owners
        try {
            $applicationOwners = Get-MsGApplicationOwner -ObjectId $application.id @irmParams
            $ownerIDsToRemove = $applicationOwners | Where-Object { $_.userPrincipalName -in $UserPrincipalName -or $_.id -in $DirectoryObjectId } | Select-Object -ExpandProperty id
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to validate application owners from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Remove Owners
        foreach ($ownerId in $ownerIDsToRemove) {
            if (($PSCmdlet.ShouldProcess($ownerId, 'Remove Application Owner')) -and ($Force.IsPresent -or ($PSCmdlet.ShouldContinue("Remove '$ownerId' as an owner from '$($application.displayName)'.", 'Are you sure you would like to proceed?')))) {
                $appOwnerEndpoint = 'applications/{0}/owners/{1}/$ref' -f $application.id, $ownerId
                try {
                    Invoke-MsGRequest -Method Delete -Endpoint $appOwnerEndpoint -Body $body @irmParams > $null
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = 'Unable to remove {0} as an owner from the application. Error: {1}' -f $ownerId, $errorMessage
                    Write-Error $errorException
                    continue
                }
            }
        }
        # end region
    }
}