Shader "Shader Graphs/CookableGlassShader" {
	Properties {
		_Smooth_Step ("Smooth Step", Vector) = (0,0,0,0)
		_Distance_Min_Max ("Distance Min Max", Vector) = (1,5,0,0)
		[NoScaleOffset] _Colors ("Colors", 2D) = "white" {}
		_AlphaMax ("AlphaMax", Float) = 0
		_Normal_Scale ("Normal Scale", Float) = 0.3
		_Normal_Strength ("Normal Strength", Range(0, 1)) = 0.2
		[NoScaleOffset] _Normal_Texture ("Normal Texture", 2D) = "white" {}
		[HideInInspector] _Cookness ("Cookness", Float) = 0
		_CookColor ("CookColor", Vector) = (0,0,0,1)
		_BurntColor ("BurntColor", Vector) = (0,0,0,1)
		[HideInInspector] _WorkflowMode ("_WorkflowMode", Float) = 1
		[HideInInspector] _CastShadows ("_CastShadows", Float) = 1
		[HideInInspector] _ReceiveShadows ("_ReceiveShadows", Float) = 1
		[HideInInspector] _Surface ("_Surface", Float) = 1
		[HideInInspector] _Blend ("_Blend", Float) = 0
		[HideInInspector] _AlphaClip ("_AlphaClip", Float) = 0
		[HideInInspector] _BlendModePreserveSpecular ("_BlendModePreserveSpecular", Float) = 1
		[HideInInspector] _SrcBlend ("_SrcBlend", Float) = 1
		[HideInInspector] _DstBlend ("_DstBlend", Float) = 0
		[HideInInspector] _SrcBlendAlpha ("_SrcBlendAlpha", Float) = 1
		[HideInInspector] _DstBlendAlpha ("_DstBlendAlpha", Float) = 0
		[ToggleUI] [HideInInspector] _ZWrite ("_ZWrite", Float) = 0
		[HideInInspector] _ZWriteControl ("_ZWriteControl", Float) = 0
		[HideInInspector] _ZTest ("_ZTest", Float) = 4
		[HideInInspector] _Cull ("_Cull", Float) = 2
		[HideInInspector] _AlphaToMask ("_AlphaToMask", Float) = 0
		[HideInInspector] _QueueOffset ("_QueueOffset", Float) = 0
		[HideInInspector] _QueueControl ("_QueueControl", Float) = -1
		[HideInInspector] [NoScaleOffset] unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" {}
	}
	
 SubShader { Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
 Pass { Tags { "LightMode"="UniversalForwardOnly" }
 CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #pragma multi_compile_fog
 #pragma shader_feature_local _SKIN_TYPE_GRADIENT_NOISE _SKIN_TYPE_CHECKERBOARD _SKIN_TYPE_VORONOI
 #pragma shader_feature_local _SKIN_AFFECTS_ONLY_METALLIC _SKIN_AFFECTS_ONLY_METALLIC_NOISE _SKIN_AFFECTS_EVERYTHING
 #include "UnityCG.cginc"
 sampler2D _Colors; float _Emission,_Cookness,_Use_Skin;float4 _CookColor,_BurntColor,_Color_Offset,_Color_Offset_2;
 float4 _MainLightPosition,_MainLightColor;
 struct app {float4 vertex:POSITION;float3 normal:NORMAL;float2 uv:TEXCOORD0;float4 color:COLOR;};
 struct vary {float4 pos:SV_POSITION;float2 uv:TEXCOORD0;float3 n:TEXCOORD1;float3 world:TEXCOORD2;UNITY_FOG_COORDS(3)};
 vary vert(app v){vary o;o.world=mul(unity_ObjectToWorld,v.vertex).xyz;o.pos=UnityObjectToClipPos(v.vertex);o.uv=v.uv;o.n=UnityObjectToWorldNormal(v.normal);UNITY_TRANSFER_FOG(o,o.pos);return o;}
 fixed4 frag(vary i):SV_Target {float3 n=normalize(i.n);float3 c=tex2D(_Colors,i.uv).rgb;
 c=lerp(c,c*lerp(float3(1,.65,.3),_CookColor.rgb,.5),saturate(_Cookness));c=lerp(c,float3(.04,.025,.015),saturate(_Cookness-1));
 float noise=frac(sin(dot(floor(i.world.xz*4),float2(12.9898,78.233)))*43758.5453);
 c=lerp(c,saturate(c+lerp(_Color_Offset.rgb,_Color_Offset_2.rgb,noise)),saturate(_Use_Skin));
 float diffuse=saturate(dot(n,normalize(_MainLightPosition.xyz)));float3 light=lerp(float3(.5,.58,.67),max(_MainLightColor.rgb,float3(.7,.7,.7)),diffuse);
 fixed4 col=fixed4(c*(light),1);UNITY_APPLY_FOG(i.fogCoord,col);return col;}
 ENDCG
 }
 UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
 }
}