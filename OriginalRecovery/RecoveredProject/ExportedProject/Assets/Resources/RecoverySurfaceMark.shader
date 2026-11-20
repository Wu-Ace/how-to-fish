Shader "Recovery/SurfaceMark"
{
 Properties {_Color("Color",Color)=(.32,.012,.008,.78)}
 SubShader {
 Tags {"RenderPipeline"="UniversalPipeline" "Queue"="Transparent+1" "RenderType"="Transparent"}
 Pass {
 Tags {"LightMode"="SRPDefaultUnlit"}
 Blend SrcAlpha OneMinusSrcAlpha
 ZWrite Off Cull Off Offset -1,-1
 HLSLPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 float4 _Color;
 struct V {float4 pos:SV_POSITION;};
 V vert(float4 position:POSITION){V o;o.pos=UnityObjectToClipPos(position);return o;}
 float4 frag(V i):SV_Target{return _Color;}
 ENDHLSL
 }
 }
}
