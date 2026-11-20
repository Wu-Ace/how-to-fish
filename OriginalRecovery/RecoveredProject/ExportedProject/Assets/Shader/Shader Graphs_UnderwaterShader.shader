Shader "Shader Graphs/UnderwaterShader" {
	Properties {
_StencilWriteMask ("_StencilWriteMask", Float) = 255
_StencilReadMask ("_StencilReadMask", Float) = 255
_StencilOp ("_StencilOp", Float) = 0
_StencilComp ("_StencilComp", Float) = 8
_Stencil ("_Stencil", Float) = 0
		[HideInInspector] [NoScaleOffset] _MainTex ("_MainTex", 2D) = "white" {}
		_UnderwaterColor ("UnderwaterColor", Vector) = (1,1,1,1)
		_Distortion1 ("Distortion1", Range(0, 1)) = 0.1
		_Distortion2 ("Distortion2", Range(0, 1)) = 0.1
		_WaveScale1 ("WaveScale1", Float) = 1
		_WaveScale2 ("WaveScale2", Float) = 1
		_WaveSpeed1 ("WaveSpeed1", Vector) = (0,0,0,0)
		_WaveSpeed2 ("WaveSpeed2", Vector) = (0,0,0,0)
		[HideInInspector] White ("Color", Vector) = (1,1,1,1)
		[HideInInspector] [NoScaleOffset] unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" {}
	}
	
 SubShader {Tags {"Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" "CanUseSpriteAtlas"="True"}
 Stencil {Ref [_Stencil] Comp [_StencilComp] Pass [_StencilOp] ReadMask [_StencilReadMask] WriteMask [_StencilWriteMask]}
 Cull Off Lighting Off ZWrite Off ZTest [unity_GUIZTestMode] Blend SrcAlpha OneMinusSrcAlpha
 Pass {CGPROGRAM
 #define RECOVERY_UNDERWATER 1
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
}