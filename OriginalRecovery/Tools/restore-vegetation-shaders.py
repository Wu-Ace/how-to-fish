from pathlib import Path
root=Path(__file__).resolve().parents[1];out=root/'RecoveredProject/ExportedProject/Assets/Shader'
template=r'''
 SubShader {Tags {"RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"} Cull Off
 Pass {Tags {"LightMode"="UniversalForwardOnly"} CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #pragma multi_compile_fog
 #include "UnityCG.cginc"
 sampler2D _Texture;float4 _Color,_TopColor,_MainLightPosition,_MainLightColor;float _WindSpeed,_WindScale;
 struct app{float4 p:POSITION;float3 n:NORMAL;float2 uv:TEXCOORD0;};struct vary {float4 p:SV_POSITION;float2 uv:TEXCOORD0;float3 n:TEXCOORD1;UNITY_FOG_COORDS(2)};
 vary vert(app v){vary o;float3 w=mul(unity_ObjectToWorld,v.p).xyz;w.x+=sin(_Time.y*max(.5,_WindSpeed)+w.x*.18+w.z*.21)*min(.18,abs(v.p.y)*.015);o.p=mul(UNITY_MATRIX_VP,float4(w,1));o.uv=v.uv;o.n=UnityObjectToWorldNormal(v.n);UNITY_TRANSFER_FOG(o,o.p);return o;}
 fixed4 frag(vary i):SV_Target{float4 tex=tex2D(_Texture,i.uv);clip(tex.a-.1);float3 c=tex.rgb;
 #ifdef RECOVERY_GRASS
 c*=GammaToLinearSpace(lerp(_Color.rgb,_TopColor.rgb,saturate(i.uv.y)));
 #endif
 float light=.55+.45*saturate(dot(normalize(i.n),normalize(_MainLightPosition.xyz)));fixed4 col=float4(c*light,1);UNITY_APPLY_FOG(i.fogCoord,col);return col;}
 ENDCG} UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"}
}'''
for name in ['WindyDefault','WindyDecorations','Grass']:
 p=out/('Shader Graphs_'+name+'.shader');s=p.read_text(encoding='utf-8-sig')
 if '//DummyShaderTextExporter' not in s:continue
 (root/'Evidence/ShaderOriginals'/p.name).write_text(s,encoding='utf-8');body=template
 if name!='WindyDefault':body=body.replace('#pragma vertex vert','#define RECOVERY_GRASS 1\n #pragma vertex vert')
 p.write_text(s.split('//DummyShaderTextExporter')[0]+body,encoding='utf-8')
p=out/'Shader Graphs_UIBlur.shader';s=p.read_text(encoding='utf-8-sig');s=s.replace('float _Intensity;','float _Intensity;float4 _Color;');s=s.replace('fixed4 c=(tex2D(_MainTex,i.uv)+_TextureSampleAdd)*i.color;','fixed4 c=(tex2D(_MainTex,i.uv)+_TextureSampleAdd)*i.color;c.rgb*=_Color.rgb;c.a*=.24;');p.write_text(s,encoding='utf-8')
print('Recovered vegetation texture shaders and translucent HUD panels')
