# Load Class Definitions
Get-ChildItem -Path $PSScriptRoot\ClassDefinitions -File -Recurse | ForEach-Object {
    if ($_.Extension -eq '.cs') {
        Add-Type -Path $_.FullName -ErrorAction 'Stop'
    }
    else {
        . $_.FullName
    }
}

# Load Functions
Get-ChildItem -Path $PSScriptRoot\Functions\Private -Filter '*.ps1' -File -Recurse | ForEach-Object {
    . $_.FullName
}

# Load Functions
Get-ChildItem -Path $PSScriptRoot\Functions\Public -Filter '*.ps1' -File -Recurse | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}