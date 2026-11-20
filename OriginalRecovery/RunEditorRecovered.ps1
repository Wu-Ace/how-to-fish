param([switch]$Verify,[switch]$Fishing,[switch]$Smoke,[switch]$ExitAfterTest,[string]$LogName='editor-runtime-current.log')
$ErrorActionPreference='Stop'
& (Join-Path $PSScriptRoot 'PrepareEditorRuntime.ps1')
$target=Join-Path $PSScriptRoot 'Builds\EditorRebuilt'
$start=New-Object System.Diagnostics.ProcessStartInfo
$start.FileName=Join-Path $target 'HowToFishRecovered.exe';$start.WorkingDirectory=$target;$start.UseShellExecute=$false
$start.Arguments='-screen-width 1280 -screen-height 720 -screen-fullscreen 0 -logFile "'+(Join-Path $PSScriptRoot ('Evidence\'+$LogName))+'"'
if($Smoke){$start.Arguments+=' -recovery-smoke'}
if($Verify){$start.Arguments+=' -recovery-smoke -recovery-verify'}
if($Fishing){$start.Arguments+=' -recovery-smoke -recovery-fishing'}
if($ExitAfterTest){$start.Arguments+=' -recovery-exit'}
$p=[System.Diagnostics.Process]::Start($start)
'Independent Unity source player PID: '+$p.Id
