"""Restore editable shader bodies; retain exported names, GUIDs and material properties.
These are reconstructions, not recovered original Shader Graph source.
"""
from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1]
shaders=root/'RecoveredProject/ExportedProject/Assets/Shader'
backup=root/'Evidence/ShaderOriginals';backup.mkdir(exist_ok=True)
common=r'''
 SubShader { Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
 Pass { Tags { "LightMode"="UniversalForwardOnly" }
 CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #pragma multi_compile_fog
 #pragma shader_feature_local _SKIN_TYPE_GRADIENT_NOISE _SKIN_TYPE_CHECKERBOARD _SKIN_TYPE_VORONOI
 #pragma shader_feature_local _SKIN_AFFECTS_ONLY_METALLIC _SKIN_AFFECTS_ONLY_METALLIC_NOISE _SKIN_AFFECTS_EVERYTHING
 #include "UnityCG.cginc"
 sampler2D _Colors; float _Emission,_Cookness,_Use_Skin;float4 _CookColor,_BurntColor,_Color_Offset,_Color_Offset_2;
 float4 _MainLightPosition,_MainLightColor;
 struct app {float4 vertex:POSITION;float3 normal:NORMAL;float2 uv:TEXCOORD0;float4 color:COLOR;};
 struct vary {float4 pos:SV_POSITION;float2 uv:TEXCOORD0;float3 n:TEXCOORD1;float3 world:TEXCOORD2;UNITY_FOG_COORDS(3)};
 vary vert(app v){vary o;o.world=mul(unity_ObjectToWorld,v.vertex).xyz;o.pos=UnityObjectToClipPos(v.vertex);o.uv=v.uv;o.n=UnityObjectToWorldNormal(v.normal);UNITY_TRANSFER_FOG(o,o.pos);return o;}
 fixed4 frag(vary i):SV_Target {float3 n=normalize(i.n);float3 c=tex2D(_Colors,i.uv).rgb;
 c=lerp(c,c*lerp(float3(1,.65,.3),_CookColor.rgb,.5),saturate(_Cookness));c=lerp(c,float3(.04,.025,.015),saturate(_Cookness-1));
 float noise=frac(sin(dot(floor(i.world.xz*4),float2(12.9898,78.233)))*43758.5453);
 c=lerp(c,saturate(c+lerp(_Color_Offset.rgb,_Color_Offset_2.rgb,noise)),saturate(_Use_Skin));
 float diffuse=saturate(dot(n,normalize(_MainLightPosition.xyz)));float3 light=lerp(float3(.5,.58,.67),max(_MainLightColor.rgb,float3(.7,.7,.7)),diffuse);
 fixed4 col=fixed4(c*(light+_Emission),1);UNITY_APPLY_FOG(i.fogCoord,col);return col;}
 ENDCG
 }
 UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
 }
}'''
water=r'''
 SubShader { Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" "Queue"="Geometry-10" }
 Pass { Tags {"LightMode"="UniversalForwardOnly"} Cull Off
 CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #pragma multi_compile_fog
 #include "UnityCG.cginc"
 float4 _DeepColor,_Ripple_Color;float _Displacement;
 struct app {float4 vertex:POSITION;};struct vary {float4 pos:SV_POSITION;float3 world:TEXCOORD0;UNITY_FOG_COORDS(1)};
 vary vert(app v){vary o;float3 p=mul(unity_ObjectToWorld,v.vertex).xyz;p.y+=sin(p.x*.21+p.z*.15+_Time.y*.8)*_Displacement+sin(p.x*.39-p.z*.27+_Time.y*.45)*_Displacement*.4;o.world=p;o.pos=mul(UNITY_MATRIX_VP,float4(p,1));UNITY_TRANSFER_FOG(o,o.pos);return o;}
 fixed4 frag(vary i):SV_Target {float3 n=normalize(cross(ddy(i.world),ddx(i.world)));n*=sign(n.y);float3 view=normalize(_WorldSpaceCameraPos-i.world);float fres=pow(1-saturate(dot(n,view)),3);float shade=saturate(dot(n,normalize(float3(.4,1,.3))));float3 blue=lerp(_DeepColor.rgb,float3(.24,.51,.69),.38+shade*.3);blue*=.85+.25*frac(sin(dot(floor(i.world.xz*.3),float2(12.98,78.23)))*43758.5);fixed4 c=float4(lerp(blue,float3(.43,.64,.78),fres*.55),1);UNITY_APPLY_FOG(i.fogCoord,c);return c;}
 ENDCG
 }}
}'''
sky=r'''
 SubShader {Tags {"Queue"="Background" "RenderType"="Background" "RenderPipeline"="UniversalPipeline"} Cull Off ZWrite Off
 Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 float4 _TopDayColor,_BottomDayColor;float _SkyBands;
 struct vary{float4 pos:SV_POSITION;float3 dir:TEXCOORD0;};
 vary vert(float4 p:POSITION){vary o;o.pos=UnityObjectToClipPos(p);o.dir=mul(unity_ObjectToWorld,p).xyz-_WorldSpaceCameraPos;return o;}
 fixed4 frag(vary i):SV_Target{float3 d=normalize(i.dir);float t=pow(saturate(d.y),.65);float3 c=lerp(_BottomDayColor.rgb,_TopDayColor.rgb,t);float cloud=sin(d.x*32+d.z*21+_Time.y*.01)*sin(d.z*45-d.x*17);c=lerp(c,float3(.8,.87,.92),saturate(cloud-.3)*.16*(1-t));return float4(c,1);}
 ENDCG}}
}'''
changed=[]
for p in shaders.glob('Shader Graphs_*.shader'):
 s=p.read_text(encoding='utf-8-sig')
 if '//DummyShaderTextExporter' not in s:continue
 body=None
 if p.stem=='Shader Graphs_WaterShader':body=water
 elif p.stem=='Shader Graphs_SkyboxShader':body=sky
 elif re.search(r'\b_Colors\s*\(',s):body=common
 if body:
  (backup/p.name).write_text(s,encoding='utf-8')
  p.write_text(s.split('//DummyShaderTextExporter')[0]+body,encoding='utf-8');changed.append(p.name)
(root/'Evidence/shader-body-restoration.json').write_text(json.dumps({'reconstructed':changed,'originalGraphsRecovered':False},indent=2),encoding='utf-8')
print('Reconstructed shader bodies:',len(changed))
