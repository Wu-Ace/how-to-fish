Shader "Shader Graphs/SlotMachineBackground" {
	Properties {
		[HideInInspector] [NoScaleOffset] _MainTex ("_MainTex", 2D) = "white" {}
		_Emission ("Emission", Float) = 0
		_MainColor ("MainColor", Vector) = (1,1,1,1)
		_SecondColor ("SecondColor", Vector) = (1,1,1,1)
		_Tightness ("Tightness", Float) = 0.75
		_Tiling ("Tiling", Float) = 1
		_TilingSpeed ("TilingSpeed", Vector) = (0.1,0,0,0)
		_WaveSpeed ("WaveSpeed", Vector) = (3,0.1,0,0)
		_WaveAmount ("WaveAmount", Float) = 0
		_WaveOffset ("WaveOffset", Float) = 0
		_NoiseScale ("NoiseScale", Float) = 1
		_NoiseAmount ("NoiseAmount", Float) = 0.25
		_Tightness2 ("Tightness2", Float) = 0.75
		_Tiling2 ("Tiling2", Float) = 1
		_TilingSpeed2 ("TilingSpeed2", Vector) = (0.1,0,0,0)
		_WaveSpeed2 ("WaveSpeed2", Vector) = (2,0.1,0,0)
		_WaveAmount2 ("WaveAmount2", Float) = 0
		_WaveOffset2 ("WaveOffset2", Float) = 0
		_NoiseScale2 ("NoiseScale2", Float) = 1
		_NoiseAmount2 ("NoiseAmount2", Float) = 0.25
		_LineColor1 ("LineColor1", Vector) = (0,0,0,1)
		_LineColor2 ("LineColor2", Vector) = (0,0,0,1)
		_LineColor3 ("LineColor3", Vector) = (0,0,0,1)
		_LineColor4 ("LineColor4", Vector) = (0,0,0,1)
		_Pixels ("Pixels", Float) = 1
		_BackgroundSpeed ("BackgroundSpeed", Float) = 0
		_LineThinness ("LineThinness", Float) = 1
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
 float4 _MainColor,_SecondColor; sampler2D _MainTex;float4 _TextureSampleAdd,_ClipRect;
 struct app {float4 p:POSITION;float4 color:COLOR;float2 uv:TEXCOORD0;};struct vary {float4 p:SV_POSITION;float4 color:COLOR;float2 uv:TEXCOORD0;float4 world:TEXCOORD1;};
 vary vert(app v){vary o;o.world=v.p;o.p=UnityObjectToClipPos(v.p);o.color=v.color;o.uv=v.uv;return o;}
 fixed4 frag(vary i):SV_Target{fixed4 c=(tex2D(_MainTex,i.uv)+_TextureSampleAdd)*i.color; c *= lerp(_MainColor,_SecondColor,smoothstep(.3,.7,frac((i.uv.x+i.uv.y)*5)));
 #ifdef UNITY_UI_CLIP_RECT
 c.a*=UnityGet2DClipping(i.world.xy,_ClipRect);
 #endif
 return c;}
 ENDCG}}
}