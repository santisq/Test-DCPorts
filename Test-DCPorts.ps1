function Test-DCPorts{
<#
    .SYNOPSIS
    Scans all Domain & Trust ports.
    
    .DESCRIPTION
    Similar to PortQuery "Domain & Trust" scan but includes Dynamic-RPC ports (5000-6000).
    
    .PARAMETER ComputerName
    Hostname of the server to scan.

    .OUTPUTS
    System.Array. Returns an object with Computer Name, Port Number, Port Description and Port Status.

    .EXAMPLE
    C:\PS> Test-DCPorts DC01

        ComputerName Port      Service                       Status            
        ------------ ----      -------                       ------            
        DC01         9389      Active Directory Web Services LISTENING         
        DC01         135       RPC Endpoint Mapper           LISTENING         
        DC01         137       NetBIOS Name Service          NOT LISTENING     
        DC01         139       NetBIOS Session Service       LISTENING         
        DC01         445       SMB over IP (Microsoft-DS)    LISTENING         
        DC01         389       LDAP                          LISTENING         
        DC01         636       LDAP over SSL                 LISTENING         
        DC01         3268      Global Catalog LDAP           LISTENING         
        DC01         3269      Global Catalog LDAP over SSL  LISTENING         
        DC01         88        Kerberos                      LISTENING         
        DC01         464       Kerberos Change/Set password  LISTENING         
        DC01         5000-6000 RPC Dynamic Assignment        ALL RPC PORTS OPEN
        DC01                   ICMP (ping)                   RESPONSE OK   
    
    .EXAMPLE           
    C:\PS> Get-ADDomainController -Filter * | Test-DCPorts
        Would test all Domain Controllers.
#>

[cmdletbinding()]
param(
    [parameter(Mandatory,ValueFromPipeline)]
    [string]$ComputerName
)

begin{

$scanResults=New-Object System.Collections.ArrayList
$dcPorts=import-csv "$psscriptroot\Dependencies\dcports.csv"
$portQuery="$psscriptroot\Dependencies\PortQry.exe"
$rpcPath="$psscriptroot\Dependencies\test-rpc.ps1"
$ports=($dcPorts|?{$_.port -notmatch '5000-6000'}|sort port).port -join ','

}

process{

start-job{
    . $args[0]
    Test-RPC $args[1]
} -ArgumentList $rpcPath,$computerName -Name 'RPC' > $null

$icmp=Test-Connection $ComputerName -Count 1 -Quiet
$portScan=&$portQuery -n $computerName -e $ports -p TCP|sls 'LISTENING|FILTERED'

Get-Job|?{$_.Name -eq 'RPC'}|Wait-Job > $null
$rpcResult=Get-Job|?{$_.Name -eq 'RPC'}|Receive-Job
Get-Job|?{$_.Name -eq 'RPC'}|Remove-Job


$DCports|?{$_.port -ne '5000-6000'}|%{

    $scanResults.Add(@{
        ComputerName=$computerName.ToUpper()
        Port=$_.port
        Service=$_.Service
        Status=($portscan|sls "\s$($_.port)\s").ToString().Split(':')[1].Trim()
        }) > $null
}

$scanResults.Add(@{
    ComputerName=$computerName.ToUpper()
    Port='5000-6000'
    Service=($dcPorts|?{$_.port -eq '5000-6000'}).Service
    Status=$(
        if($rpcResult.AllRPCPortsOpen){'ALL RPC PORTS OPEN'}
        else{'FILTERED'}
        )
    }) > $null

$scanResults.Add(@{
    ComputerName=$computerName.ToUpper()
    Port=$null
    Service='ICMP (ping)'
    Status=if($icmp){'RESPONSE OK'}else{'REQUEST TIMED OUT'}
    }) > $null

}

end{

return $scanResults|%{New-Object PSObject -Property $_}|
    select ComputerName,Port,Service,Status

}

}