param([string]$GameRoot='E:\SteamLibrary\steamapps\common\How to Fish\How to Fish')
$ErrorActionPreference='Stop'
$runtime=Join-Path $PSScriptRoot 'Builds\OriginalRuntime'
$data=Join-Path $runtime 'How to Fish_Data'
Copy-Item (Join-Path $PSScriptRoot 'Recompiled\Assembly-CSharp.Patched.dll') (Join-Path $data 'Managed\Assembly-CSharp.dll') -Force
Copy-Item (Join-Path $PSScriptRoot 'Recompiled\RecoveryExtension.dll') (Join-Path $data 'Managed\RecoveryExtension.dll') -Force
$init=Get-Content (Join-Path $GameRoot 'How to Fish_Data\RuntimeInitializeOnLoads.json') -Raw|ConvertFrom-Json
$init.root=@($init.root)+@{assemblyName='RecoveryExtension';nameSpace='';className='RecoveryGiftPanel';methodName='Install';loadTypes=0;isUnityClass=$false}
$init|ConvertTo-Json -Compress -Depth 8|Set-Content (Join-Path $data 'RuntimeInitializeOnLoads.json') -Encoding utf8
$assemblies=Get-Content (Join-Path $GameRoot 'How to Fish_Data\ScriptingAssemblies.json') -Raw|ConvertFrom-Json
if($assemblies.names -notcontains 'RecoveryExtension.dll'){$assemblies.names=@($assemblies.names)+'RecoveryExtension.dll';$assemblies.types=@($assemblies.types)+16}
$assemblies|ConvertTo-Json -Compress -Depth 8|Set-Content (Join-Path $data 'ScriptingAssemblies.json') -Encoding utf8
'Recovered runtime prepared. Original game files remain unchanged.'
