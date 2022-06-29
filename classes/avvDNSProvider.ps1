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
            if (-not $res) { $res=$Method }
        }
        return $res
    }
<##############################
    [Array] MethodDispath([String]$Method, [Hashtable]$Arguments)
    {
        $res=@()
        if ($this.MethodIsSupported($Method))
        {
            $MethodImpl=$this.Methods[$Method]
            $Command='$this.'+"$($MethodImpl)"+'($Arguments)'
            $res=(Invoke-Expression -Command $Command)
        }
        return $res
    }
    [Hashtable] GetDomains([Hashtable]$Arguments)
    {
        $res=@{'args'=$Arguments}
        return $res
    }

    [Hashtable] GetRecords([Hashtable]$Arguments)
    {
        $res=@{'args'=$Arguments}
        return $res
    }
############################>
}
