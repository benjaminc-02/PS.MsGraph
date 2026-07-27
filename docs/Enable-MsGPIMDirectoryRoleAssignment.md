---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Enable-MsGPIMDirectoryRoleAssignment

## SYNOPSIS
Actives self PIM role assignment for a specified role.

## SYNTAX

### Name
```
Enable-MsGPIMDirectoryRoleAssignment [-RoleDefinitionName] <String> [-Justification] <String>
 [[-Hours] <Int32>] [[-DirectoryScopeId] <String>] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Id
```
Enable-MsGPIMDirectoryRoleAssignment [-RoleDefinitionId] <String> [-Justification] <String> [[-Hours] <Int32>]
 [[-DirectoryScopeId] <String>] [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function activates a self PIM role assignemnt for a given role for the signed-in user.
The justification and timeframe can be provided.

## EXAMPLES

### EXAMPLE 1
```
Enable-MsGPIMDirectoryRoleAssignment -RoleDefinitionName 'Global Administrator' -Justification 'Updating conditional access.'
```

Activates the 'Global Administrator' role for the signed in user to perform the specified actions.

## PARAMETERS

### -RoleDefinitionName
Name of the role.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoleDefinitionId
Id of the role.

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

### -Justification
Justification for elevating access.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hours
Timeframe that the assignment is active for.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryScopeId
Scope id for where to activate the assignment.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: /
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
