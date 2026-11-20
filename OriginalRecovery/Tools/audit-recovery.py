from pathlib import Path
import hashlib,json,datetime
root=Path(__file__).resolve().parents[1]
original=Path(r'E:/SteamLibrary/steamapps/common/How to Fish/How to Fish')
runtime=root/'Builds/OriginalRuntime'
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for part in iter(lambda:f.read(1024*1024),b''):h.update(part)
 return h.hexdigest()
expected={'How to Fish_Data/Managed/Assembly-CSharp.dll','How to Fish_Data/globalgamemanagers','How to Fish_Data/RuntimeInitializeOnLoads.json','How to Fish_Data/ScriptingAssemblies.json'}
records=[];unexpected=[];missing=[]
for f in (original/'How to Fish_Data').rglob('*'):
 if not f.is_file():continue
 rel=f.relative_to(original).as_posix();target=runtime/rel
 if not target.exists():missing.append(rel);continue
 a,b=sha(f),sha(target)
 records.append({'path':rel,'bytes':f.stat().st_size,'originalSha256':a,'runtimeSha256':b,'identical':a==b,'expectedAdaptation':rel in expected})
 if a!=b and rel not in expected:unexpected.append(rel)
sources=[]
for folder in ['RecoverySource','GameSource','Tools']:
 for p in (root/folder).rglob('*'):
  if p.is_file() and p.suffix in ('.cs','.ps1','.py'):sources.append({'path':p.relative_to(root).as_posix(),'sha256':sha(p)})
for name in ['Assembly-CSharp.Patched.dll','RecoveryExtension.dll']:
 p=root/'Recompiled'/name;sources.append({'path':p.relative_to(root).as_posix(),'sha256':sha(p)})
plugins=[]
for f in (original/'BepInEx/plugins').rglob('*.dll'):
 p=runtime/f.relative_to(original)
 plugins.append({'path':f.relative_to(original).as_posix(),'identical':p.exists() and sha(f)==sha(p),'sha256':sha(f)})
assets=root/'RecoveredProject/ExportedProject/Assets'
summary={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'originalRoot':str(original),'runtimeRoot':str(runtime),'editorVersion':'6000.3.26f1','originalEngineVersion':'6000.4.4f1','dataFilesCompared':len(records),'identicalDataFiles':sum(x['identical'] for x in records),'adaptedDataFiles':[x['path'] for x in records if not x['identical']],'unexpectedDifferences':unexpected,'missing':missing,'scenes':len(list((assets/'Scenes').rglob('*.unity'))),'prefabs':len(list(assets.rglob('*.prefab'))),'sourceFiles':len(list((root/'GameSource').rglob('*.cs'))),'plugins':plugins}
(root/'Evidence/recovery-integrity.json').write_text(json.dumps({'summary':summary,'originalData':records,'sourceManifest':sources},ensure_ascii=False,indent=2),encoding='utf-8')
(root/'Evidence/recovery-integrity-summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False))
