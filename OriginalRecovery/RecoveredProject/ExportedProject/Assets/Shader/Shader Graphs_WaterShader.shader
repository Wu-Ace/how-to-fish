Shader "Shader Graphs/WaterShader" {
	Properties {
		[ToggleUI] _Testing ("Testing", Float) = 0
		_DeepColor ("Deep Color", Vector) = (0.03921569,0.09803922,0.2745098,0.7058824)
		_DeepColor_1 ("Deep Color 2", Vector) = (0.03921569,0.09803922,0.2745098,0.7058824)
		Color_93e06cd551a5449091bcde90b46765a0 ("Shallow Color", Vector) = (0.03804734,0.5490196,0.5490196,0.1960784)
		Color_1 ("Shallow Color 2", Vector) = (0.03804734,0.5490196,0.5490196,0.1960784)
		_Pixels ("Pixels", Float) = 0
		_Color_Noise_Scale ("Color Noise Scale", Float) = 0
		Vector1_6f56a0970372485390c6587863c2374e ("Depth", Float) = -3.5
		Vector1_6c82dffdd68049bcb019d3a9c64c92a0 ("Depth Strenght", Range(0, 2)) = 0.2
		Vector1_6269b1025b26473ca8bc61634f34b537 ("Smoothness", Range(0, 1)) = 0.95
		_Wave_Frequency_1 ("Wave Frequency 1", Float) = 1
		_Gradient_Speed_1 ("Gradient Speed 1", Float) = 1
		_Wave_Direction_1 ("Wave Direction 1", Vector) = (1,0,0,0)
		_Wave_Height_1 ("Wave Height 1", Float) = 0
		_Peak_1 ("Peak 1", Float) = 1
		_Wave_Frequency_2 ("Wave Frequency 2", Float) = 1
		_Gradient_Speed_2 ("Gradient Speed 2", Float) = 1
		_Wave_Direction_2 ("Wave Direction 2", Vector) = (1,0,0,0)
		_Wave_Height_2 ("Wave Height 2", Float) = 0
		_Peak_2 ("Peak 2", Float) = 1
		_Foam_Amount ("Foam Amount", Float) = 40
		_Foam_Threshold ("Foam Threshold", Float) = 50
		_Foam_Speed ("Foam Speed", Float) = 0.05
		_Foam_Scale ("Foam Scale", Float) = 200
		_Foam_Color ("Foam Color", Vector) = (1,1,1,1)
		[NoScaleOffset] _Normal_Bumps_Map ("Normal Bumps Map", 2D) = "white" {}
		_Normal_Bumps_Strength ("Normal Bumps Strength", Range(0, 1)) = 0.2
		_Normal_Bumps_Fade_Speed ("Normal Bumps Fade Speed", Float) = 1
		_Normal_Bumps_Scale ("Normal Bumps Scale", Vector) = (1,2,0,0)
		_Normal_Bumps_2_Offset ("Normal Bumps 2 Offset", Float) = 100
		_Specular_Smoothness ("Specular Smoothness", Range(0, 1)) = 0
		[HDR] _Specular_Color ("Specular Color", Vector) = (0,0,0,1)
		_Specular_SmoothStep ("Specular SmoothStep", Vector) = (0,1,0,0)
		[HideInInspector] _QueueOffset ("_QueueOffset", Float) = 0
		[HideInInspector] _QueueControl ("_QueueControl", Float) = -1
		[HideInInspector] [NoScaleOffset] unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" {}
	}
	
 SubShader { Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" "Queue"="Geometry-10" }
 Pass { Tags {"LightMode"="UniversalForwardOnly"} Cull Off
 CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #pragma multi_compile_fog
 #include "UnityCG.cginc"
 float4 _DeepColor,_Ripple_Color;float _Displacement;
 struct app {float4 vertex:POSITION;};struct vary {float4 pos:SV_POSITION;float3 world:TEXCOORD0;UNITY_FOG_COORDS(1)};
 vary vert(app v){vary o;float3 p=mul(unity_ObjectToWorld,v.vertex).xyz;p.y+=sin(p.x*.21+p.z*.15+_Time.y*.8)*_Displacement+sin(p.x*.39-p.z*.27+_Time.y*.45)*_Displacement*.4;o.world=p;o.pos=mul(UNITY_MATRIX_VP,float4(p,1));UNITY_TRANSFER_FOG(o,o.pos);return o;}
 fixed4 frag(vary i):SV_Target {float3 n=normalize(cross(ddy(i.world),ddx(i.world)));n*=sign(n.y);float3 view=normalize(_WorldSpaceCameraPos-i.world);float fres=pow(1-saturate(dot(n,view)),3);float shade=saturate(dot(n,normalize(float3(.4,1,.3))));float3 blue=lerp(_DeepColor.rgb,float3(.24,.51,.69),.38+shade*.3);blue*=.85+.25*frac(sin(dot(floor(i.world.xz*.3),float2(12.98,78.23)))*43758.5);fixed4 c=float4(lerp(blue,float3(.43,.64,.78),fres*.55),1);UNITY_APPLY_FOG(i.fogCoord,c);return c;}
 ENDCG
 }}
}