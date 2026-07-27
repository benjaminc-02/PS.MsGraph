---
external help file: PS.MsGraph-help.xml
Module Name: PS.MsGraph
online version:
schema: 2.0.0
---

# Invoke-MsGRequest

## SYNOPSIS
Issues REST API requests to the Graph API.

## SYNTAX

```
Invoke-MsGRequest [-Method] <String> [-Endpoint] <String> [[-Body] <Hashtable>] [[-Version] <String>]
 [-Headers <Hashtable>] [-Jwt <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function issues REST API requests to the Microsoft Graph API using the specified method and endpoint.

## EXAMPLES

### EXAMPLE 1
```
Invoke-MsGRequest -Method Get -Endpoint 'applications?$filter=displayName eq "TestApp-01"'
```

Invokes the 'applications' endpoint to retrieve apps that are named "TestApp-01".

## PARAMETERS

### -Method
HTTP Method

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

### -Endpoint
Endpoint to call

```yaml
Type: String
Parameter Sets: (All)
Aliases: Uri

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
Request Body

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
Version of the API to call

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: V1.0
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
