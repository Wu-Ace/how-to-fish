$ErrorActionPreference='Stop'
$source=Join-Path $PSScriptRoot 'Builds\OriginalRuntime'
$target=Join-Path $PSScriptRoot 'Builds\EditorRebuilt'
Copy-Item (Join-Path $source 'BepInEx') $target -Recurse -Force
foreach($file in @('winhttp.dll','doorstop_config.ini')){Copy-Item (Join-Path $source $file) $target -Force}
$config=Join-Path $target 'BepInEx\config\com.hypemystream.howtofish.cfg'
$text=[IO.File]::ReadAllText($config).Replace('6096','6097');[IO.File]::WriteAllText($config,$text)
$threadCompat=Join-Path $PSScriptRoot 'Recompiled\EmbeddedServer.Mod.Unity63.dll'
if(Test-Path -LiteralPath $threadCompat){Copy-Item $threadCompat (Join-Path $target 'BepInEx\plugins\EmbeddedServer\mods\EmbeddedServer.Mod.dll') -Force}
$notices=Join-Path $PSScriptRoot 'RecoveredProject\ExportedProject\Assets\ThirdPartyNotices'
if(Test-Path -LiteralPath $notices){Copy-Item $notices $target -Recurse -Force}
'Independent Unity player gift plugin prepared on 6097'
