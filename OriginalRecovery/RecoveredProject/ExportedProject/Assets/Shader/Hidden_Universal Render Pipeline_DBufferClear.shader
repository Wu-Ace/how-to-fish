Shader "Hidden/Universal Render Pipeline/DBufferClear"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            Name "DBufferClear"
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Fragment


            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

            void Fragment(
                Varyings input,
                OUTPUT_DBUFFER(outDBuffer))
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                outDBuffer0 = half4(0, 0, 0, 1);
#if defined(_DBUFFER_MRT3) || defined(_DBUFFER_MRT2)
                outDBuffer1 = half4(0.5f, 0.5f, 0.5f, 1);
#endif
#if defined(_DBUFFER_MRT3)
                outDBuffer2 = half4(0, 0, 0, 1);
#endif
            }
            ENDHLSL
        }
    }
}
