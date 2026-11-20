from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1];assets=root/'RecoveredProject/ExportedProject/Assets';out=assets/'ComputeShader';backup=root/'Evidence/ComputeOriginals';backup.mkdir(exist_ok=True)
builtin=Path(r'E:/UnityHub/6000.3.26f1/Editor/Data/Resources/PackageManager/BuiltInPackages')
packages=['com.unity.render-pipelines.core','com.unity.render-pipelines.universal','com.unity.render-pipelines.universal-config']
changed=[]
for package in packages:
 base=builtin/package
 for p in base.rglob('*.compute'):
  old=out/(p.stem+'.asset')
  if not old.exists():continue
  meta=old.with_suffix('.asset.meta');guid=re.search(r'^guid: (\w+)',meta.read_text(),re.M)[1]
  data=p.read_text(encoding='utf-8-sig')
  def include(m):
   name=m[1]
   if name.startswith(('Packages/','Assets/')):return m[0]
   f=(p.parent/name).resolve()
   if not f.exists():return m[0]
   try:rel=f.relative_to(base)
   except ValueError:return m[0]
   return '#include "Assets/RecoveryPipeline/'+package+'/'+rel.as_posix()+'"'
  data=re.sub(r'#include\s+"([^"]+)"',include,data)
  for name in packages:data=data.replace('Packages/'+name+'/', 'Assets/RecoveryPipeline/'+name+'/')
  (backup/old.name).write_bytes(old.read_bytes());(backup/meta.name).write_bytes(meta.read_bytes())
  target=out/(p.stem+'.compute');target.write_text(data,encoding='utf-8')
  target.with_suffix('.compute.meta').write_text('fileFormatVersion: 2\nguid: '+guid+'\nComputeShaderImporter:\n  externalObjects: {}\n  currentAPIMask: 4\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n',encoding='utf-8')
  old.unlink();meta.unlink();changed.append(target.name)
(root/'Evidence/compute-shaders.json').write_text(json.dumps({'officialSources':changed,'preservedGuids':True},indent=2),encoding='utf-8')
print('Restored official compute shaders:',len(changed))
