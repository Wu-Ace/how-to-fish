Shader "Custom/DepthMaskShader" {
	Properties {
	}
	
 SubShader {Tags {"Queue"="Geometry-1" "RenderPipeline"="UniversalPipeline"} Pass {ColorMask 0 ZWrite On
 CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 float4 vert(float4 p:POSITION):SV_POSITION{return UnityObjectToClipPos(p);}float4 frag():SV_Target{return 0;}
 ENDCG}}
}