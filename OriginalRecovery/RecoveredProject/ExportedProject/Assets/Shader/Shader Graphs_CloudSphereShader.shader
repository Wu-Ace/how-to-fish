Shader "Shader Graphs/CloudSphereShader" {
	Properties {
		_CloudHeigth ("CloudHeigth", Float) = 0
		_Pixels ("Pixels", Float) = 1
		[HDR] _Color ("Color", Vector) = (0.7490196,0.7490196,0.7490196,1)
		[HDR] _SSSColor ("SSSColor", Vector) = (1,0.5607843,0,1)
		_NormalInfluence ("NormalInfluence", Float) = 0
		_SSSPower ("SSSPower", Float) = 0
		_SSSIntensity ("SSSIntensity", Float) = 0
		_Thickness ("Thickness", Float) = 0
		_CloudScale ("CloudScale", Float) = 0
		_DetailScale ("DetailScale", Float) = 10
		_CloudSmoothStep ("CloudSmoothStep", Vector) = (0,1,0,0)
		_DetailSmoothStep ("DetailSmoothStep", Vector) = (0,0,0,0)
		_CombinedSmoothStep ("CombinedSmoothStep", Vector) = (0,0,0,0)
		_HeightSmoothStep ("HeightSmoothStep", Vector) = (0,0,0,0)
		_HeigthSmoothStep2 ("HeigthSmoothStep2", Vector) = (0,0,0,0)
		_CloudSpeed ("CloudSpeed", Vector) = (-0.0005,-0.0025,0,0)
		_DetailSpeed ("DetailSpeed", Vector) = (0.015,0.01,0,0)
		[HideInInspector] _QueueOffset ("_QueueOffset", Float) = 0
		[HideInInspector] _QueueControl ("_QueueControl", Float) = -1
		[HideInInspector] [NoScaleOffset] unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" {}
	}
	
 SubShader {Tags {"Queue"="Background+1" "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline"} Blend SrcAlpha OneMinusSrcAlpha ZWrite Off Cull Off
 Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 float4 _Color,_CloudSpeed;float _CloudScale;
 struct vary {float4 p:SV_POSITION;float3 w:TEXCOORD0;};vary vert(float4 p:POSITION){vary o;o.p=UnityObjectToClipPos(p);o.w=mul(unity_ObjectToWorld,p).xyz-_WorldSpaceCameraPos;return o;}
 fixed4 frag(vary i):SV_Target{float3 d=normalize(i.w);float2 p=d.xz/max(.1,d.y+.25)*3+_Time.y*_CloudSpeed.xy;float n=sin(p.x*4+sin(p.y*3))*sin(p.y*6+sin(p.x*2));float a=smoothstep(.18,.85,n)*.3*saturate(d.y*2+.25);return float4(_Color.rgb,a);}
 ENDCG}}
}