---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Add-MsGDirectoryRoleAssignment

## SYNOPSIS
Adds a member to a role in Entra ID.

## SYNTAX

### Name
```
Add-MsGDirectoryRoleAssignment [-RoleDefinitionName] <String> [[-DirectoryScopeId] <String>]
 [[-UserPrincipalName] <String[]>] [[-GroupName] <String[]>] [[-DirectoryObjectId] <String[]>]
 [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Id
```
Add-MsGDirectoryRoleAssignment [-RoleDefinitionId] <String> [[-DirectoryScopeId] <String>]
 [[-UserPrincipalName] <String[]>] [[-GroupName] <String[]>] [[-DirectoryObjectId] <String[]>]
 [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function adds a given member to a specified role in Entra ID.

## EXAMPLES

### EXAMPLE 1
```
Add-MsGDirectoryRoleAssignment -RoleDefinitionName "Global Administrator" -UserPrincipalName benjamin.cohn@testdomain.com
```

Assigns the "Global Administrator" role to benjamin.cohn@testdomain.com.

## PARAMETERS

### -RoleDefinitionName
Name of the role to add the principal to.

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

### -RoleDefinitionId
ID of the role to add the principal to.

```yaml
Type: String
Parameter Sets: Id
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryScopeId
Scope of the role to add the principal to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: /
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserPrincipalName
UserPrincipalName of the user to add to the role.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupName
GroupName of the group to add to the role.
Needs to be able to be assigned.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryObjectId
ObjectId of the principal to add to the role.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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
