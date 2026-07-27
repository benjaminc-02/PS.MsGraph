---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Add-MsGApplicationCertificate

## SYNOPSIS
Adds a specified certificate to an app registration in Entra ID.

## SYNTAX

### Name-Thumbprint
```
Add-MsGApplicationCertificate [-DisplayName] <String> [-Thumbprint] <String> [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Name-Path
```
Add-MsGApplicationCertificate [-DisplayName] <String> [-Path] <String> [[-StoreLocation] <String>]
 [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### AppId-Thumbprint
```
Add-MsGApplicationCertificate [-AppId] <String> [-Thumbprint] <String> [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AppId-Path
```
Add-MsGApplicationCertificate [-AppId] <String> [-Path] <String> [[-StoreLocation] <String>]
 [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ObjId-Thumbprint
```
Add-MsGApplicationCertificate [-ObjectId] <String> [-Thumbprint] <String> [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ObjId-Path
```
Add-MsGApplicationCertificate [-ObjectId] <String> [-Path] <String> [[-StoreLocation] <String>]
 [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function adds a specified certificate to an app registration in Entra ID, allowing it to be used for authentication.

## EXAMPLES

### EXAMPLE 1
```
Add-MsGApplicationCertificate -DisplayName TestApp-01 -Path C:\temp\TestApp-01.cer
```

Adds the specified certificate as an authentication certificate to the app registration.

## PARAMETERS

### -DisplayName
Display Name of the app registration.

```yaml
Type: String
Parameter Sets: Name-Thumbprint, Name-Path
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
Parameter Sets: AppId-Thumbprint, AppId-Path
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
Parameter Sets: ObjId-Thumbprint, ObjId-Path
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path of the public key certificate.

```yaml
Type: String
Parameter Sets: Name-Path, AppId-Path, ObjId-Path
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StoreLocation
Certificate Store location of a stored certificate.

```yaml
Type: String
Parameter Sets: Name-Path, AppId-Path, ObjId-Path
Aliases:

Required: False
Position: 5
Default value: CurrentUser
Accept pipeline input: False
Accept wildcard characters: False
```

### -Thumbprint
Thumbprint of the certificate in the stored location.

```yaml
Type: String
Parameter Sets: Name-Thumbprint, AppId-Thumbprint, ObjId-Thumbprint
Aliases:

Required: True
Position: 6
Default value: None
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
