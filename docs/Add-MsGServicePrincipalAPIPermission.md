---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Add-MsGServicePrincipalAPIPermission

## SYNOPSIS
Adds specified API permission to service principal.

## SYNTAX

### Name (Default)
```
Add-MsGServicePrincipalAPIPermission [-DisplayName] <String> [-Permission] <String[]> [[-Type] <String>]
 [-ResourceAppId <String>] [-Force] [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AppId
```
Add-MsGServicePrincipalAPIPermission [-AppId] <String> [-Permission] <String[]> [[-Type] <String>]
 [-ResourceAppId <String>] [-Force] [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ObjId
```
Add-MsGServicePrincipalAPIPermission [-ObjectId] <String> [-Permission] <String[]> [[-Type] <String>]
 [-ResourceAppId <String>] [-Force] [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function adds specified API permissions to an service principal.
Both application and delegated permissions can be assigned for any resource application.

## EXAMPLES

### EXAMPLE 1
```
Add-MsGServicePrincipalAPIPermission -DisplayName TestApp-01 -Permission User.Read.All -Type Application -AdminConsent -Force
```

This adds the User.Read.All Application API Permission for Microsoft Graph to the TestApp-01 service principal, allowing it to read user data in the tenant.

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

### -Permission
List of permissions to add to the service principal.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Type of permissions to add to the service principal.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Application
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceAppId
App/Client Id of the resource application that the permissions are assigned from.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 00000003-0000-0000-c000-000000000000
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
