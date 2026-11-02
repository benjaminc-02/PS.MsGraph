function New-MsGUser {
    <#
    .SYNOPSIS
    Creates new user in Entra ID.
    .DESCRIPTION
    This function will create a new user object in Entra ID.
    .PARAMETER UserPrincipalName
    The userPrincipalName of the new user.
    .PARAMETER Password
    The initial password of the new user.
    .PARAMETER AccountEnabled
    Whether the account is enabled on creation or not.
    .PARAMETER DisplayName
    DisplayName of the new user.
    .PARAMETER Mail
    Mail address of the new user.
    .PARAMETER MailNickname
    Mail nickname of the new user.
    .PARAMETER ForceChangePasswordNextSignIn
    Forces the password change on next sign in.
    .PARAMETER ForceChangePasswordNextSignInWithMfa
    Forces the password change on next sign in after multifactor authentication.
    .PARAMETER City
    City of the new user.
    .PARAMETER CompanyName
    Company name of the new user.
    .PARAMETER Country
    Country of the new user.
    .PARAMETER Department
    Department of the new user.
    .PARAMETER EmployeeID
    Employee ID of the new user.
    .PARAMETER EmployeeType
    Employee type of the new user.
    .PARAMETER GivenName
    GivenName of the new user.
    .PARAMETER JobTitle
    Job title of the new user.
    .PARAMETER OfficeLocation
    Office location of the new user.
    .PARAMETER PostalCode
    Postal Code of the new user.
    .PARAMETER State
    State of the new user.
    .PARAMETER StreetAddress
    Street address of the new user.
    .PARAMETER Surname
    Surname of the new user.
    .PARAMETER Headers
    Authentication Headers to connect to Microsoft Graph.
    .PARAMETER Jwt
    Jwt to connect to Microsoft Graph.
    .EXAMPLE
    PS> New-MsGUser -UserPrincipalName 'test_manager01@testdomain.local' -Password ('password123!' | ConvertTo-SecureString -AsPlainText -Force)

    This will create the 'test_manager01@testdomain.local' in the authenticated tenant.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $true, Position = 0)][string]$UserPrincipalName,
        [parameter(Mandatory = $true, Position = 1)][securestring]$Password,
        [parameter(Mandatory = $false)][bool]$AccountEnabled = $true,
        [parameter(Mandatory = $false)][string]$DisplayName = $UserPrincipalName,
        [parameter(Mandatory = $false)][Alias('EmailAddress')][string]$Mail = $UserPrincipalName,
        [parameter(Mandatory = $false)][string]$MailNickname = $Mail.Split('@')[0],
        [parameter(Mandatory = $false)][switch]$ForceChangePasswordNextSignIn,
        [parameter(Mandatory = $false)][switch]$ForceChangePasswordNextSignInWithMfa,
        [parameter(Mandatory = $false)][string]$City,
        [parameter(Mandatory = $false)][string]$CompanyName,
        [parameter(Mandatory = $false)][string]$Country,
        [parameter(Mandatory = $false)][string]$Department,
        [parameter(Mandatory = $false)][string]$EmployeeID,
        [parameter(Mandatory = $false)][ValidateSet('Employee', 'Contractor', 'Consultant', 'Vendor')][string]$EmployeeType,
        [parameter(Mandatory = $false)][string]$GivenName,
        [parameter(Mandatory = $false)][string]$JobTitle,
        [parameter(Mandatory = $false)][string]$OfficeLocation,
        [parameter(Mandatory = $false)][string]$PostalCode,
        [parameter(Mandatory = $false)][string]$State,
        [parameter(Mandatory = $false)][string]$StreetAddress,
        [parameter(Mandatory = $false)][string]$Surname,
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
        # Retrieve user password
        $dummyCredential = [pscredential]::new($UserPrincipalName, $Password)
        $plainTextPassword = $dummyCredential.GetNetworkCredential().Password
        $passwordProfile = @{
            'forceChangePasswordNextSignIn'        = $ForceChangePasswordNextSignIn.IsPresent
            'forceChangePasswordNextSignInWithMfa' = $ForceChangePasswordNextSignInWithMfa.IsPresent
            'password'                             = $plainTextPassword
        }
        # end region

        # Create user body
        $body = @{
            'accountEnabled'    = $AccountEnabled
            'displayName'       = $DisplayName
            'mailNickname'      = $MailNickname
            'passwordProfile'   = $passwordProfile
            'mail'              = $Mail
            'userPrincipalName' = $UserPrincipalName
        }
        # end region

        # Add City
        if ($PSBoundParameters.ContainsKey('City')) {
            $body.Add('city', $City)
        }
        # end region

        # Add CompanyName
        if ($PSBoundParameters.ContainsKey('CompanyName')) {
            $body.Add('companyName', $CompanyName)
        }
        # end region

        # Add Country
        if ($PSBoundParameters.ContainsKey('Country')) {
            $body.Add('country', $Country)
        }
        # end region

        # Add Department
        if ($PSBoundParameters.ContainsKey('Department')) {
            $body.Add('department', $Department)
        }
        # end region

        # Add EmployeeID
        if ($PSBoundParameters.ContainsKey('EmployeeID')) {
            $body.Add('employeeID', $EmployeeID)
        }
        # end region

        # Add EmployeeType
        if ($PSBoundParameters.ContainsKey('EmployeeType')) {
            $body.Add('employeeType', $EmployeeType)
        }
        # end region

        # Add GivenName
        if ($PSBoundParameters.ContainsKey('GivenName')) {
            $body.Add('givenName', $GivenName)
        }
        # end region

        # Add JobTitle
        if ($PSBoundParameters.ContainsKey('JobTitle')) {
            $body.Add('jobTitle', $JobTitle)
        }
        # end region

        # Add OfficeLocation
        if ($PSBoundParameters.ContainsKey('OfficeLocation')) {
            $body.Add('officeLocation', $OfficeLocation)
        }
        # end region

        # Add PostalCode
        if ($PSBoundParameters.ContainsKey('PostalCode')) {
            $body.Add('postalCode', $PostalCode)
        }
        # end region

        # Add State
        if ($PSBoundParameters.ContainsKey('State')) {
            $body.Add('state', $State)
        }
        # end region

        # Add StreetAddress
        if ($PSBoundParameters.ContainsKey('StreetAddress')) {
            $body.Add('streetAddress', $StreetAddress)
        }
        # end region

        # Add Surname
        if ($PSBoundParameters.ContainsKey('Surname')) {
            $body.Add('surname', $Surname)
        }
        # end region

        # Create new user
        if ($PSCmdlet.ShouldProcess($UserPrincipalName, 'Create User')) {
            try {
                Invoke-MsGRequest -Method Post -Endpoint 'users' -Body $body -Headers $Headers -ErrorAction 'Stop'
            }
            catch {
                $errorMessage = Get-MsGErrorMessage $_
                $errorException = '{0} : Unable to create a new user in Entra ID. Error: {1}' -f $MyInvocation.MyCommand.Name, $errorMessage
                throw $errorException
            }
        }
        else {
            Write-Verbose ($body | ConvertTo-Json -Depth 20)
        }
        # end region
    }
}