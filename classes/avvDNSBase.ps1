class avvDNSBase{
    [string]hidden $provider='_none_'
    [hashtable]$params=[ordered]@{}
    [array]$classes=@()

    [string]$pwd=(Split-Path $psCommandPath -Parent)


    avvDNSBase([string]$provider)
    {
        $this.provider=$provider
        $this.params=[ordered]@{
            provider=$provider
        }
    }

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
        Работа с провайдером.$this

        Вход:
            [string]$command
                'domainsList'
                'recordsList,
                'getRecord,
                'newRecord,
                'changeRecord,
        Возврат:
            [hashtable]{'status'=[int]; 'result'=[array]@()}
                status  = 0 - нет ошибок
                        = 1 - нет провайдера
                        = 2 - нет такого класса, файла с классом, ошибка создания объекта
                        = 3 -
                        = 4 -
                        = 5 -
    #>
    [hashtable] hidden GetData([string]$command)
    {
        $errros=@(
            "OK"
            "Нет провайдера {0}"
            "Нет класса {0}"
        )
        $result = @{
            status=0
            msg=""
            msgException=""
            result=@()
        }
        #$result.cp=$psCommandPath #--------------------------------------------------------------
        $classNameProvider='avvDNS' + $this.ToTitleCase($this.provider)
        if ($this.provider.ToLower() -ne '_none_')
        {
            try
            {
                Import-Module ".\$($classNameProvider).ps1"
                #Import-Module "./avvDNSSelectel.ps1"
                #$classProvider=New-Object -TypeName $classNameProvider -ArgumentList $this.provider;
                $classProvider=New-Object -TypeName $classNameProvider

                ############# delete
                $result.qwerty=$classProvider
            }
            catch
            {
                $result.status=2 # нет такого класса, файла с классом, ошибка создания объекта
                $result.msgException=$PSItem.Exception.Message
            }
        }
        else
        {
            $result.status=1 # нет такого провайдера
            $result.result=@()
        }
        $arrObj=@($this.provider, $classNameProvider)
        $result.msg=$errros[$result.status] -f $arrObj
        return $result
    }

    [String] ToTitleCase([string]$value)
    {
        return $this.ToTitleCase($value, $false)
    }

    [String] ToTitleCase([string]$value, [bool]$isCulture)
    {
        $result = ""
        if ($isCulture)
        {
            $result=((Get-Culture).TextInfo).ToTitleCase($value)
        }
        else
        {
            $ar=$value.Split(" ").ForEach({if ($_.Length) {$_.Substring(0,1).ToUpper()+$_.Substring(1,($_.Length-1))} else {$_}})
            $result=[string]::Join(" ", $ar)
        }
        return $result
    }

    [String] ToTitleCase([array]$value, [bool]$isCulture)
    {
        $result=""
        $arr=@()
        $value.foreach(
            {
                $arr += if ($_) {$this.ToTitleCase($_, $isCulture)} else {$_}
            }
        )
        $result=[string]::Join("", $arr)
        return $result
    }

    <#
    [Void]InitDNSBase()
    {

    }
     #>

}
<#
    $t='avvDNSBase';$cs="[$($t)]::new('asas')";$cs;$c=Invoke-Expression $cs;$c
    $t='avvDNSBase';$c1=New-Object -TypeName $($t) -ArgumentList @{'provider'='selectel';'token'='token1'};$c1




 #>
