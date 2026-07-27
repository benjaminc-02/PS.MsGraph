---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Get-MsGAccessToken

## SYNOPSIS
Retrieves an access token from the specified Entra ID resource.

## SYNTAX

### UserAccount (Default)
```
Get-MsGAccessToken [-ResourceName <String>] [-Scopes <String[]>] [-ResourceUrl <String>] -TenantId <String>
 [-AsHeaders] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ClientSecretCredential
```
Get-MsGAccessToken -ServicePrincipalCredential <PSCredential> [-ResourceName <String>] [-ResourceUrl <String>]
 -TenantId <String> [-AsHeaders] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Certificate
```
Get-MsGAccessToken -ClientId <String> -Thumbprint <String> [-CertificateStore <String>]
 [-ResourceName <String>] [-ResourceUrl <String>] -TenantId <String> [-AsHeaders]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ClientSecret
```
Get-MsGAccessToken -ClientId <String> -ClientSecret <String> [-ResourceName <String>] [-ResourceUrl <String>]
 -TenantId <String> [-AsHeaders] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This functions retrieves an access token from Entra ID for a specified resource using a given authentication mechanism.
This can be used for user-based interactive authentication or for principal-based non-interactive authentication.

## EXAMPLES

### EXAMPLE 1
```
Get-MsGAccessToken -TenantId testdomain.onmicrosoft.com
```

Triggers an interactive user sign-in through MSAL to authenticate to Entra ID and retrieve a jwt.

### EXAMPLE 2
```
Get-MsGAccessToken -TenantId testdomain.onmicrosoft.com -ServicePrincipalCredential $AppCredential
```

Authenticates to Entra ID using the Client Id and Secret Credential from $AppCredential.

### EXAMPLE 3
```
Get-MsGAccessToken -TenantId testdomain.onmicrosoft.com -ClientId aeca5cf4-4738-4e32-b0d9-030d9b5b4297 -ClientSecret -gx8Q~_H1GPUygPDGJl4D.otjdReVx-x0KnvnaGF
```

Authenticates to Entra ID using the provided client id and secret.

### EXAMPLE 4
```
Get-MsGAccessToken -TenantId testdomain.onmicrosoft.com -ClientId aeca5cf4-4738-4e32-b0d9-030d9b5b4297 -Thumbprint 'A909502DD82AE41433E6F83886B00D4277A32A7B' -CertificateStore 'CurrentUser'
```

Authenticates to Entra ID using the provided client id and certificate from the current user store with the "A909502DD82AE41433E6F83886B00D4277A32A7B" thumbprint.

## PARAMETERS

### -ServicePrincipalCredential
Credential object containing client id and secret for service principal.

```yaml
Type: PSCredential
Parameter Sets: ClientSecretCredential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
Client id of service principal to authenticate to.

```yaml
Type: String
Parameter Sets: Certificate, ClientSecret
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
Client secret of service principal to authenticate to.

```yaml
Type: String
Parameter Sets: ClientSecret
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Thumbprint
Thumbprint of private key certificate in specified certificate store tied to an app registration to authenticate to.

```yaml
Type: String
Parameter Sets: Certificate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateStore
Certificate store holding the private key certificate to authenticate with.

```yaml
Type: String
Parameter Sets: Certificate
Aliases:

Required: False
Position: Named
Default value: CurrentUser
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceName
Name of the resource to authenticate to Entra ID for.
Maps to resource url in the function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Graph
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scopes
Scopes to authenticate to the resource for.

```yaml
Type: String[]
Parameter Sets: UserAccount
Aliases:

Required: False
Position: Named
Default value: User.Read
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceUrl
Url of the resource to authenticate to Entra ID for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Https://graph.microsoft.com
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
Id/name of the tenant to authenticate to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsHeaders
Returns the token as headers instead of as a Jwt.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
