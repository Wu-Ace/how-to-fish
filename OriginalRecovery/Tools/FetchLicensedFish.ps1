$ErrorActionPreference='Stop'
$recoveryRoot=Split-Path $PSScriptRoot -Parent
$folder=Join-Path $recoveryRoot 'RecoveredProject\ExportedProject\Assets\ThirdPartyLicensed\QuaterniusAnimatedFish'
New-Item -ItemType Directory -Path $folder -Force|Out-Null
$models=@(
 @{Name='Dolphin.fbx';Id='1go5_SFLW93ke-M1mjB-NyyQOGLvmlYVe'},
 @{Name='Fish1.fbx';Id='11ce4zeSgSk4FeO81mOv-sgrYhRlaBmHz'},
 @{Name='Fish2.fbx';Id='1Y2KfJrVq-FZ2aPzHe1NCJvBX_AsVKC6Q'},
 @{Name='Fish3.fbx';Id='1IhETkaj4bssjH3lNmxvSW7VwW8uCcM0C'},
 @{Name='Manta ray.fbx';Id='1rS0aoM_-e0SZJIFJgcyJkbC1bpGnFzdH'},
 @{Name='Shark.fbx';Id='1KDMkQoY97oRGvAt1BEV5bLJ3hfm1aHiW'},
 @{Name='Whale.fbx';Id='1h6v3BFzlfFSHfRvfVTJ3Ezyz7shJ-57T'}
)
$records=@()
foreach($model in $models){$url='https://drive.google.com/uc?export=download&id='+$model.Id;$target=Join-Path $folder $model.Name;Invoke-WebRequest $url -OutFile $target -TimeoutSec 90;$bytes=[IO.File]::ReadAllBytes($target);if($bytes.Length -lt 1000 -or [Text.Encoding]::ASCII.GetString($bytes,0,[Math]::Min(40,$bytes.Length)) -notmatch 'Kaydara FBX|FBXHeaderExtension'){throw ('Not an FBX download: '+$model.Name)};$records+=@{name=$model.Name;downloadUrl=$url;sha256=(Get-FileHash -LiteralPath $target).Hash;license='CC0-1.0';author='Quaternius';sourcePage='https://quaternius.com/packs/animatedfish.html';originalGameProvenanceConfirmed=$false};'Verified CC0 upstream model: '+$model.Name}
$notice="Animated Fish Pack by Quaternius`nSource: https://quaternius.com/packs/animatedfish.html`nLicense: CC0 1.0 Universal`nLicense URL: https://creativecommons.org/publicdomain/zero/1.0/`nAuthor page explicitly permits personal and commercial projects.`nThese are licensed replacement candidates; they are not proven to be How to Fish's original asset source.`n"
[IO.File]::WriteAllText((Join-Path $folder 'SOURCE-AND-LICENSE.txt'),$notice)
$records|ConvertTo-Json -Depth 5|Set-Content (Join-Path $recoveryRoot 'Evidence\licensed-fish-models.json') -Encoding utf8
