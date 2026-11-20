from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1];assets=root/'RecoveredProject/ExportedProject/Assets'
converted=[]
for base in [root/'GameSource',assets/'Scripts/Assembly-CSharp']:
 for p in base.rglob('*.cs'):
  s=p.read_text(encoding='utf-8-sig')
  m=re.search(r'^namespace\s+([\w.]+);\s*$',s,re.M)
  if m:
   s=s[:m.start()]+'namespace '+m[1]+'\n{\n'+s[m.end():]+'\n}\n';p.write_text(s,encoding='utf-8');converted.append(p.relative_to(root).as_posix())
guids=[]
for p in (assets/'ComputeShader').glob('*.compute.meta'):
 guids.append(re.search(r'^guid: (\w+)',p.read_text(),re.M)[1])
fixed=[]
for p in assets.rglob('*'):
 if p.suffix not in ('.asset','.mat','.prefab','.unity'):continue
 s=p.read_text(encoding='utf-8-sig');before=s
 for guid in guids:s=s.replace('guid: '+guid+', type: 2','guid: '+guid+', type: 3')
 if s!=before:p.write_text(s,encoding='utf-8');fixed.append(p.relative_to(root).as_posix())
(root/'Evidence/source-serialization-repair.json').write_text(json.dumps({'blockNamespaces':converted,'computePptrTypes':fixed},indent=2),encoding='utf-8')
print('Block namespaces:',len(converted),'Compute PPtr repairs:',len(fixed))
