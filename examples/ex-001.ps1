
$q=.\dns-cli.ps1 -Debug -Action 'v' -Domain t.mrovo.ru -ExtParams @{'extVersion'='';'ewr'='cvcx'} -Provider 'clinic';
$q.result;$q.response

$q=.\dns-cli.ps1 -Debug -Action 'doctors' -Domain t.mrovo.ru -ExtParams @{'extVersion'='';'ewr'='cvcx'} -Provider 'clinic';
$q.result;$q.response

$q=.\dns-cli.ps1 -Debug -Action 'doctors' -Domain t.mrovo.ru -ExtParams @{'extUri'='370f01fe-2f39-11e9-bec0-f44d30eed1e5/workplaces'; 'erewr'='cvcx'} -Provider 'clinic';
$q.result;$q.response
