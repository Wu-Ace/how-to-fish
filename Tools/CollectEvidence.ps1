$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$runtime=Join-Path $taskRoot 'Evidence\runtime-verification.txt'
$passes=@(Select-String -LiteralPath $runtime -Pattern '^PASS ').Count
$failures=@(Select-String -LiteralPath $runtime -Pattern '^FAIL ').Count
[pscustomobject]@{collectedUtc=[DateTime]::UtcNow.ToString('o');passed=$passes;failed=$failures;assertions=$passes+$failures;note='Raw runtime header includes one metadata entry; authoritative count is PASS/FAIL rows.'}|ConvertTo-Json|Set-Content (Join-Path $taskRoot 'Evidence\runtime-tally.json')
$paths=@()
foreach($folder in @('Assets','Packages','ProjectSettings','Tools')){
 $paths+=Get-ChildItem -LiteralPath (Join-Path $taskRoot $folder) -Recurse -File | Where-Object {$_.Extension -in '.cs','.shader','.unity','.json','.asset','.txt','.html','.cjs','.ps1'} | Select-Object -ExpandProperty FullName
}
$paths+=@('README.md','ai-handoff.md','启动游戏.cmd','启动礼物控制台.cmd','启动礼物控制台.ps1','Builds\HowToFish\HowToFish.exe','Builds\HowToFish\HowToFish_Data\Managed\Assembly-CSharp.dll','Evidence\runtime-verification.txt','Evidence\runtime-tally.json','Evidence\runtime-03.log','Evidence\build-07.log','Evidence\verification-panel.png','Evidence\verification-harbor.png','Evidence\panel-verification.json','Evidence\original-live-effects.json','Evidence\panel-sandbox-confirmation.json','Evidence\panel-original-confirmation.json','Evidence\acceptance.md')|ForEach-Object {Join-Path $taskRoot $_}
$entries=foreach($file in $paths|Sort-Object -Unique){if(Test-Path -LiteralPath $file){$hash=Get-FileHash -LiteralPath $file -Algorithm SHA256;[pscustomobject]@{path=$file.Substring($taskRoot.Length+1).Replace('\','/');sha256=$hash.Hash;bytes=(Get-Item -LiteralPath $file).Length}}}
[pscustomobject]@{collectedUtc=[DateTime]::UtcNow.ToString('o');engine='6000.3.26f1';git='not a git repository';files=@($entries)}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $taskRoot 'Evidence\manifest-sha256.json')
Write-Output "Assertions: $($passes+$failures); passed: $passes; failed: $failures; hashed files: $($entries.Count)"
