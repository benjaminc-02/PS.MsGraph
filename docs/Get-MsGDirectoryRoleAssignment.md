---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Get-MsGDirectoryRoleAssignment

## SYNOPSIS
Retrieves principals assigned to the role definition specified.

## SYNTAX

### Name (Default)
```
Get-MsGDirectoryRoleAssignment [-DisplayName] <String> [[-DirectoryScopeId] <String>] [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ObjId
```
Get-MsGDirectoryRoleAssignment [-ObjectId] <String> [[-DirectoryScopeId] <String>] [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves principals assigned to the role definition specified.

## EXAMPLES

### EXAMPLE 1
```
Get-MsGDirectoryRoleAssignment -DisplayName "Global Administrator"
```

Retrieves principals that are assigned "Global Administrator".

## PARAMETERS

### -DisplayName
DisplayName of the role definition.

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

### -ObjectId
ObjectId of the role definition.

```yaml
Type: String
Parameter Sets: ObjId
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryScopeId
Scope of the role definition.

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
