function Connect-MsGraph {
    [CmdletBinding()]
    [Alias('csmg')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'ClientSecretCredential')]
        [pscredential]$ServicePrincipalCredential,

        [parameter(Mandatory = $true, ParameterSetName = 'ClientSecret')]
        [parameter(Mandatory = $true, ParameterSetName = 'Certificate')]
        [string]$ClientId,

        [parameter(Mandatory = $true, ParameterSetName = 'ClientSecret')]
        [string]$ClientSecret,

        [parameter(Mandatory = $true, ParameterSetName = 'Certificate')]
        [string]$Thumbprint,

        [parameter(Mandatory = $false, ParameterSetName = 'Certificate')]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$CertificateStore = 'CurrentUser',

        [parameter(Mandatory = $false)]
        [ValidateSet('Graph', 'DevOps', 'Keyvault', 'Management')]
        [string]$ResourceName,

        [parameter(Mandatory = $false, ParameterSetName = 'UserAccount')]
        [string[]]$Scopes = ('User.Read'),

        [parameter(Mandatory = $false)][string]$ResourceUrl = 'https://graph.microsoft.com',
        [parameter(Mandatory = $true)][string]$TenantId,
        [parameter(Mandatory = $false)][switch]$AsHeaders
    )
    BEGIN {
        # Retrieve ResourceUrl if not present.
        if ($PSBoundParameters.ContainsKey('ResourceName') -eq $true) {
            $resourceUrlTable = @{
                'Graph'      = 'https://graph.microsoft.com/'
                'DevOps'     = '499b84ac-1321-427f-aa17-267ca6975798'
                'Keyvault'   = 'https://vault.azure.net/'
                'Management' = 'https://management.azure.com/'
            }
            $ResourceUrl = $resourceUrlTable[$ResourceName]
            $sessionName = 'my{0}Token' -f $ResourceName
        }
        else {
            $sessionName = 'myGraphToken'
        }
        # end region
    }
    PROCESS {
        try {
            $JwtToken = Get-MsGAccessToken @PSBoundParameters
            New-Variable -Name $sessionName -Value $JwtToken -Scope Global -Force -ErrorAction 'Stop'
        }
        catch {
            $errorMessage = Get-MsGErrorMessage $_
            $errorException = '{0} : Unable to retrieve jwt. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
            throw $errorException
        }
    }
}