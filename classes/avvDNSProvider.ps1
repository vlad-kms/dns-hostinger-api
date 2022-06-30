class avvDNSProvider
{
    [Hashtable]hidden $Methods=@{
        'domainsList'='GetDomains'
        'recordsList'='GetRecords'
    }

    [array] GetMethods()
    {
        return $this.Methods
    }

    [bool] MethodIsImplemented([string]$Method)
    {
        return $this.Methods.Contains($Method)
    }

    [String] GetImplementationMethod([String]$Method)
    {
        $res=''
        if ($this.Methods.Contains($Method))
        {
            $res=$this.Methods[$Method]
            if (!($res)) { $res=$Method }
        }
        return $res
    }
}
