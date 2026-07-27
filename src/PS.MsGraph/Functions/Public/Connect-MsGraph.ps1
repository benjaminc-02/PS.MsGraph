function Connect-MsGraph {
    <#
    .SYNOPSIS
    Retrieves an access token from the specified Entra ID resource and sets it as a session variable.
    .DESCRIPTION
    This functions retrieves an access token from Entra ID for a specified resource using a given authentication mechanism and sets it as a session variable to be used in the functions tied to this module. This can be used for user-based interactive authentication or for principal-based non-interactive authentication.
    .PARAMETER ServicePrincipalCredential
    Credential object containing client id and secret for service principal.
    .PARAMETER ClientId
    Client id of service principal to authenticate to.
    .PARAMETER ClientSecret
    Client secret of service principal to authenticate to.
    .PARAMETER Thumbprint
    Thumbprint of private key certificate in specified certificate store tied to an app registration to authenticate to.
    .PARAMETER CertificateStore
    Certificate store holding the private key certificate to authenticate with.
    .PARAMETER ResourceName
    Name of the resource to authenticate to Entra ID for. Maps to resource url in the function.
    .PARAMETER Scopes
    Scopes to authenticate to the resource for.
    .PARAMETER ResourceUrl
    Url of the resource to authenticate to Entra ID for.
    .PARAMETER TenantId
    Id/name of the tenant to authenticate to.
    .EXAMPLE
    PS> Connect-MsGraph -TenantId testdomain.onmicrosoft.com

    Triggers an interactive user sign-in through MSAL to authenticate to Entra ID and retrieve a jwt.
    .EXAMPLE
    PS> Connect-MsGraph -TenantId testdomain.onmicrosoft.com -ServicePrincipalCredential $AppCredential

    Authenticates to Entra ID using the Client Id and Secret Credential from $AppCredential.
    .EXAMPLE
    PS> Connect-MsGraph -TenantId testdomain.onmicrosoft.com -ClientId aeca5cf4-4738-4e32-b0d9-030d9b5b4297 -ClientSecret -gx8Q~_H1GPUygPDGJl4D.otjdReVx-x0KnvnaGF

    Authenticates to Entra ID using the provided client id and secret.
    .EXAMPLE
    PS> Connect-MsGraph -TenantId testdomain.onmicrosoft.com -ClientId aeca5cf4-4738-4e32-b0d9-030d9b5b4297 -Thumbprint 'A909502DD82AE41433E6F83886B00D4277A32A7B' -CertificateStore 'CurrentUser'

    Authenticates to Entra ID using the provided client id and certificate from the current user store with the "A909502DD82AE41433E6F83886B00D4277A32A7B" thumbprint.
    #>
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
        [parameter(Mandatory = $true)][string]$TenantId
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