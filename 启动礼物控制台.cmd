@echo off
set "FISH_PANEL_ROOT=%~dp0"
powershell.exe -NoProfile -Command "$taskRoot=$env:FISH_PANEL_ROOT; $node=(Get-Command node).Source; try{$null=Invoke-RestMethod 'http://127.0.0.1:6092/catalog.json' -TimeoutSec 1}catch{Start-Process -FilePath $node -ArgumentList ([string][char]34+(Join-Path $taskRoot 'Tools\gift-panel-server.cjs')+[char]34) -WorkingDirectory $taskRoot -WindowStyle Hidden; Start-Sleep -Milliseconds 700}; Start-Process 'http://127.0.0.1:6092/'"

