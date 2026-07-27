---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Remove-MsGUserAuthMethod

## SYNOPSIS
Removes a specified authentication method from a user in Entra ID.

## SYNTAX

```
Remove-MsGUserAuthMethod [-UserPrincipalName] <String> [[-AuthMethodId] <String>] [-Force]
 [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function will remove a specified authentication method from a user in Entra ID.

## EXAMPLES

### EXAMPLE 1
```
Remove-MsGUserAuthMethod -UserPrincipalName benjamin.cohn@testdomain.com -AuthMethodId 36a3e6ef-6465-45b2-b41b-8b0203ab701f -Force
```

Removes the "36a3e6ef-6465-45b2-b41b-8b0203ab701f" auth method from benjamin.cohn@testdomain.com.

## PARAMETERS

### -UserPrincipalName
UserPrincipalName of the user to remove the auth method of.

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -AuthMethodId
Id of the authentication method of the user to remove.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
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
