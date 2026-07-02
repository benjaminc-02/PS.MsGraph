function Get-MsGErrorMessage {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    # Validate if error message is in json.
    try {
        $errorJson = $ErrorRecord.ErrorDetails.Message | ConvertFrom-Json -Depth 10 -ErrorAction 'Stop'

        # Output JSON error message.
        if ($errorJson.PSObject.Properties.Name -contains 'error') {
            $errorMessage = $errorJson | ConvertTo-Json -Depth 10 -Compress
        }
        else {
            $errorMessage = $ErrorRecord.Exception.Message
        }
    }
    catch {
        $errorMessage = $ErrorRecord.Exception.Message
    }

    # Output $errorMessage
    return $errorMessage
}