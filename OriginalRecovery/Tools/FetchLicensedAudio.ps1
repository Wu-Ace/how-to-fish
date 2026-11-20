$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root=Split-Path $PSScriptRoot -Parent
$records=@()
foreach($slug in @('impact-sounds','interface-sounds','music-jingles')){
 $folder=Join-Path $root ('LicensedArtSources\KenneyAudio\'+$slug)
 New-Item -ItemType Directory -Path $folder -Force|Out-Null
 $page='https://kenney.nl/assets/'+$slug
 $session=New-Object Microsoft.PowerShell.Commands.WebRequestSession
 $html=Invoke-WebRequest $page -WebSession $session -TimeoutSec 30
 $id=[regex]::Match($html.Content,"data-download-id='([^']+)'").Groups[1].Value
 $link=Invoke-RestMethod ('https://kenney.nl/download-link/'+$id) -WebSession $session -Headers @{Referer=$page;Origin='https://kenney.nl';'X-Requested-With'='XMLHttpRequest'} -TimeoutSec 30
 $zip=Join-Path $folder 'upstream.zip'
 Invoke-WebRequest $link.url -WebSession $session -Headers @{Referer=$page} -OutFile $zip -TimeoutSec 60
 $archive=[IO.Compression.ZipFile]::OpenRead($zip)
 $licenses=@();foreach($entry in $archive.Entries){if($entry.FullName -match '(?i)(license|licence).*\.txt$'){$reader=[IO.StreamReader]::new($entry.Open());$licenses+=$reader.ReadToEnd();$reader.Dispose()}}
 $archive.Dispose()
 if(($licenses -join "`n") -notmatch '(?i)CC0|Creative Commons Zero'){throw ('Missing CC0 license: '+$slug)}
 Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $folder 'files') -Force
 $records+=@{pack=$slug;source=$page;license='CC0-1.0';licenseText=$licenses;sha256=(Get-FileHash $zip).Hash;status='downloaded and checked; not mapped to gameplay audio events'}
 $records|ConvertTo-Json -Depth 5|Set-Content (Join-Path $root 'Evidence\licensed-audio-packs.json') -Encoding utf8
 Write-Output ('Verified '+$slug)
}
