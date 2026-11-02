---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Remove-MsGServicePrincipal

## SYNOPSIS
Removes service principal from Entra ID.

## SYNTAX

### Name
```
Remove-MsGServicePrincipal [-DisplayName] <String> [-Force] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AppId
```
Remove-MsGServicePrincipal [-AppId] <String> [-Force] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ObjId
```
Remove-MsGServicePrincipal [-ObjectId] <String> [-Force] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function removes a specified service principal from Entra ID, deleting the object.

## EXAMPLES

### EXAMPLE 1
```
Remove-MsGServicePrincipal -DisplayName TestApp-01 -Force
```

This removes the TestApp-01 service principal from Entra ID.

## PARAMETERS

### -DisplayName
Display Name of the service principal.

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
App/Client Id of the service principal.

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
Object Id of the service principal.

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

### -Force
Bypasses the confirmation check.

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
