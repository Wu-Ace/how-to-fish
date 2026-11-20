Shader "Shader Graphs/WindyDefault" {
	Properties {
		[NoScaleOffset] _Texture ("Texture", 2D) = "white" {}
		_Smoothness ("Smoothness", Float) = 0
		_Metallic ("Metallic", Float) = 0
		_WindFromOrigoSmoothstep ("WindFromOrigoSmoothstep", Vector) = (0,1,0,0)
		_WindSpeed ("WindSpeed", Float) = 2.8
		_WindSpeed2 ("WindSpeed2", Float) = 0.5
		_WindScale ("WindScale", Float) = 0.15
		_WindDensity ("WindDensity", Float) = 0.2
		_NormalInfluence ("NormalInfluence", Float) = 2
		_SSSPower ("SSSPower", Float) = 1.5
		_SSSIntensity ("SSSIntensity", Float) = 2
		_Thickness ("Thickness", Float) = 1
		[NoScaleOffset] _Normal_Map ("Normal Map", 2D) = "white" {}
		_Normal_Strength ("Normal Strength", Range(0, 1)) = 0.146
		_Normal_Scale ("Normal Scale", Float) = 1
		[HideInInspector] _QueueOffset ("_QueueOffset", Float) = 0
		[HideInInspector] _QueueControl ("_QueueControl", Float) = -1
		[HideInInspector] [NoScaleOffset] unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector] [NoScaleOffset] unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" {}
	}
	
 SubShader {Tags {"RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"} Cull Off
 Pass {Tags {"LightMode"="UniversalForwardOnly"} CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #pragma multi_compile_fog
 #include "UnityCG.cginc"
 sampler2D _Texture;float4 _Color,_TopColor,_MainLightPosition,_MainLightColor;float _WindSpeed,_WindScale;
 struct app{float4 p:POSITION;float3 n:NORMAL;float2 uv:TEXCOORD0;};struct vary {float4 p:SV_POSITION;float2 uv:TEXCOORD0;float3 n:TEXCOORD1;UNITY_FOG_COORDS(2)};
 vary vert(app v){vary o;float3 w=mul(unity_ObjectToWorld,v.p).xyz;w.x+=sin(_Time.y*max(.5,_WindSpeed)+w.x*.18+w.z*.21)*min(.18,abs(v.p.y)*.015);o.p=mul(UNITY_MATRIX_VP,float4(w,1));o.uv=v.uv;o.n=UnityObjectToWorldNormal(v.n);UNITY_TRANSFER_FOG(o,o.p);return o;}
 fixed4 frag(vary i):SV_Target{float4 tex=tex2D(_Texture,i.uv);clip(tex.a-.1);float3 c=tex.rgb;
 #ifdef RECOVERY_GRASS
 c*=GammaToLinearSpace(lerp(_Color.rgb,_TopColor.rgb,saturate(i.uv.y)));
 #endif
 float light=.55+.45*saturate(dot(normalize(i.n),normalize(_MainLightPosition.xyz)));fixed4 col=float4(c*light,1);UNITY_APPLY_FOG(i.fogCoord,col);return col;}
 ENDCG} UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"}
}