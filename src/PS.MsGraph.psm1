# Load Functions
Get-ChildItem -Path $PSScriptRoot\Functions\Private | ForEach-Object {
    . $_.FullName
}
# Load Functions
Get-ChildItem -Path $PSScriptRoot\Functions\Public | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}