---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# New-MsGApplicationPassword

## SYNOPSIS
Create new application password.

## SYNTAX

### Name (Default)
```
New-MsGApplicationPassword [-DisplayName] <String> [[-DaysTillExpiration] <Int32>] [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AppId
```
New-MsGApplicationPassword [-AppId] <String> [[-DaysTillExpiration] <Int32>] [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ObjId
```
New-MsGApplicationPassword [-ObjectId] <String> [[-DaysTillExpiration] <Int32>] [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function creates a new application password/client secret for a given app registration..

## EXAMPLES

### EXAMPLE 1
```
New-MsGApplicationPassword -DisplayName TestApp-01 -DaysTillExpiration 365
```

@odata.context      : https://graph.microsoft.com/v1.0/$metadata#microsoft.graph.passwordCredential
customKeyIdentifier :
displayName         : Password uploaded on Mon Jul 27 2026
endDateTime         : 7/27/2027 2:43:04 PM
hint                : -gx
keyId               : b9192cec-a784-4cc3-babe-067df0dab412
secretText          : -gx8Q~_H1GPUygPDGJl4D.otjdReVx-x0KnvnaGF
startDateTime       : 7/27/2026 2:43:04 PM

Creates a brand new application password for the TestApp-01 app registration.

## PARAMETERS

### -DisplayName
Display Name of the app registration.

```yaml
Type: String
Parameter Sets: Name
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
Parameter Sets: AppId
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
Parameter Sets: ObjId
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DaysTillExpiration
Days till the password expires.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 365
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
