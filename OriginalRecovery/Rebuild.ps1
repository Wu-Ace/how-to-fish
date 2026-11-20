param([string]$GameRoot='E:\SteamLibrary\steamapps\common\How to Fish\How to Fish',[string]$SourceFolder='GameSource')
$ErrorActionPreference='Stop'
$taskRoot=$PSScriptRoot
$managed=Join-Path $GameRoot 'How to Fish_Data\Managed'
$out=Join-Path $taskRoot 'Recompiled\Assembly-CSharp.dll'
$lines=@('-nologo','-target:library','-unsafe','-langversion:latest','-nostdlib+',('-out:"'+$out+'"'))
$lines+=Get-ChildItem $managed -Filter '*.dll'|Where-Object Name -ne 'Assembly-CSharp.dll'|ForEach-Object {'-r:"'+$_.FullName+'"'}
$lines+=@(Get-ChildItem (Join-Path $taskRoot $SourceFolder) -Recurse -Filter '*.cs';Get-ChildItem (Join-Path $taskRoot 'RecoverySource') -Filter '*.cs')|Where-Object Name -ne 'UnitySourceGeneratedAssemblyMonoScriptTypes_v1.cs'|ForEach-Object {'"'+$_.FullName+'"'}
$rsp=Join-Path $taskRoot 'Evidence\rebuild.rsp'
Set-Content $rsp $lines -Encoding utf8
& 'E:\UnityHub\6000.3.26f1\Editor\Data\NetCoreRuntime\dotnet.exe' 'E:\UnityHub\6000.3.26f1\Editor\Data\DotNetSdkRoslyn\csc.dll' "@$rsp" *> (Join-Path $taskRoot 'Evidence\rebuild.log')
if($LASTEXITCODE -ne 0){Get-Content (Join-Path $taskRoot 'Evidence\rebuild.log') -TotalCount 65;exit 1}
'RECOVERED_SOURCE_COMPILE_OK'

