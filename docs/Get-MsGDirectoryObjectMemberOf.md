---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Get-MsGDirectoryObjectMemberOf

## SYNOPSIS
Retrieves the group memberships of a directory object.

## SYNTAX

```
Get-MsGDirectoryObjectMemberOf [-Id] <String> [[-SecurityEnabledOnly] <Boolean>] [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves the group memberships of a specified directory object.

## EXAMPLES

### EXAMPLE 1
```
Get-MsGUser benjamin.cohn@testdomain.com | Get-MsGDirectoryObjectMemberOf
```

Retrieves the group memberships for benjamin.cohn@testdomain.com.

### EXAMPLE 2
```
Get-MsGServicePrincipal TestApp-01 | Get-MsGDirectoryObjectMemberOf
```

Retrieves the group memberships for TestApp-01.

## PARAMETERS

### -Id
ObjectId of the directory object.

```yaml
Type: String
Parameter Sets: (All)
Aliases: ObjectId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SecurityEnabledOnly
Determines whether only security groups should be retrieved or if all groups should be returned.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: True
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
