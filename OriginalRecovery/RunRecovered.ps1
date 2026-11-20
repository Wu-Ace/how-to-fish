param([switch]$Verify,[switch]$Smoke,[switch]$Fishing,[switch]$ExitAfterTest,[string]$LogName='runtime-current.log')
$ErrorActionPreference='Stop'
$runtime=Join-Path $PSScriptRoot 'Builds\OriginalRuntime'
$data=Join-Path $runtime 'How to Fish_Data'
Copy-Item (Join-Path $PSScriptRoot 'Recompiled\Assembly-CSharp.Patched.dll') (Join-Path $data 'Managed\Assembly-CSharp.dll') -Force
Copy-Item (Join-Path $PSScriptRoot 'Recompiled\RecoveryExtension.dll') (Join-Path $data 'Managed\RecoveryExtension.dll') -Force
$original='E:\SteamLibrary\steamapps\common\How to Fish\How to Fish\How to Fish_Data\RuntimeInitializeOnLoads.json'
$init=Get-Content -LiteralPath $original -Raw|ConvertFrom-Json
$init.root=@($init.root)+@{assemblyName='RecoveryExtension';nameSpace='';className='RecoveryGiftPanel';methodName='Install';loadTypes=0;isUnityClass=$false}
$init|ConvertTo-Json -Compress -Depth 8|Set-Content (Join-Path $data 'RuntimeInitializeOnLoads.json') -Encoding utf8
$start=New-Object System.Diagnostics.ProcessStartInfo
$start.FileName=Join-Path $runtime 'How to Fish.exe';$start.WorkingDirectory=$runtime;$start.UseShellExecute=$false
$start.Environment['SteamAppId']='4001890';$start.Environment['SteamGameId']='4001890'
$log=Join-Path $PSScriptRoot ('Evidence\'+$LogName)
$start.Arguments='-screen-width 1280 -screen-height 720 -screen-fullscreen 0 -logFile "'+$log+'"'
if($Smoke){$start.Arguments+=' -recovery-smoke'}
if($Verify){$start.Arguments+=' -recovery-smoke -recovery-verify'}
if($Fishing){$start.Arguments+=' -recovery-smoke -recovery-fishing'}
if($ExitAfterTest){$start.Arguments+=' -recovery-exit'}
$process=[System.Diagnostics.Process]::Start($start)
Write-Output "Recovered original process: $($process.Id)"


