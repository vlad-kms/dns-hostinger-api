using module '.\avvDNSProvider.ps1'

#using module "D:\tools\selectel.dns-hosting\classes\avvDNSSelectel.ps1"
#. .\avvDNSProvider.ps1

class avvDNSSelectel : avvDNSProvider
{

    avvDNSSelectel() : base() {
        $this.Methods.Add('GetDomains', '')
    }

    [Hashtable] GetDomains([Hashtable]$Arguments)
    {
        $res=@{}
        $res.add('Provider', 'Selectel')
        return $res
    }

    #avvDNSSelectel
}