Shader "Shader Graphs/MapLine" {
	Properties {
		[HideInInspector] [NoScaleOffset] _MainTex ("_MainTex", 2D) = "white" {}
		_Thinness ("Thinness", Float) = 31.76
		_Angle ("Angle", Float) = 0
		_RightMaskOffset ("RightMaskOffset", Float) = -0.25
		_ButtomMaskOffset ("ButtomMaskOffset", Float) = 0
		_Speed ("Speed", Float) = 0
		_Distance_Step ("Distance Step", Float) = 1
		_CircleSmoothstep ("CircleSmoothstep", Vector) = (0,0,0,0)
		_LineSmoothstep ("LineSmoothstep", Vector) = (0,0,0,0)
		[HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
		[HideInInspector] _Stencil ("Stencil ID", Float) = 0
		[HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
		[HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
		[HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
		[HideInInspector] _ColorMask ("ColorMask", Float) = 15
		[HideInInspector] _ClipRect ("ClipRect", Vector) = (0,0,0,0)
		[HideInInspector] _UIMaskSoftnessX ("UIMaskSoftnessX", Float) = 1
		[HideInInspector] _UIMaskSoftnessY ("UIMaskSoftnessY", Float) = 1
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