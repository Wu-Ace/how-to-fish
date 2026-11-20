Shader "Hidden/Universal Render Pipeline/XR/XRMirrorView"
{
    SubShader
    {
        Tags{ "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
            // Foveated rendering currently not supported in dxc on metal
            #pragma never_use_dxc metal
        ENDHLSL

        Pass
        {
            ZWrite Off ZTest Always Blend Off Cull Off

            HLSLPROGRAM
                #pragma vertex VertQuad
                #pragma fragment FragBilinear



                #if defined(DISABLE_TEXTURE2D_X_ARRAY)
                #define SRC_TEXTURE2D_X_ARRAY 0
                #else
                #define SRC_TEXTURE2D_X_ARRAY 1
                #endif
                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/XR/XRMirrorView.hlsl"
            ENDHLSL
        }
    }

    Fallback Off
}
