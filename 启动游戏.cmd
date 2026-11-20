@echo off
setlocal
set SteamAppId=4001890
set SteamGameId=4001890
cd /d "%~dp0OriginalRecovery\Builds\OriginalRuntime"
start "" "How to Fish.exe" -screen-width 1280 -screen-height 720 -screen-fullscreen 0 -logFile "..\..\Evidence\runtime-current.log"
