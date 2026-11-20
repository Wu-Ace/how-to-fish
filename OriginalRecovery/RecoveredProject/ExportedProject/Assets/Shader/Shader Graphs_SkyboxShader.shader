Shader "Shader Graphs/SkyboxShader" {
	Properties {
		_SkyPixels ("SkyPixels", Vector) = (1,1,0,0)
		[HDR] _TopDayColor ("TopDayColor", Vector) = (0,0.4660978,1,1)
		[HDR] _TopNightColor ("TopNightColor", Vector) = (0,0.4660978,1,1)
		[HDR] _BottomDayColor ("BottomDayColor", Vector) = (0.2627451,0.5764706,1,1)
		[HDR] _BottomSunriseColor ("BottomSunriseColor", Vector) = (2.996079,1.050501,0,1)
		[HDR] _BottomNightColor ("BottomNightColor", Vector) = (0.01960784,0.01960784,0.01960784,1)
		_SkyNoiseStrength ("SkyNoiseStrength", Range(0, 1)) = 1
		_SkyBands ("SkyBands", Float) = 6
		_SkyNoiseScale ("SkyNoiseScale", Vector) = (10,10,0,0)
		_SunStep ("SunStep", Range(0, 1)) = 0.5
		_SunPixels ("SunPixels", Float) = 4
		[HDR] _SunColor ("SunColor", Vector) = (1,0.9787216,0.6226415,1)
		_SunIntensity ("SunIntensity", Float) = 8
		_MoonRadius ("MoonRadius", Range(0, 100)) = 0
		[HDR] _MoonColor ("MoonColor", Vector) = (0.5660378,0.5660378,0.5660378,1)
		_MoonIntensity ("MoonIntensity", Float) = 1
		[HideInInspector] _QueueOffset ("_QueueOffset", Float) = 0
		[HideInInspector] _QueueControl ("_QueueControl", Float) = -1
		[HideInInspector] [NoScaleOffset] unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" {}
	}
	
 SubShader {Tags {"Queue"="Background" "RenderType"="Background" "RenderPipeline"="UniversalPipeline"} Cull Off ZWrite Off
 Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 float4 _TopDayColor,_BottomDayColor;float _SkyBands;
 struct vary{float4 pos:SV_POSITION;float3 dir:TEXCOORD0;};
 vary vert(float4 p:POSITION){vary o;o.pos=UnityObjectToClipPos(p);o.dir=mul((float3x3)unity_ObjectToWorld,p.xyz);return o;}
 fixed4 frag(vary i):SV_Target{float3 d=normalize(i.dir);float t=pow(saturate(d.y),.65);float3 c=lerp(_BottomDayColor.rgb,_TopDayColor.rgb,t);float cloud=sin(d.x*32+d.z*21+_Time.y*.01)*sin(d.z*45-d.x*17);c=lerp(c,float3(.8,.87,.92),saturate(cloud-.3)*.16*(1-t));return float4(c,1);}
 ENDCG}}
}