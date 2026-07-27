---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Add-MsGApplicationFederatedCredential

## SYNOPSIS
Adds a specified federated credential to an app registration in Entra ID.

## SYNTAX

### Name-ClaimsMatch
```
Add-MsGApplicationFederatedCredential [-DisplayName] <String> [-FCName] <String> [-Issuer] <String>
 [-ClaimsMatchingExpression] <String> [-Audience <String[]>] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Name-Subject
```
Add-MsGApplicationFederatedCredential [-DisplayName] <String> [-FCName] <String> [-Issuer] <String>
 [-Subject] <String> [-Audience <String[]>] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AppId-ClaimsMatch
```
Add-MsGApplicationFederatedCredential [-AppId] <String> [-FCName] <String> [-Issuer] <String>
 [-ClaimsMatchingExpression] <String> [-Audience <String[]>] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AppId-Subject
```
Add-MsGApplicationFederatedCredential [-AppId] <String> [-FCName] <String> [-Issuer] <String>
 [-Subject] <String> [-Audience <String[]>] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ObjId-ClaimsMatch
```
Add-MsGApplicationFederatedCredential [-ObjectId] <String> [-FCName] <String> [-Issuer] <String>
 [-ClaimsMatchingExpression] <String> [-Audience <String[]>] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ObjId-Subject
```
Add-MsGApplicationFederatedCredential [-ObjectId] <String> [-FCName] <String> [-Issuer] <String>
 [-Subject] <String> [-Audience <String[]>] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function adds a specified federated identity credential to an app registration in Entra ID, allowing for external OIDC identity providers to authentication to the application.

## EXAMPLES

### EXAMPLE 1
```
Add-MsGApplicationFederatedCredential -DisplayName TestApp-01 -FCName FlexCred-Test -Issuer https://app.terraform.io -Subject 'organization:test-org:project:test-proj:workspace:test-workspace:run_phase:plan'
```

Adds the specified federated identity credential for the specified issuer and subject.

## PARAMETERS

### -DisplayName
Display Name of the app registration.

```yaml
Type: String
Parameter Sets: Name-ClaimsMatch, Name-Subject
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -AppId
App/Client Id of the app registration.

```yaml
Type: String
Parameter Sets: AppId-ClaimsMatch, AppId-Subject
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ObjectId
Object Id of the app registration.

```yaml
Type: String
Parameter Sets: ObjId-ClaimsMatch, ObjId-Subject
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FCName
Name of the federated credential.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FederatedCredentialName, FedCredName

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Issuer
The URL of the external identity provider.
Must match the issuer claim of the external token being exchanged.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subject
The identifier of the external software workload within the external identity provider.
Like the audience value, it has no fixed format, as each IdP uses their own - sometimes a GUID, sometimes a colon delimited identifier, sometimes arbitrary strings.
The value here must match the sub claim within the token presented to Microsoft Entra ID.

```yaml
Type: String
Parameter Sets: Name-Subject, AppId-Subject, ObjId-Subject
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClaimsMatchingExpression
Enables the use of claims matching expressions against specified claims.

```yaml
Type: String
Parameter Sets: Name-ClaimsMatch, AppId-ClaimsMatch, ObjId-ClaimsMatch
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Audience
The audience that can appear in the external token.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Api://AzureADTokenExchange
Accept pipeline input: False
Accept wildcard characters: False
```

### -Headers
Authentication Headers to connect to Microsoft Graph.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Jwt
Jwt to connect to Microsoft Graph.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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
