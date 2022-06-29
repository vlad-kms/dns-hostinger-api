#using module '.\avvDNSProvider.ps1'
#. .\avvDNSProvider.ps1

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
        return $this.MethodDispath('domainsList')
    }

    <#
        ��������������� �������  ������ ��� ������ � �����������
        ����:
            [string]$Method
                'domainsList'
                'recordsList,
                'getRecord,
                'newRecord,
                'changeRecord,
        �����:
            [Hashtable]
                [int] status
                                = 0 - ��� ������
                                = 1 - ��� ����������
                                = 2 - ��� ������ � ����������� ������
                                = 3 - ��� ������ ������
                                = 4 - ������ �������� ���������� ������
                                = 4 - ������ ������ ������ ��� �������� ���������� �� ����� � ������
                                = 5 -
                [hashtable] compute - ����������� ������, ���������� �� ����� ���������� �������
                [array]     result  - ������ ������� � ������� DNS
                [Hashtable] raw     - raw ������ � �������, http ����� �� REST ������
                [String]    msg     - ��������� �� ������, ���� status <> 0
                [String]    msgException    - ��������� ��������� �� Exception, ���� status <> 0
     #>
    [Array] MethodDispath([String]$Method)
    {
        $errors=@(
        "OK"
        "��� ���������� API ��� ���������� {0}"
        "������ �������� ����� ���������� API {0} ��� ������ {1}"
        "��� ������ {0}"
        "������ �������� ���������� ������ {0}"
        "������ ������ ������ {0} ������ {1}"
        "����� {0} �� �������������� � ������ ������ ���������� {1}"
        )
        $result = @{
            status=0
            compute=@{}
            msg=""
            msgException=""
            result=@()
            raw=@{}
        }
        $arrObj=@()

        $ClassNameProvider='avvDNS' + $this.ToTitleCase($this.provider)
        $result.compute.add('Method', $Method)
        $result.compute.add('ClassNameProvider', $ClassNameProvider)
        try
        {
            if ($this.provider.ToLower() -ne '_none_')
            {
                # ����������� ����� ���������� ������
                try
                {
                    $NameModule = "$( $this.pwd )\$( $ClassNameProvider ).ps1"
                    $result.compute.add('NameModule', $NameModule)
                    #Import-Module ".\$($classNameProvider).ps1"
                    #Import-Module $NameModule
                    . "$( $this.pwd )\avvDNSProvider.ps1"
                    . $NameModule
                }
                catch
                {
                    # "������ �������� ����� ���������� API {0} ��� ������ {1}"
                    $result.status = 2
                    $arrObj = @($NameModule, $ClassNameProvider)
                    $result.msgException = $PSItem.Exception.Message
                    throw $PSItem
                }

                # �������� ���������� ������ ����������
                try
                {
                    #$classProvider=New-Object -TypeName $classNameProvider -ArgumentList $this.provider;
                    #$ClassProvider=New-Object -TypeName $ClassNameProvider -ArgumentList $this.params;
                    # $ClassNameProvider+="1" # TEST-EXCEPTION
                    $ClassProvider = New-Object -TypeName $ClassNameProvider;
                    $result.compute.add('classProvider', $ClassProvider.Methods)
                }
                catch
                {
                    # "������ �������� ���������� ������ {0}"
                    $result.status = 4
                    $arrObj = @($ClassNameProvider)
                    $result.msgException = $PSItem.Exception.Message
                    throw $PSItem
                }

                # ��������� ������������� �������� ����������� $Method � ������ ����������
                try
                {
                    #$Method += '1' # TEST-EXCEPTION
                    $ComPart1="MethodIsImplemented('$( $Method )')"
                    #$ComPart1="MethodIsImplemented1('$( $Method )')" # TEST_ECEPTION
                    #$CommandIsImplemented = '$ClassProvider.' + "MethodIsImplemented('$( $Method )')"
                    $CommandIsImplemented = '$ClassProvider.' + $ComPart1
                    $result.compute.add('CommandIsImplemented', $CommandIsImplemented)
                    $MethodIsImplemented=Invoke-Expression -Command ($CommandIsImplemented)
                    #$MethodIsImplemented = Invoke-Expression -Command ('$classProvider.' + "MethodIsSupported('$( $Method )')")
                    $result.compute.add('MethodIsImplemented', $MethodIsImplemented)
                }
                catch
                {
                    # "������ ������ ������ {0} ������ {1}"
                    $result.status = 5 # �����
                    $arrObj = @(
                        '[' + "$ClassNameProvider" + '].' + $ComPart1
                        $ClassNameProvider
                    )
                    $result.msgException = $PSItem.Exception.Message
                    throw $PSItem
                }

                # ����������� � ������ ������� ��� $Method
                try
                {
                    if ($MethodIsImplemented)
                    {
                        # ���� ���������� ������� � ������ ��� $method
                        try
                        {
                            # ������� �������-���� ������ ����������� ���������� ������
                            #$Method += '1' # TEST-EXCEPTION
                            $ComPart1="GetImplementationMethod('$( $Method )')"
                            #$ComPart1="MethodIsImplemented1('$( $Method )')" # TEST_ECEPTION
                            $ImplMethod = Invoke-Expression -Command ('$classProvider.' + $ComPart1)
                            $result.compute.add('ImplMethod', $ImplMethod)
                        }
                        catch
                        {
                            # "������ ������ ������ {0} ������ {1}"
                            $result.status = 5 # �����
                            $arrObj = @(
                            '[' + "$ClassNameProvider" + '].' + $ComPart1
                            $ClassNameProvider
                            )
                            $result.msgException = $PSItem.Exception.Message
                            throw $PSItem
                        }
                    }
                    else
                    {
                        # ���� �� ���������� ������� � ������ ���������� ��� $Method
                        # "����� {0} �� �������������� � ������ ������ ���������� {1}"
                        $result.status = 6
                        $arrObj=@($Method, $ClassNameProvider)
                        $result.result = @()
                        throw [System.InvalidOperationException]::New($errors[$result.status] -f $arrObj)
                        #$result.msgException = "��� ���������� ���������� $($this.provider)"
                    }

                    #$res=$classProvider.MethodDispath($Method, $this.params)
                }
                catch
                {
                    $result.msgException = $PSItem.Exception.Message
                    throw $PSItem
                }

                # ����� �������-����������
                try
                {
                    # ������� �������-���� ������ ����������� ���������� ������
                    $ImplMethod = '' # TEST-EXCEPTION
                    if ($ImplMethod)
                    {
                        # ���� ���������� ����������
                        #echo "fsd"
                    }
                    else
                    {
                        # �� ���������� ����������
                        # "����� {0} �� �������������� � ������ ������ ���������� {1}"
                        $result.status = 6
                        $arrObj=@($Method, $ClassNameProvider)
                        $result.result = @()
                        throw [System.InvalidOperationException]::New($errors[$result.status] -f $arrObj)
                        #$result.msgException = "��� ���������� ���������� $($this.provider)"

                    }
                }
                catch
                {
                    #"��� ���������� {0}"
                    #"������ �������� ����� ���������� API {0} ��� ������ {1}"
                    #"��� ������ {0}"
                    $result.status = 2 # ��� ������ ������, ����� � �������, ������ �������� �������
                    $result.msgException = $PSItem.Exception.Message
                    throw $PSItem
                }
            }
            else
            {
                # "��� ���������� API ��� ���������� {0}"
                $result.status = 1
                $arrObj=@($this.provider)
                $result.result = @()
                #$result.msgException = "��� ���������� ���������� $($this.provider)"
            }
        }
        catch {}

        #$arrObj=@($this.provider, $classNameProvider, $NameModule)
        $result.msg=$errors[$result.status] -f $arrObj
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
            $ar=$value.Split(" ").ForEach({if ($_.Length) {$_.Substring(0,1).ToUpper()+$_.Substring(1,($_.Length-1)).ToLower()} else {$_}})
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
