$uri="https://api.selectel.ru/domains/v1/791388/records"
$uri="https://api.selectel.ru/domains/v1/791376/records"



#$body="{'content':'test', 'type':'TXT', 'name':'tst11.t.mrovo.ru.', 'ttl':'86411'}"
$body=@{"content"='test'; type='TXT'; name='tst11.t.mrovo.ru.'; ttl='86411'}
$header=@{"Content-Type"='application/json'; "X-Token"=$token}
#Invoke-Webrequest -Uri $uri -Method POST -Body ($body | ConvertTo-Json) -Headers $header

$w=(Invoke-Webrequest -Uri $uri -Method GET -Headers $header)
echo $w.Content > 123-123
$wo=($w|ConvertFrom-Json)

