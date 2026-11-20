Shader "Shader Graphs/MapBackground" {
	Properties {
		[HideInInspector] [NoScaleOffset] _MainTex ("_MainTex", 2D) = "white" {}
		[HideInInspector] _Stencil ("_Stencil", Float) = 0
		[HideInInspector] _StencilComp ("_StencilComp", Float) = 8
		[HideInInspector] _StencilOp ("_StencilOp", Float) = 0
		[HideInInspector] _StencilWriteMask ("_StencilWriteMask", Float) = 255
		[HideInInspector] _StencilReadMask ("_StencilReadMask", Float) = 255
		[HideInInspector] _ColorMask ("_ColorMask", Float) = 15
		_GridColor ("GridColor", Vector) = (0.01013041,1,0,1)
		_Pixels ("Pixels", Float) = 1
		_BackgroundColor ("BackgroundColor", Vector) = (0,0,0,1)
		_GridThickness ("GridThickness", Float) = 0.12
		_PlayerOffsetMultiplier ("PlayerOffsetMultiplier", Float) = 4
		_CircleDistanceCheck ("CircleDistanceCheck", Float) = 1
		_CircleSmoothstep ("CircleSmoothstep", Vector) = (0.5,1,0,0)
		[HideInInspector] White ("Color", Vector) = (1,1,1,1)
		[HideInInspector] [NoScaleOffset] unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" {}
	}
	
 SubShader {Tags {"Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" "CanUseSpriteAtlas"="True"}
 Stencil {Ref [_Stencil] Comp [_StencilComp] Pass [_StencilOp] ReadMask [_StencilReadMask] WriteMask [_StencilWriteMask]}
 Cull Off Lighting Off ZWrite Off ZTest [unity_GUIZTestMode] Blend SrcAlpha OneMinusSrcAlpha
 Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
 #include "UnityCG.cginc"
 #include "UnityUI.cginc"
 sampler2D _MainTex;float4 _TextureSampleAdd,_ClipRect;
 struct app {float4 p:POSITION;float4 color:COLOR;float2 uv:TEXCOORD0;};struct vary {float4 p:SV_POSITION;float4 color:COLOR;float2 uv:TEXCOORD0;float4 world:TEXCOORD1;};
 vary vert(app v){vary o;o.world=v.p;o.p=UnityObjectToClipPos(v.p);o.color=v.color;o.uv=v.uv;return o;}
 fixed4 frag(vary i):SV_Target{fixed4 c=(tex2D(_MainTex,i.uv)+_TextureSampleAdd)*i.color;
 #ifdef UNITY_UI_CLIP_RECT
 c.a*=UnityGet2DClipping(i.world.xy,_ClipRect);
 #endif
 return c;}
 ENDCG}}
}