# Test-DCPorts
Scans all Domain & Trust ports.
    
### DESCRIPTION
Similar to PortQuery "Domain & Trust" scan but includes Dynamic-RPC ports (5000-6000).
    
### PARAMETERS 
`<ComputerName>` // Hostname of the server to scan.

### OUTPUTS
System.Array. Returns an object with Computer Name, Port Number, Port Description and Port Status.

### USAGE EXAMPLES

`C:\PS> Test-DCPorts DC01`

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
    
`C:\PS> Get-ADDomainController -Filter * | Test-DCPorts` // Would test all Domain Controllers.
 
### Credits
- [`Test-RPC`](https://www.powershellgallery.com/packages/Test-RPC/1.0/Content/Test-RPC.ps1) written by Ryan Ries
- [`PortQry`](https://www.microsoft.com/en-us/download/details.aspx?id=17148) from Microsoft
