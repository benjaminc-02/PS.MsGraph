---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Get-MsGApplicationAPIPermission

## SYNOPSIS
Retrieves API permissions of app registrations.

## SYNTAX

### Name
```
Get-MsGApplicationAPIPermission [-DisplayName] <String> [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### AppId
```
Get-MsGApplicationAPIPermission [-AppId] <String> [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ObjId
```
Get-MsGApplicationAPIPermission [-ObjectId] <String> [-Headers <Hashtable>] [-Jwt <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves the API permissions of a specified app registration.

## EXAMPLES

### EXAMPLE 1
```
Get-MsGApplicationAPIPermission -DisplayName TestApp-01
```

Retrieves the API permissions tied to the TestApp-01 app registration.

## PARAMETERS

### -DisplayName
DisplayName of the app registration.

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
AppId of the app registration.

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
ObjectId of the app registration.

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
