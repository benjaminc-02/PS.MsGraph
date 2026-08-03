---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# New-MsGGroup

## SYNOPSIS
Creates new group in Entra ID.

## SYNTAX

### Security (Default)
```
New-MsGGroup [-DisplayName] <String> [[-Description] <String>] [-IsAssignableToRole] [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Dynamic
```
New-MsGGroup [-DisplayName] <String> [[-Description] <String>] [-MembershipRule <String>]
 [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### M365
```
New-MsGGroup [-DisplayName] <String> [[-Description] <String>] [-MailEnabled] [-EmailAddress <String>]
 [-MailNickname <String>] [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function allows you to create new groups in Entra ID.
By default groups are Security-Enabled unless stated otherwise.

## EXAMPLES

### EXAMPLE 1
```
New-MsGGroup -DisplayName FinanceAdmins -Description "Group for admins in the Finance department."
```

Creates a Security-Enabled group in Entra ID.

### EXAMPLE 2
```
New-MsGGroup -DisplayName FinanceMembers -Description "Members of the Finance department." -MembershipRule "(user.department eq 'Finance')"
```

Creates a Security-Enabled group in Entra ID that is dynamically populated with users whose Department is 'Finance'.

## PARAMETERS

### -DisplayName
DisplayName of the group to create.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description of the group to create.

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

### -IsAssignableToRole
Determines if the group is assignable to a role.

```yaml
Type: SwitchParameter
Parameter Sets: Security
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MailEnabled
Determines whether the group is mail-enabled or not.

```yaml
Type: SwitchParameter
Parameter Sets: M365
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EmailAddress
Email address of the group to create.

```yaml
Type: String
Parameter Sets: M365
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MailNickname
Mail nickname of the group to create.

```yaml
Type: String
Parameter Sets: M365
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MembershipRule
Membership rule for dynamic group.

```yaml
Type: String
Parameter Sets: Dynamic
Aliases:

Required: False
Position: Named
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
