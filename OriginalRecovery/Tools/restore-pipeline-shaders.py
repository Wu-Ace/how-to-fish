from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1];assets=root/'RecoveredProject/ExportedProject/Assets';out=assets/'Shader';backup=root/'Evidence/ShaderOriginals';backup.mkdir(exist_ok=True)
builtin=Path(r'E:/UnityHub/6000.3.26f1/Editor/Data/Resources/PackageManager/BuiltInPackages')
packages=['com.unity.render-pipelines.core','com.unity.render-pipelines.universal','com.unity.render-pipelines.universal-config']
def rewrite(s):
 for name in packages:s=s.replace('Packages/'+name+'/', 'Assets/RecoveryPipeline/'+name+'/')
 return s
exported={}
for p in out.glob('*.shader'):
 m=re.search(r'Shader\s+"([^"]+)"',p.read_text(encoding='utf-8-sig'))
 if m:exported[m[1]]=p
changed=[]
for package in packages:
 base=builtin/package
 for p in base.rglob('*'):
  if not p.is_file() or p.suffix not in ('.hlsl','.cginc','.shader'):continue
  data=p.read_text(encoding='utf-8-sig')
  if p.suffix=='.shader':
   m=re.search(r'Shader\s+"([^"]+)"',data)
   if not m or m[1] not in exported:continue
   target=exported[m[1]]
   if not (backup/target.name).exists():(backup/target.name).write_bytes(target.read_bytes())
   # Resolve local includes relative to the original official shader location.
   def include(m):
    name=m[1]
    if name.startswith(('Packages/','Assets/')):return '#include "'+rewrite(name)+'"'
    f=(p.parent/name).resolve()
    if not f.exists():return m[0]
    try:rel=f.relative_to(base)
    except ValueError:return m[0]
    return '#include "Assets/RecoveryPipeline/'+package+'/'+rel.as_posix()+'"'
   data=re.sub(r'#include\s+"([^"]+)"',include,data);changed.append(target.name)
  else:
   target=assets/'RecoveryPipeline'/package/p.relative_to(base);target.parent.mkdir(parents=True,exist_ok=True)
  # Imported player DLLs have no editor-side URP variant stripper. Avoid compiling
  # every platform/lighting permutation for these restored infrastructure passes.
  if p.suffix=='.shader' and not any(x in target.name for x in ('CoreBlit','CopyDepth','BlitHDROverlay','CoreCopy','LutBuilder')):
   def strip_variant(m):
    line=m[0]
    if 'UberPost' in target.name and any(k in line for k in ('_HDR_GRADING','_BLOOM_','_GAMMA_20','_USE_FAST_SRGB','_ENABLE_ALPHA','_DITHERING')):return line
    if any(k in target.name for k in ('FinalPost','Scaling Setup')) and any(k in line for k in ('_GAMMA_20','_LINEAR_TO_SRGB','_DITHERING','_ENABLE_ALPHA')):return line
    if target.name=='Universal Render Pipeline_Lit.shader' and any(k in line for k in ('_EMISSION','_ALPHATEST_ON','_SURFACE_TYPE_TRANSPARENT','_ALPHAPREMULTIPLY')):return line
    return ''
   data=re.sub(r'^\s*#pragma\s+(?:multi_compile\S*|shader_feature\S*)[^\n]*',strip_variant,data,flags=re.M)
  target.write_text(rewrite(data),encoding='utf-8')
(root/'Evidence/pipeline-shaders.json').write_text(json.dumps({'officialUnityVersion':'6000.3.26f1','shaderReplacements':changed},indent=2),encoding='utf-8')
print('Official URP/core shader bodies restored:',len(changed))
