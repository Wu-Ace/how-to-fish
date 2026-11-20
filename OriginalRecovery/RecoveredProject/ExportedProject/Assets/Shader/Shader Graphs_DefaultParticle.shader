Shader "Shader Graphs/DefaultParticle" {
	Properties {
		_Color ("Color", Vector) = (0,0,0,1)
		[NoScaleOffset] _MainTex ("_MainTex", 2D) = "white" {}
		_AlphaClipping ("AlphaClipping", Range(0, 1)) = 0
		_NoiseStrength ("NoiseStrength", Range(0, 1)) = 0
		_NoiseScale ("NoiseScale", Float) = 0.1
		[NoScaleOffset] _Noise ("Noise", 2D) = "white" {}
		[HideInInspector] _QueueOffset ("_QueueOffset", Float) = 0
		[HideInInspector] _QueueControl ("_QueueControl", Float) = -1
		[HideInInspector] [NoScaleOffset] unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" {}
	}
	
 SubShader {Tags {"Queue"="Transparent" "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline"} Blend SrcAlpha OneMinusSrcAlpha ZWrite Off Cull Off
 Pass {Tags {"LightMode"="UniversalForwardOnly"} CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 sampler2D _MainTex;float4 _Color;float _AlphaClipping;
 struct app {float4 p:POSITION;float4 c:COLOR;float2 uv:TEXCOORD0;};struct vary {float4 p:SV_POSITION;float4 c:COLOR;float2 uv:TEXCOORD0;};vary vert(app v){vary o;o.p=UnityObjectToClipPos(v.p);o.uv=v.uv;o.c=v.c;return o;}
 fixed4 frag(vary i):SV_Target{float4 c=tex2D(_MainTex,i.uv)*i.c*_Color;clip(c.a-_AlphaClipping);return c;}
 ENDCG}}
}