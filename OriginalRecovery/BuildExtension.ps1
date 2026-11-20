param([string]$GameRoot='E:\SteamLibrary\steamapps\common\How to Fish\How to Fish')
$ErrorActionPreference='Stop'
$taskRoot=$PSScriptRoot;$managed=Join-Path $GameRoot 'How to Fish_Data\Managed';$out=Join-Path $taskRoot 'Recompiled\RecoveryExtension.dll'
$lines=@('-nologo','-target:library','-langversion:latest','-nostdlib+',('-out:"'+$out+'"'))
$lines+=Get-ChildItem $managed -Filter '*.dll'|ForEach-Object {'-r:"'+$_.FullName+'"'}
$lines+=Get-ChildItem (Join-Path $taskRoot 'RecoverySource') -Filter '*.cs'|ForEach-Object {'"'+$_.FullName+'"'}
$rsp=Join-Path $taskRoot 'Evidence\extension.rsp';Set-Content $rsp $lines -Encoding utf8
& 'E:\UnityHub\6000.3.26f1\Editor\Data\NetCoreRuntime\dotnet.exe' 'E:\UnityHub\6000.3.26f1\Editor\Data\DotNetSdkRoslyn\csc.dll' "@$rsp" *> (Join-Path $taskRoot 'Evidence\extension-build.log')
if($LASTEXITCODE -ne 0){Get-Content (Join-Path $taskRoot 'Evidence\extension-build.log');exit 1}
'RECOVERY_EXTENSION_COMPILE_OK'
