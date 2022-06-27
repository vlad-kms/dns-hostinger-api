class avvDNSBase{
    [string]hidden $provider='_none_'
    [hashtable]$params=[ordered]@{}

    [string]$pwd=(Split-Path $psCommandPath -Parent)


    avvDNSBase([hashtable]$data)
    {
        $this.params=$data
        if ($data.Contains('provider'))
        {
            $this.provider=$data.provider
        }
    }

    [Array]GetDomains()
    {
        return $this.GetData('domainsList')
    }

    <#
        ������ � �����������.$this

        ����:
            [string]$command
                'domainsList'
                'recordsList,
                'getRecord,
                'newRecord,
                'changeRecord,
        �������:
            [hashtable]{'status'=[int]; 'result'=[array]@()}
                status  = 0 - ��� ������
                        = 1 - ��� ����������
                        = 2 - ��� ������ ������, ����� � �������, ������ �������� �������
                        = 3 -
                        = 4 -
                        = 5 -
    #>
    [hashtable] hidden GetData([string]$command)
    {
        $errros=@(
            "OK"
            "��� ���������� {0}"
            "��� ������ {0}"
        )
        $result = @{
            status=0
            msg=""
            msgException=""
            result=@()
        }
        $classNameProvider='avvDNS' + $this.ToTitleCase($this.provider) + ""
        if ($this.provider.ToLower() -ne '_none_')
        {
            try
            {

            }
            catch
            {
                $result.status=2 # ��� ������ ������, ����� � �������, ������ �������� �������
                $result.msgException=$PSItem.Exception.Message
            }
        }
        else
        {
            $result.status=1 # ��� ������ ����������
            $result.result=@()
        }
        $arrObj=@($this.provider, $classNameProvider)
        $result.msg=$errros[$result.status] -f $arrObj
        return $result
    }

    [String] ToTitleCase([string]$value, [bool]$isCulture=$false)
    {
        if ($isCulture)
        { return ((Get-Culture).TextInfo).ToTitleCase($value) }
        else
        {
            return ""
        }
    }

    [Void]InitDNSBase()
    {

    }

}
<#
    $t='avvDNSBase';$cs="[$($t)]::new('asas')";$cs;$c=Invoke-Expression $cs;$c
    $t='avvDNSBase';$c1=New-Object -TypeName $($t) -ArgumentList @{'provider'='selectel';'token'='token1'};$c1




 #>
