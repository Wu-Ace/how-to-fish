Shader "Shader Graphs/CharacterShader" {
	Properties {
		[NoScaleOffset] _Colors ("Colors", 2D) = "white" {}
		[NoScaleOffset] _Normal_Map ("Normal Map", 2D) = "white" {}
		_Normal_Strength ("Normal Strength", Range(0, 1)) = 1
		_Normal_Scale ("Normal Scale", Float) = 0.2
		_SkinColor ("SkinColor", Vector) = (0,0,0,0)
		_PrimaryColor ("PrimaryColor", Vector) = (0,0,0,0)
		_SecondColor ("SecondColor", Vector) = (0,0,0,0)
		_ThirdColor ("ThirdColor", Vector) = (0,0,0,0)
		_NormalInfluence ("NormalInfluence", Float) = 0
		_SSSPower ("SSSPower", Float) = 0
		_SSSIntensity ("SSSIntensity", Float) = 0
		_SSSColor ("SSSColor", Vector) = (0,0,0,1)
		_Thickness ("Thickness", Float) = 0
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
 // Recovery character palette: original customization vectors store palette UVs, not RGB.
 float4 _SkinColor,_PrimaryColor,_SecondColor,_ThirdColor;sampler2D _Colors; float _Emission,_Cookness,_Use_Skin;float4 _CookColor,_BurntColor,_Color_Offset,_Color_Offset_2;
 float4 _MainLightPosition,_MainLightColor;
 struct app {float4 vertex:POSITION;float3 normal:NORMAL;float2 uv:TEXCOORD0;float4 color:COLOR;};
 struct vary {float4 pos:SV_POSITION;float2 uv:TEXCOORD0;float3 n:TEXCOORD1;float3 world:TEXCOORD2;UNITY_FOG_COORDS(3)};
 vary vert(app v){vary o;o.world=mul(unity_ObjectToWorld,v.vertex).xyz;o.pos=UnityObjectToClipPos(v.vertex);o.uv=v.uv;o.n=UnityObjectToWorldNormal(v.normal);UNITY_TRANSFER_FOG(o,o.pos);return o;}
 fixed4 frag(vary i):SV_Target {float3 n=normalize(i.n);float3 c=tex2D(_Colors,i.uv).rgb;
 float skin=step(.75,c.r)*step(.55,c.g)*(1-step(.15,c.b));
 float2 skinUV=dot(_SkinColor.xy,_SkinColor.xy)>.0001?frac(_SkinColor.xy):float2(.97,.27);
 c=lerp(c,tex2D(_Colors,skinUV).rgb,skin);
 if(_PrimaryColor.z>.5&&c.r>.8&&c.g<.15&&c.b<.15)c=tex2D(_Colors,frac(_PrimaryColor.xy)).rgb;
 if(_SecondColor.z>.5&&c.g>.8&&c.r<.15&&c.b<.15)c=tex2D(_Colors,frac(_SecondColor.xy)).rgb;
 if(_ThirdColor.z>.5&&c.b>.8&&c.r<.15&&c.g<.15)c=tex2D(_Colors,frac(_ThirdColor.xy)).rgb;
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