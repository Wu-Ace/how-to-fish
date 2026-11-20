$ErrorActionPreference='Stop'
$taskRoot=$PSScriptRoot
$node=(Get-Command node -ErrorAction Stop).Source
try{$null=Invoke-RestMethod 'http://127.0.0.1:6092/catalog.json' -TimeoutSec 1}catch{
 Start-Process -FilePath $node -ArgumentList ('"'+(Join-Path $taskRoot 'Tools\gift-panel-server.cjs')+'"') -WorkingDirectory $taskRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $taskRoot 'Evidence\panel-server.log') -RedirectStandardError (Join-Path $taskRoot 'Evidence\panel-server-error.log')
 Start-Sleep -Milliseconds 500
}
Start-Process 'http://127.0.0.1:6092/'
