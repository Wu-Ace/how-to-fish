from pathlib import Path
root=Path(__file__).resolve().parents[1];out=root/'RecoveredProject/ExportedProject/Assets/Shader'
for p in out.glob('Shader Graphs_*.shader'):
 s=p.read_text(encoding='utf-8-sig')
 if 'light+_Emission' in s:p.write_text(s.replace('light+_Emission','light'),encoding='utf-8')
cloud=r'''
 SubShader {Tags {"Queue"="Background+1" "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline"} Blend SrcAlpha OneMinusSrcAlpha ZWrite Off Cull Off
 Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 float4 _Color,_CloudSpeed;float _CloudScale;
 struct vary {float4 p:SV_POSITION;float3 w:TEXCOORD0;};vary vert(float4 p:POSITION){vary o;o.p=UnityObjectToClipPos(p);o.w=mul(unity_ObjectToWorld,p).xyz-_WorldSpaceCameraPos;return o;}
 fixed4 frag(vary i):SV_Target{float3 d=normalize(i.w);float2 p=d.xz/max(.1,d.y+.25)*3+_Time.y*_CloudSpeed.xy;float n=sin(p.x*4+sin(p.y*3))*sin(p.y*6+sin(p.x*2));float a=smoothstep(.18,.85,n)*.3*saturate(d.y*2+.25);return float4(_Color.rgb,a);}
 ENDCG}}
}'''
particle=r'''
 SubShader {Tags {"Queue"="Transparent" "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline"} Blend SrcAlpha OneMinusSrcAlpha ZWrite Off Cull Off
 Pass {Tags {"LightMode"="UniversalForwardOnly"} CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 sampler2D _MainTex;float4 _Color;float _AlphaClipping;
 struct app {float4 p:POSITION;float4 c:COLOR;float2 uv:TEXCOORD0;};struct vary {float4 p:SV_POSITION;float4 c:COLOR;float2 uv:TEXCOORD0;};vary vert(app v){vary o;o.p=UnityObjectToClipPos(v.p);o.uv=v.uv;o.c=v.c;return o;}
 fixed4 frag(vary i):SV_Target{float4 c=tex2D(_MainTex,i.uv)*i.c*_Color;clip(c.a-_AlphaClipping);return c;}
 ENDCG}}
}'''
depth=r'''
 SubShader {Tags {"Queue"="Geometry-1" "RenderPipeline"="UniversalPipeline"} Pass {ColorMask 0 ZWrite On
 CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 float4 vert(float4 p:POSITION):SV_POSITION{return UnityObjectToClipPos(p);}float4 frag():SV_Target{return 0;}
 ENDCG}}
}'''
for filename,body in [('Shader Graphs_CloudSphereShader.shader',cloud),('Shader Graphs_DefaultParticle.shader',particle),('Custom_DepthMaskShader.shader',depth)]:
 p=out/filename;s=p.read_text(encoding='utf-8-sig')
 if '//DummyShaderTextExporter' in s:
  (root/'Evidence/ShaderOriginals'/p.name).write_text(s,encoding='utf-8');p.write_text(s.split('//DummyShaderTextExporter')[0]+body,encoding='utf-8')
p=root/'GameSource/SteamManager.cs';s=p.read_text(encoding='utf-8-sig');old='public static bool RefreshRelayStatus()\n\t{'
if 'Local offline recovery' not in s:s=s.replace(old,old+'\n        if (RecoveryIsolation.Enabled) { RelayStatus = ESteamNetworkingAvailability.k_ESteamNetworkingAvailability_CannotTry; RelayStatusMessage = "Local offline recovery"; return false; }')
p.write_text(s,encoding='utf-8');(root/'RecoveredProject/ExportedProject/Assets/Scripts/Assembly-CSharp/SteamManager.cs').write_text(s,encoding='utf-8')
p=root/'RecoverySource/RecoveryGiftPanel.cs';s=p.read_text(encoding='utf-8-sig').replace('礼物模块未连接 (6096)','礼物模块未连接 ('+'"+Port+"'+')');p.write_text(s,encoding='utf-8')
print('Restored cloud/particle/depth bodies and reduced inherited material overexposure')
