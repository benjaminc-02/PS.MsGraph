---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Get-MsGUser

## SYNOPSIS
Retrieves properties of users.

## SYNTAX

### UserName (Default)
```
Get-MsGUser [-UserPrincipalName] <String> [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Filter
```
Get-MsGUser [-Filter] <String> [-AdvancedQuery] [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All
```
Get-MsGUser [-All] [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function retrieves the properties of users.

## EXAMPLES

### EXAMPLE 1
```
Get-MsGUser -UserPrincipalName benjamin.cohn@testdomain.com
```

Retrieves properties and details for the user "benjamin.cohn@testdomain.com".

## PARAMETERS

### -UserPrincipalName
UserPrincipalName or ObjectId of the user.

```yaml
Type: String
Parameter Sets: UserName
Aliases: UserId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Filter
Filter string for retrieving users by property values.

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdvancedQuery
To use when querying using an advanced filter.

```yaml
Type: SwitchParameter
Parameter Sets: Filter
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
To retrieve all available users from Entra ID.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: 4
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
