Shader "Hidden/Universal Render Pipeline/SubpixelMorphologicalAntialiasing"
{
    Properties
    {
        [HideInInspector] _StencilRef ("_StencilRef", Int) = 64
        [HideInInspector] _StencilMask ("_StencilMask", Int) = 64
    }

    HLSLINCLUDE

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        // Edge detection
        Pass
        {
            Stencil
            {
                WriteMask [_StencilMask]
                Ref [_StencilRef]
                Comp Always
                Pass Replace
            }

            HLSLPROGRAM

                #pragma vertex VertEdge
                #pragma fragment FragEdge
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/PostProcessing/SubpixelMorphologicalAntialiasingBridge.hlsl"

            ENDHLSL
        }

        // Blend Weights Calculation
        Pass
        {
            Stencil
            {
                WriteMask [_StencilMask]
                ReadMask [_StencilMask]
                Ref [_StencilRef]
                Comp Equal
                Pass Replace
            }

            HLSLPROGRAM

                #define USE_FULL_PRECISION_BLIT_TEXTURE 1
                #pragma vertex VertBlend
                #pragma fragment FragBlend
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/PostProcessing/SubpixelMorphologicalAntialiasingBridge.hlsl"

            ENDHLSL
        }

        // Neighborhood Blending
        Pass
        {
            HLSLPROGRAM

                #pragma vertex VertNeighbor
                #pragma fragment FragNeighbor
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/PostProcessing/SubpixelMorphologicalAntialiasingBridge.hlsl"

            ENDHLSL
        }
    }
}
