<######################################
    [FileCFG]
#######################################>
Class FileCFG {
    [hashtable]$CFG
	[bool]$ErrorAsException = $true
	
    FileCFG(){
		$res=$this.InitFileCFG();
    }
    FileCFG(
		[bool]$EaE
    ){
		$this.ErrorAsException=$EaE
		
        $res=$this.InitFileCFG();
    }

    <##>
    [string]IsExcept ([bool]$Value, [string]$Msg) {
        return [FileCFG]::IsExcept($Value, $this.ErrorAsException, $Msg)
    }

    static [string]IsExcept ([bool]$Value, [bool]$EasE, [string]$Msg) {
        if ( $EasE -and $Value ) {
            throw($Msg)
        }
        if ($Value) {return $Msg} else {return ""}
    }
    
	<#
        Считать секцию
        Возврат:
            [hashtable
	#>
	[hashtable]ReadSection([string]$Section) {
		$result=[ordered]@{}
        if ( !$this.IsExcept(!$this.CFG.ContainsKey($Section), "Not found section name $($Section)") ) {
            $result = $this.CFG[$Section]
        }
		return $result
	}
    
    <#
        Считать значение ключа
        Возврат:
            [string] Значение ключа. Если ключа нет, то $null
    #>
    [string]GetKey([string]$Path, [string]$Key){
        $Result = ""
        $Section=$this.ReadSection($path)
        if ( ($section.Count -ne 0) -and ($Section.ContainsKey($Key)) ) {
            $Result = $Section[$Key]
        } else {
            $Result = $null
        }
        return $Result
    }

    <#
    [string]ToString() {
        return [string]$this.CFG.Keys
    }
    #>

}






Class IniCFG : FileCFG {
    [string]$FileName
    [hashtable]$CFG
	[bool]$ErrorAsException
	
    IniCFG(){
        $this.FileName=$PSCommandPath + '.cfg'
		$this.ErrorAsException=$True

		$res=$this.InitFileCFG();
    }
    IniCFG(
		[bool]$EaE
    ){
        $this.FileName=$PSCommandPath + '.cfg'
		$this.ErrorAsException=$EaE
		
        $res=$this.InitFileCFG();
    }

    IniCFG(
        [string]$FN
    ){
        $this.FileName=$FN;
		$this.ErrorAsException=$True
		
        $res=$this.InitFileCFG();
    }
    IniCFG(
        [string]$FN,
		[bool]$EaE
    ){
        $this.FileName=$FN;
		$this.ErrorAsException=$EaE
		
        $res=$this.InitFileCFG();
    }

    [string]IsExcept ([bool]$Value, [string]$Msg) {
        return [IniCFG]::IsExcept($Value, $this.ErrorAsException, $Msg)
    }
    static [string]IsExcept ([bool]$Value, [bool]$EasE, [string]$Msg) {
        if ( $EasE -and $Value ) {
            throw($Msg)
        }
        if ($Value) {return $Msg} else {return ""}
    }
    <#
		Инициализация. Проверить существование файла, считать данные из
		файла в hashtable.
		Exception, если не считали, или объект пустой 
    #>
    [bool]InitFileCFG() {
        $result=$false
		
        [IniCFG]::IsExcept(!$this.FileName, $true, "Not defined Filename for file configuration.")
        $isFile = Test-Path -Path "$($this.FileName)" -PathType Leaf
        [IniCFG]::IsExcept(!$isFile, $true, "Not exists file configuration: $($this.FileName)")
	    $this.CFG=([IniCFG]::ImportInifile($this.FileName))
        $result=($this.CFG.Count -ne 0)
        $this.IsExcept(!$result, "Error parsing file CFG: $($this.FileName)")
        return $result
    }
    
    <#
	#>
    static [hashtable]ImportInifile([string]$Filename){
        $iniObj = [ordered]@{}
        $section=""
        switch -regex -File $Filename {
            "^\[(.+)\]$" {
                $section = $matches[1]
                $iniObj[$section] = [ordered]@{}
                #Continue
            }
            "(?<key>^[^\#\;\=]*)[=?](?<value>.+)" {
                $key  = $matches.key.Trim()
                $value  = $matches.value.Trim()

                if ( ($value -like '$(*)') -or ($value -like '"*"') ) {
                    # в INI могут использоваться переменные (команды) из скрипта 
                    # key1=$($var1)
                    # key2="$var1"
                    $value = Invoke-Expression $value
                }
                if ( $section ) {
                    $iniObj[$section][$key] = $value
                } else {
                    $iniObj[$key] = $value
                }
                continue
            }
            "(?<key>^[^\#\;\=]*)[=?]" {
                $key  = $matches.key.Trim()
                if ( $section ) {
                    $iniObj[$section][$key] = ""
                } else {
                    $iniObj[$key] = ""
                }
            }
        } ### switch -regex -File $IniFile {
        return $iniObj
    }
	
	<#
        Считать секцию
        Возврат:
            [hashtable
	#>
	[hashtable]ReadSection([string]$Section) {
		$result=[ordered]@{}
        if ( !$this.IsExcept(!$this.CFG.ContainsKey($Section), "Not found section name $($Section)") ) {
            $result = $this.CFG[$Section]
        }
		return $result
	}
    
    <#
        Считать значение ключа
        Возврат:
            [string] Значение ключа. Если ключа нет, то $null
    #>
    [string]GetKey([string]$Path, [string]$Key){
        $Result = ""
        $Section=$this.ReadSection($path)
        if ( ($section.Count -ne 0) -and ($Section.ContainsKey($Key)) ) {
            $Result = $Section[$Key]
        } else {
            $Result = $null
        }
        return $Result
    }

    <#
    [string]ToString() {
        return [string]$this.CFG.Keys
    }
    #>

}
<#
$c1=[IniCFG]::new()
$c1
#>