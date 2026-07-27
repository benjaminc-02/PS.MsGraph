---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Get-MsGUserAuthMethod

## SYNOPSIS
Retrieves the authentication methods of a given user.

## SYNTAX

```
Get-MsGUserAuthMethod [-UserPrincipalName] <String> [[-AuthMethod] <String>] [-Headers <Hashtable>]
 [-Jwt <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves the authentication methods of a given user.

## EXAMPLES

### EXAMPLE 1
```
Get-MsGUserAuthMethod -UserPrincipalName benjamin.cohn@testdomain.com -AuthMethod MSAuthApp
```

Retrieves all auth methods for benjamin.cohn@testdomain.com that are from the Microsoft Authenticator app.

## PARAMETERS

### -UserPrincipalName
UserPrincipalName or ObjectId of the user.

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

### -AuthMethod
Auth method type that should be retrieved off the user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: All
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
