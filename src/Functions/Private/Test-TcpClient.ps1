function Test-TcpClient {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,Position=0)][string]$HostName,
        [parameter(Mandatory=$true,Position=1)][int]$Port
    )
    PROCESS{
        $Connection = [System.Net.Sockets.TcpClient]::new($HostName,$Port)
        Write-Output $Connection
    }
}