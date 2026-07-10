function Add-MsGServicePrincipalOwner {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$DisplayName,
        [parameter(Mandatory = $true, ParameterSetName = 'AppId', Position = 1)][string]$AppId,
        [parameter(Mandatory = $true, ParameterSetName = 'ObjId', Position = 2)][string]$ObjectId,
        [parameter(Mandatory = $false, Position = 3)][string[]]$UserPrincipalName,
        [parameter(Mandatory = $false, Position = 4)][string[]]$DirectoryObjectId,
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
                'Content-Type'  = 'servicePrincipal/json'
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

        # Retrieve ServicePrincipal from Entra ID
        try {
            switch ($PSCmdlet.ParameterSetName) {
                "Name" {
                    $appEndpoint = "servicePrincipals?`$filter=displayName eq '{0}'" -f $DisplayName
                }
                "AppId" {
                    $appEndpoint = "servicePrincipals?`$filter=appId eq '{0}'" -f $AppId
                }
                "ObjId" {
                    $appEndpoint = "servicePrincipals/{0}" -f $ObjectId
                }
            }
            $servicePrincipal = Invoke-MsGRequest -Method Get -Endpoint $appEndpoint @irmParams
            if ([string]::IsNullOrEmpty($servicePrincipal)) {
                $errorMessage = 'Service Principal not found.'
                throw $errorMessage
            }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve service principal from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Compare Owners
        try {
            $ownerIDsToAdd = New-Object -TypeName System.Collections.Generic.List[string]
            $servicePrincipalOwners = Get-MsGServicePrincipalOwner -ObjectId $servicePrincipal.id @irmParams
            $ownerIDs | Where-Object { $_ -notin $servicePrincipalOwners.id } | ForEach-Object { $ownerIDsToAdd.Add($_) }
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to validate service principal owners from Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
        # end region

        # Add Owners
        $ownerEndpoint = 'servicePrincipals/{0}/owners/$ref' -f $servicePrincipal.id
        foreach ($ownerId in $ownerIDsToAdd) {
            if ($PSCmdlet.ShouldProcess($servicePrincipal.displayName, 'Add Service Principal Owner')) {
                $body = @{'@odata.id' = 'https://graph.microsoft.com/v1.0/directoryObjects/{0}' -f $ownerId }
                try {
                    Invoke-MsGRequest -Method Post -Endpoint $ownerEndpoint -Body $body @irmParams > $null
                }
                catch {
                    $errorMessage = Get-MsGErrorMessage $_
                    $errorException = 'Unable to add {0} as an owner to the service principal. Error: {1}' -f $ownerId, $errorMessage
                    Write-Error $errorException
                    continue
                }
            }
        }
        # end region
    }
}