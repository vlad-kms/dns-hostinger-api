#using module '.\avvDNSProvider.ps1'
#. .\avvDNSProvider.ps1

class avvDNSBase{
    [string]hidden $provider='_none_'
    [hashtable]$params=[ordered]@{}
    [array]$classes=@()
    [string]$pwd=(Split-Path $psCommandPath -Parent)
    [bool]$IsRaiseEception=$false

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
    [Array]GetRecords()
    {
        return $this.MethodDispath('GetRecords')
    }

    <#
        Диспетчеризация методов  класса для работы с провайдером
        Вход:
            [string]$Method
                'domainsList'
                'recordsList,
                'getRecord,
                'newRecord,
                'changeRecord,
        Выход:
            [Hashtable]
                [int] status
                                = 0 - нет ошибок
                                = 1 - нет провайдера
                                = 2 - нет файлов с реализацией класса
                                = 3 - нет такого класса
                                = 4 - ошибка создания экземпляра класса
                                = 4 - ошибка вызова метода для проверки реализован ли метод в классе
                                = 5 -
                [hashtable] compute - вычисленные данные, переменные во время выполнения функции
                [array]     result  - массив записей с сервера DNS
                [Hashtable] raw     - raw данные с сервера, http ответ на REST запрос
                [String]    msg     - сообщение об ошибке, если status <> 0
                [String]    msgException    - системное сообщение об Exception, если status <> 0
     #>
    [Array] MethodDispath([String]$Method)
    {
        $errors=@(
        "OK"
        "Нет реализации API для провайдера {0}"
        "Ошибка открытия файла реализации API {0} для класса {1}"
        "Нет класса {0}"
        "Ошибка создания экземпляра класса {0}"
        "Ошибка вызова метода {0} класса {1}"
        "Метод {0} не поддерживается в данном классе реализации {1}"
        "Ошибка вызова метода {0} реализации API DNS хостингера {1}: {2}"
        "8"
        "9"
        "Ошибка выполнения вызова API DNS хостера"
        "11"
        "12"
        "13"
        "14"
        "15"
        "16"
        "17"
        "18"
        "19"
        "20"
        "Исключение при вызове REST API провайдера"
        "Ошибка возврата из REST API http request"
        "23"
        )
        $result = @{
            status=0
            compute=@{}
            msg=""
            msgException=""
            Error=@{}
            result=@()
            response=@{}
        }
        $arrObj=@()

        $ClassNameProvider='avvDNS' + $this.ToTitleCase($this.provider)
        $result.compute.add('Method', $Method)
        $result.compute.add('ClassNameProvider', $ClassNameProvider)
        try
        {
            if ($this.provider.ToLower() -ne '_none_')
            {
                # Подключение файла реализации класса
                try
                {
                    $NameModule = "$( $this.pwd )\$( $ClassNameProvider ).ps1"
                    $result.compute.add('NameModule', $NameModule)
                    #Import-Module ".\$($classNameProvider).ps1"
                    #Import-Module $NameModule
                    . "$( $this.pwd )\avvDNSProvider.ps1"
                    . "$($NameModule)"
                }
                catch
                {
                    # "Ошибка открытия файла реализации API {0} для класса {1}"
                    $result.status = 2
                    $arrObj = @($NameModule, $ClassNameProvider)
                    $result.msgException = $PSItem.Exception.Message
                    throw $PSItem
                }

                # Создание экземпляра класса реализации
                try
                {
                    #$classProvider=New-Object -TypeName $classNameProvider -ArgumentList $this.provider;
                    #$ClassProvider=New-Object -TypeName $ClassNameProvider -ArgumentList $this.params;
                    # $ClassNameProvider+="1" # TEST-EXCEPTION
                    $ClassProvider = New-Object -TypeName $ClassNameProvider;
                    $this.classes += $ClassProvider;
                    $ClassProvider.Init($this.Params.extParams);
                    $result.compute.add('classProvider_methods', $ClassProvider.Methods)
                }
                catch
                {
                    # "Ошибка создания экземпляра класса {0}"
                    $result.status = 4
                    $arrObj = @($ClassNameProvider)
                    $result.msgException = $PSItem.Exception.Message
                    throw $PSItem
                }

                # проверить существование описания переданного $Method в классе реализации
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
                    # "Ошибка вызова метода {0} класса {1}"
                    $result.status = 5 # Метод
                    $arrObj = @(
                        '[' + "$ClassNameProvider" + '].' + $ComPart1
                        $ClassNameProvider
                    )
                    $result.msgException = $PSItem.Exception.Message
                    throw $PSItem
                }

                # Подготовить к вызову функцию для $Method
                try
                {
                    if ($MethodIsImplemented)
                    {
                        # Если существует функция в классе для $method
                        try
                        {
                            # вернуть функцию-член класса реализующую функционал метода
                            #$Method += '1' # TEST-EXCEPTION
                            $ComPart1="GetImplementationMethod('$( $Method )')"
                            #$ComPart1="MethodIsImplemented1('$( $Method )')" # TEST_ECEPTION
                            $ImplMethod = Invoke-Expression -Command ('$classProvider.' + $ComPart1)
                            $result.compute.add('ImplMethod', $ImplMethod)
                        }
                        catch
                        {
                            # "Ошибка вызова метода {0} класса {1}"
                            $result.status = 5 # Метод
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
                        # Если не существует функции в классе реализации для $Method
                        # "Метод {0} не поддерживается в данном классе реализации {1}"
                        $result.status = 6
                        $arrObj=@($Method, $ClassNameProvider)
                        $result.result = @()
                        throw [System.InvalidOperationException]::New($errors[$result.status] -f $arrObj)
                        #$result.msgException = "Нет реализации провайдера $($this.provider)"
                    }

                    #$res=$classProvider.MethodDispath($Method, $this.params)
                }
                catch
                {
                    $result.msgException = $PSItem.Exception.Message
                    #throw $PSItem
                    throw
                }

                # Exception если нет функции-реализации
                if ($ImplMethod)
                {
                    #$ImplMethod = '' # TEST-EXCEPTION
                    if (!$ImplMethod)
                    {
                        # не существует реализация
                        # "Метод {0} не поддерживается в данном классе реализации {1}"
                        $result.status = 6
                        $arrObj=@($Method, $ClassNameProvider)
                        $result.result = @()
                        throw [System.InvalidOperationException]::New($errors[$result.status] -f $arrObj)
                    }
                }

                # Вызов функцию-член класса реализующую функционал метода
                try
                {
                    # вызвать функцию-член класса реализующую функционал метода
                    ### это со статическим методом
                    ### $ComPart1="[$($ClassNameProvider)]::"+"$($ImplMethod)("+'$($this.params)'+")"
                    ### это с обычным методом
                    $ComPart1='$classProvider.' + "$($ImplMethod)("+'$($this.params)'+")"
                    #$ComPart1='$classProvider.' + "$($ImplMethod)_("+'$($this.params)'+")" # TEST-EXCEPTION
                    #$ComPart1 = '[avvDNSSelectel]' + $ComPart1 # TEST-EXCEPTION
                    #$ComPart1="MethodIsImplemented1('$( $Method )')" # TEST_ECEPTION
                    $res = Invoke-Expression -Command $ComPart1
                    #$result.compute.add('ExecImplMethod', $res)
                    $result.error=$res.Error
                    $result.response=$res
                    $result.result=$res.result
                }
                catch
                {
                    # "Ошибка вызова метода {0} реализации API DNS хостингера {1}"
                    $result.status = 7
                    $arrObj=@($ImplMethod, $this.provider, $ComPart1)
                    $result.msgException = $PSItem.Exception.Message
                    throw $PSItem
                }
            }
            else
            {
                # "Нет реализации API для провайдера {0}"
                $result.status = 1
                $arrObj=@($this.provider)
                $result.result = @()
                #$result.msgException = "Нет реализации провайдера $($this.provider)"
            }

            # вернулись из метода обработки API с ошибкой
            if ( ($result.response.ErrorCode -ne 0) -and ($result.response.ErrorCode -ne $null) )
            {
                $result.Status=$result.response.ErrorCode
                $arrObj=@()
                throw $result.Error
            }
        }
        catch
        {
            if ($this.IsRaiseEception) {throw}
        }

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
}
