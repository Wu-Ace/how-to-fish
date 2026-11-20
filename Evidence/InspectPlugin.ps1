param([string]$GameRoot='E:\SteamLibrary\steamapps\common\How to Fish\How to Fish')
Add-Type -Path "$GameRoot\BepInEx\core\Mono.Cecil.dll"
$a=[Mono.Cecil.AssemblyDefinition]::ReadAssembly("$GameRoot\BepInEx\plugins\EmbeddedServer\mods\EmbeddedServer.Mod.dll")
$t=$a.MainModule.Types|Select-Object -Last 1
$data=($t.Fields|Where-Object Name -eq '3').InitialValue
for($i=0;$i -lt $data.Length;$i++){$data[$i]=($data[$i] -bxor $i -bxor 170) -band 255}
$map=[System.Collections.Generic.Dictionary[string,string]]::new([System.StringComparer]::Ordinal)
foreach($m in $t.Methods){if($m.Parameters.Count -eq 0 -and $m.Name -ne '.cctor'){$nums=@($m.Body.Instructions|Where-Object {$_.OpCode.Name -eq 'ldc.i4'}|ForEach-Object Operand);if($nums.Count -eq 4){$map[$m.Name]=[Text.Encoding]::UTF8.GetString($data,$nums[2],$nums[3])}}}
$map.GetEnumerator()|Sort-Object Key|ForEach-Object {"$($_.Key) = $($_.Value)"}|Set-Content Evidence\plugin-decoded-strings.txt
& { foreach($type in $a.MainModule.Types|Select-Object -SkipLast 1){foreach($m in $type.Methods){if($m.HasBody){"`nMETHOD $($type.FullName)::$($m.Name)";foreach($i in $m.Body.Instructions){if($i.OpCode.Name -eq 'call' -and $i.Operand.DeclaringType.FullName -eq $t.FullName){"$($i.Offset): STRING '$($map[$i.Operand.Name])'"}else{$i.ToString()}}}}} } |Set-Content Evidence\plugin-readable-il.txt



