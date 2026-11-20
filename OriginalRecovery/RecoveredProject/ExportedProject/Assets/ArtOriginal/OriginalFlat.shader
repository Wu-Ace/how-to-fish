Shader "ProjectOriginal/FacetedArt"
{
 Properties { _BaseColor("Color",Color)=(1,1,1,1) }
 SubShader
 {
  Tags {"RenderPipeline"="UniversalPipeline" "RenderType"="Opaque"}
  Pass
  {
   Name "Forward" Tags {"LightMode"="UniversalForward"}
   HLSLPROGRAM
   #pragma vertex vert
   #pragma fragment frag
   #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
   #pragma multi_compile_fragment _ _SHADOWS_SOFT
   #pragma multi_compile_fog
   #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
   #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
   CBUFFER_START(UnityPerMaterial)
   half4 _BaseColor;
   CBUFFER_END
   struct Attributes {float4 positionOS:POSITION;float3 normalOS:NORMAL;};
   struct Varyings {float4 positionCS:SV_POSITION;float3 normalWS:TEXCOORD0;float3 positionWS:TEXCOORD1;half fog:TEXCOORD2;};
   Varyings vert(Attributes i){Varyings o;o.positionWS=TransformObjectToWorld(i.positionOS.xyz);o.positionCS=TransformWorldToHClip(o.positionWS);o.normalWS=TransformObjectToWorldNormal(i.normalOS);o.fog=ComputeFogFactor(o.positionCS.z);return o;}
   half4 frag(Varyings i):SV_Target
   {
    half3 n=normalize(i.normalWS);Light l=GetMainLight(TransformWorldToShadowCoord(i.positionWS));
    half diffuse=saturate(dot(n,l.direction));half3 ambient=lerp(half3(.28,.30,.32),half3(.47,.49,.49),saturate(n.y*.5+.5));
    half3 c=_BaseColor.rgb*(ambient+l.color*diffuse*.63*lerp(.28,1,l.shadowAttenuation));
    return half4(MixFog(c,i.fog),1);
   }
   ENDHLSL
  }
  UsePass "Universal Render Pipeline/Lit/ShadowCaster"
  UsePass "Universal Render Pipeline/Lit/DepthOnly"
 }
}
