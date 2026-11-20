$ErrorActionPreference='Stop'
$recoveryRoot=Split-Path $PSScriptRoot -Parent
$assets=Join-Path $recoveryRoot 'RecoveredProject\ExportedProject\Assets'
$downloads=Join-Path $recoveryRoot 'LicensedArtSources\GoogleFonts'
$notices=Join-Path $assets 'ThirdPartyNotices\Fonts'
$reference=Join-Path $recoveryRoot 'ReferenceOnly\OriginalFonts'
$families=@(
 @{Id='underdog';File='Underdog-Regular.ttf';Match='^Underdog-Regular(?:_\d+)?$'},
 @{Id='zcoolkuaile';File='ZCOOLKuaiLe-Regular.ttf';Match='^ZCOOLKuaiLe-Regular(?:_\d+)?$'},
 @{Id='notosanssc';File='NotoSansSC[wght].ttf';Match='^NotoSansSC-VariableFont_wght(?:_\d+)?$'},
 @{Id='notosansjp';File='NotoSansJP[wght].ttf';Match='^JP_NotoSans(?:_\d+)?$'},
 @{Id='notosanskr';File='NotoSansKR[wght].ttf';Match='^NotoSansKR(?:_\d+)?$'},
 @{Id='notosanstc';File='NotoSansTC[wght].ttf';Match='^NotoSansTC(?:_\d+)?$'}
)
$records=@()
foreach($family in $families){
 $folder=Join-Path $downloads $family.Id;New-Item -ItemType Directory -Path $folder -Force|Out-Null
 $base='https://raw.githubusercontent.com/google/fonts/main/ofl/'+$family.Id+'/'
 $license=Join-Path $folder 'OFL.txt';Invoke-WebRequest ($base+'OFL.txt') -OutFile $license -TimeoutSec 60
 if([IO.File]::ReadAllText($license) -notmatch 'SIL Open Font License'){throw ('Unverified font license: '+$family.Id)}
 $font=Join-Path $folder $family.File;Invoke-WebRequest ($base+[uri]::EscapeDataString($family.File)) -OutFile $font -TimeoutSec 120
 if((Get-Item -LiteralPath $font).Length -lt 1000){throw ('Invalid font download: '+$family.Id)}
 $noticeFolder=Join-Path $notices $family.Id;New-Item -ItemType Directory -Path $noticeFolder -Force|Out-Null;Copy-Item $license $noticeFolder -Force
 $targets=@(Get-ChildItem $assets -Filter '*.ttf' -Recurse|Where-Object {$_.BaseName -match $family.Match})
 foreach($target in $targets){$relative=$target.FullName.Substring($assets.Length+1);$backup=Join-Path $reference $relative;if(!(Test-Path -LiteralPath $backup)){New-Item -ItemType Directory -Path (Split-Path $backup -Parent) -Force|Out-Null;Copy-Item -LiteralPath $target.FullName -Destination $backup};Copy-Item -LiteralPath $font -Destination $target.FullName -Force}
 $records+=@{family=$family.Id;source=$base+[uri]::EscapeDataString($family.File);licenseUrl=$base+'OFL.txt';license='OFL-1.1';sha256=(Get-FileHash -LiteralPath $font -Algorithm SHA256).Hash;usedPaths=@($targets|ForEach-Object {$_.FullName.Substring($assets.Length+1)});downloadedUtc=[DateTime]::UtcNow.ToString('O')}
 'Verified OFL and replaced '+$family.Id+': '+$targets.Count+' font files'
}
$records|ConvertTo-Json -Depth 6|Set-Content (Join-Path $recoveryRoot 'Evidence\licensed-fonts.json') -Encoding utf8
