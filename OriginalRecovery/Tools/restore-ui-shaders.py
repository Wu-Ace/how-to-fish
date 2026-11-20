from pathlib import Path
import re,tarfile
root=Path(__file__).resolve().parents[1];out=root/'RecoveredProject/ExportedProject/Assets/Shader';backup=root/'Evidence/ShaderOriginals';backup.mkdir(exist_ok=True)
package=Path(r'E:/UnityHub/6000.3.26f1/Editor/Data/Resources/PackageManager/BuiltInPackages/com.unity.ugui/Package Resources/TMP Essential Resources.unitypackage')
exported={}
for p in (root/'RecoveredProject/ExportedProject/Assets').rglob('*.shader'):
 m=re.search(r'Shader\s+"([^"]+)"',p.read_text(encoding='utf-8-sig'))
 if m:exported.setdefault(m[1],[]).append(p)
tmp_dirs={p.parent for name,paths in exported.items() if name.startswith('TextMeshPro/') for p in paths}
with tarfile.open(package,'r:gz') as t:
 for member in t.getmembers():
  if not member.name.endswith('/pathname'):continue
  name=t.extractfile(member).read().decode().strip();prefix=member.name.rsplit('/',1)[0]
  if not name.endswith(('.shader','.cginc')):continue
  try:data=t.extractfile(prefix+'/asset').read()
  except KeyError:continue
  if name.endswith('.cginc'):
   for folder in tmp_dirs:(folder/Path(name).name).write_bytes(data)
   continue
  m=re.search(rb'Shader\s+"([^"]+)"',data)
  if m and m[1].decode() in exported:
   for p in exported[m[1].decode()]:
    if not (backup/p.name).exists():(backup/p.name).write_bytes(p.read_bytes())
    p.write_bytes(data)
ui=r'''
 SubShader {Tags {"Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" "CanUseSpriteAtlas"="True"}
 Stencil {Ref [_Stencil] Comp [_StencilComp] Pass [_StencilOp] ReadMask [_StencilReadMask] WriteMask [_StencilWriteMask]}
 Cull Off Lighting Off ZWrite Off ZTest [unity_GUIZTestMode] Blend SrcAlpha OneMinusSrcAlpha
 Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
 #include "UnityCG.cginc"
 #include "UnityUI.cginc"
 sampler2D _MainTex;float4 _TextureSampleAdd,_ClipRect,_VignetteColor,_UnderwaterColor;float _Intensity;
 struct app {float4 p:POSITION;float4 color:COLOR;float2 uv:TEXCOORD0;};struct vary {float4 p:SV_POSITION;float4 color:COLOR;float2 uv:TEXCOORD0;float4 world:TEXCOORD1;};
 vary vert(app v){vary o;o.world=v.p;o.p=UnityObjectToClipPos(v.p);o.color=v.color;o.uv=v.uv;return o;}
 fixed4 frag(vary i):SV_Target{fixed4 c=(tex2D(_MainTex,i.uv)+_TextureSampleAdd)*i.color;
 #ifdef RECOVERY_VIGNETTE
 c.rgb=_VignetteColor.rgb;c.a*=saturate(pow(length((i.uv-.5)*2),2)*_Intensity);
 #endif
 #ifdef RECOVERY_UNDERWATER
 c.rgb=_UnderwaterColor.rgb;c.a*=.3;
 #endif
 #ifdef UNITY_UI_CLIP_RECT
 c.a*=UnityGet2DClipping(i.world.xy,_ClipRect);
 #endif
 return c;}
 ENDCG}}
}'''
for filename in ['Shader Graphs_UI.shader','Shader Graphs_UIBlur.shader','Unify_UI_Tinted Blur.shader','Shader Graphs_MapBackground.shader','Shader Graphs_VignetteShader.shader','Shader Graphs_UnderwaterShader.shader','Shader Graphs_ThinkingShader.shader','Shader Graphs_SniperAim.shader','Shader Graphs_MapLine.shader','Shader Graphs_MapObject.shader']:
 p=out/filename
 if not p.exists():continue
 s=p.read_text(encoding='utf-8-sig')
 if '//DummyShaderTextExporter' not in s:continue
 (backup/p.name).write_text(s,encoding='utf-8')
 prefix=s.split('//DummyShaderTextExporter')[0]
 # Shader Graph exports for non-UI blur materials omit standard stencil properties.
 for key,default in [('_Stencil',0),('_StencilComp',8),('_StencilOp',0),('_StencilReadMask',255),('_StencilWriteMask',255)]:
  if not re.search(r'\b'+key+r'\s*\(',prefix):prefix=prefix.replace('Properties {','Properties {\n'+key+' ("'+key+'", Float) = '+str(default),1)
 body=ui
 if 'Vignette' in filename:body=body.replace('#pragma vertex vert','#define RECOVERY_VIGNETTE 1\n #pragma vertex vert')
 if 'Underwater' in filename:body=body.replace('#pragma vertex vert','#define RECOVERY_UNDERWATER 1\n #pragma vertex vert')
 p.write_text(prefix+body,encoding='utf-8')
print('Official TMP shaders/includes and recovered UI shader bodies installed')
