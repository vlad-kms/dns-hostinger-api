
$global:q1=.\dns-cli.ps1 -Debug -Action 'v' -ExtParams @{'ExtVersion'='';'ewr'='cvcx'} -Provider 'clinic';
$q1.result;$q1.response

$global:q2=.\dns-cli.ps1 -Debug -Action 'doctors' -ExtParams @{'ExtVersion'='';'ewr'='cvcx'} -Provider 'clinic';
$q2.result;$q2.response

$global:q3=.\dns-cli.ps1 -Debug -Action 'doctors' -ExtParams @{'ExtUri'='370f01fe-2f39-11e9-bec0-f44d30eed1e5/workplaces'; 'erewr'='cvcx'} -Provider 'clinic';
$q3.result;$q3.response

$global:q4=.\dns-cli.ps1 -Debug -Action 'doctors' -ExtParams @{'ExtUri'='370f01fe-2f39-11e9-bec0-f44d30eed1e5/workplaces'; 'access_token'='access_token'} -Provider 'clinic';
$q4.result;$q4.response

############
$q=.\dns-cli.ps1 -FileIni "E:\projects\my-configs\src\dns-hostinger\dns-cli.ps1.ini" -Provider 'selectel' -Action 'gd' -ExtParams @{'domainId'='t.mrovo.ru';'classDebug'=1};$q;$q.result
<# ВЫВОД НА ЭКРАН
Пробуем импорт модуля avvClasses.
================================================
================================================

Name                           Value
----                           -----
msg                            OK
compute                        {ImplMethod, ClassNameProvider, classProvider_methods, Method...}
result                         {Microsoft.PowerShell.Commands.Internal.Format.FormatStartData, Microsoft.PowerShell.Commands.Internal.Format.GroupStartData, Microsoft.PowerShell.Commands.Internal.Format.FormatEntryData, Microsoft.PowerShell.Comma...
msgException
status                         0
Error
response                       {this, data, resarr, raw...}



id name       create_date user_id tags change_date ips
-- ----       ----------- ------- ---- ----------- ---
791388 t.mrovo.ru  1653996098  218200 {}    1654462640 {188.64.221.10, 188.64.221.10, 188.64.221.10, 188.64.221.78...}
#>

$q=.\dns-cli.ps1 -FileIni "E:\projects\my-configs\src\dns-hostinger\dns-cli.ps1.ini" -Provider 'selectel' -Action 'gd' -ExtParams @{'classDebug'=1};$q;$q.result
<# ВЫВОД НА ЭКРАН
Пробуем импорт модуля avvClasses.
================================================
================================================

Name                           Value
----                           -----
msg                            OK
compute                        {ImplMethod, ClassNameProvider, classProvider_methods, Method...}
result                         {Microsoft.PowerShell.Commands.Internal.Format.FormatStartData, Microsoft.PowerShell.Commands.Internal.Format.GroupStartData, Microsoft.PowerShell.Commands.Internal.Format.FormatEntryData, Microsoft.PowerShell.Comma...
msgException
status                         0
Error
response                       {this, data, resarr, raw...}



id name          create_date user_id tags change_date ips
-- ----          ----------- ------- ---- ----------- ---
792021 alt.av-kms.ru  1654286694  218200 {}    1654351372 {2.1.1.6, 213.59.193.170}
792250 avkms.ru       1654337179  218200 {}    1654550152 {178.218.108.151, 188.64.222.66, 188.64.221.10, 87.225.88.149...}
791977 av-kms.ru      1654266952  218200 {}    1658645921 {92.37.148.34, 87.225.87.241, 178.218.108.151, 178.218.108.151...}
791376 mrovo.ru       1653988859  218200 {}    1658745861 {192.168.11.3, 192.168.11.1, 87.225.88.149, 188.64.221.10...}
791388 t.mrovo.ru     1653996098  218200 {}    1654462640 {188.64.221.10, 188.64.221.10, 188.64.221.10, 188.64.221.78...}
#>