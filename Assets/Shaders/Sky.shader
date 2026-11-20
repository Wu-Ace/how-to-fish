Shader "FishSandbox/Sky" { Properties {_Sunset("Sunset",Range(0,1))=0} SubShader {Tags {"Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox"} Cull Off ZWrite Off Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 float _Sunset;
 struct v2f {float4 pos:SV_POSITION;float3 dir:TEXCOORD0;};v2f vert(float4 v:POSITION){v2f o;o.pos=UnityObjectToClipPos(v);o.dir=v.xyz;return o;}
 float hash(float2 p){return frac(sin(dot(p,float2(127.1,311.7)))*43758.5453);}float noise(float2 p){float2 a=floor(p),f=frac(p);f=f*f*(3-2*f);return lerp(lerp(hash(a),hash(a+float2(1,0)),f.x),lerp(hash(a+float2(0,1)),hash(a+1),f.x),f.y);}
 fixed4 frag(v2f i):SV_Target{float3 d=normalize(i.dir);float h=saturate(d.y);float3 top=lerp(float3(.22,.39,.6),float3(.36,.24,.4),_Sunset),horizon=lerp(float3(.66,.77,.82),float3(.98,.57,.31),_Sunset);float3 c=lerp(horizon,top,pow(h,.45));float2 uv=d.xz/max(.12,d.y)*2.5;float cloud=noise(floor((uv+_Time.y*.015)*5)/5)*.65+noise(uv*2)*.35;float mask=smoothstep(.58,.78,cloud)*smoothstep(0,.18,d.y);c=lerp(c,lerp(float3(.85,.87,.86),float3(.85,.53,.43),_Sunset),mask*.65);return float4(c,1);}
 ENDCG } } }
