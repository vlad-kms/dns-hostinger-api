
$global:q1=.\dns-cli.ps1 -Debug -Action 'v' -ExtParams @{'ExtVersion'='';'ewr'='cvcx'} -Provider 'clinic';
$q1.result;$q1.response

$global:q2=.\dns-cli.ps1 -Debug -Action 'doctors' -ExtParams @{'ExtVersion'='';'ewr'='cvcx'} -Provider 'clinic';
$q2.result;$q2.response

$global:q3=.\dns-cli.ps1 -Debug -Action 'doctors' -ExtParams @{'ExtUri'='370f01fe-2f39-11e9-bec0-f44d30eed1e5/workplaces'; 'erewr'='cvcx'} -Provider 'clinic';
$q3.result;$q3.response
