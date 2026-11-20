Shader "FishSandbox/Ocean" { Properties { _Color("Color",Color)=(0.06,0.4,0.5,1) } SubShader { Tags {"RenderType"="Opaque"} Pass { CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 struct app { float4 vertex:POSITION; };struct v2f {float4 pos:SV_POSITION;float3 world:TEXCOORD0;UNITY_FOG_COORDS(1)};
 v2f vert(app v){v2f o;o.world=mul(unity_ObjectToWorld,v.vertex).xyz;o.world.y+=sin(o.world.x*.17+_Time.y)*.2+cos(o.world.z*.23-_Time.y*.7)*.15;o.pos=mul(UNITY_MATRIX_VP,float4(o.world,1));UNITY_TRANSFER_FOG(o,o.pos);return o;}
 fixed4 frag(v2f i):SV_Target {float3 n=normalize(cross(ddy(i.world),ddx(i.world)));float light=saturate(dot(n,normalize(float3(.4,1,.3))));float shade=sin(floor(i.world.x*.25)*17+floor(i.world.z*.25)*31)*.018;fixed4 c=fixed4(lerp(float3(.12,.25,.38),float3(.28,.49,.61),light)+shade,1);UNITY_APPLY_FOG(i.fogCoord,c);return c;}
 ENDCG } } }
