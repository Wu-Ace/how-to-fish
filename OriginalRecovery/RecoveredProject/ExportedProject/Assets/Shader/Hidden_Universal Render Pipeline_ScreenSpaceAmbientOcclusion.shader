Shader "Hidden/Universal Render Pipeline/ScreenSpaceAmbientOcclusion"
{
    HLSLINCLUDE
        #pragma editor_sync_compilation
        #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        Cull Off
        ZWrite Off
        ZTest Always

        // ------------------------------------------------------------------
        // Ambient Occlusion
        // ------------------------------------------------------------------

        // 0 - Occlusion estimation
        Pass
        {
            Name "SSAO_Occlusion"
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment SSAO






                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"
            ENDHLSL
        }

        // ------------------------------------------------------------------
        // Bilateral Blur
        // ------------------------------------------------------------------

        // 1 - Horizontal
        Pass
        {
            Name "SSAO_Bilateral_HorizontalBlur"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment HorizontalBlur
                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"
            ENDHLSL
        }

        // 2 - Vertical
        Pass
        {
            Name "SSAO_Bilateral_VerticalBlur"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment VerticalBlur
                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"
            ENDHLSL
        }

        // 3 - Final
        Pass
        {
            Name "SSAO_Bilateral_FinalBlur"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment FinalBlur
                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"
            ENDHLSL
        }

        // 4 - After Opaque
        Pass
        {
            Name "SSAO_Bilateral_FinalBlur_AfterOpaque"

            ZTest Off
            ZWrite Off
            Cull Off
            Blend One SrcAlpha, Zero One
            BlendOp Add, Add

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment FragBilateralAfterOpaque

                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"

                half4 FragBilateralAfterOpaque(Varyings input) : SV_Target
                {
                    half ao = FinalBlur(input).r;
                    return half4(0.0, 0.0, 0.0, ao);
                }

            ENDHLSL
        }

        // ------------------------------------------------------------------
        // Gaussian Blur
        // ------------------------------------------------------------------

        // 5 - Horizontal
        Pass
        {
            Name "SSAO_Gaussian_HorizontalBlur"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment HorizontalGaussianBlur
                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"
            ENDHLSL
        }

        // 6 - Vertical
        Pass
        {
            Name "SSAO_Gaussian_VerticalBlur"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment VerticalGaussianBlur
                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"
            ENDHLSL
        }

        // 7 - After Opaque
        Pass
        {
            Name "SSAO_Gaussian_VerticalBlur_AfterOpaque"

            ZTest Off
            ZWrite Off
            Cull Off
            Blend One SrcAlpha, Zero One
            BlendOp Add, Add

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment FragGaussianAfterOpaque

                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"

                half4 FragGaussianAfterOpaque(Varyings input) : SV_Target
                {
                    half ao = VerticalGaussianBlur(input).r;
                    return half4(0.0, 0.0, 0.0, ao);
                }

            ENDHLSL
        }

        // ------------------------------------------------------------------
        // Kawase Blur
        // ------------------------------------------------------------------

        // 8 - Kawase Blur
        Pass
        {
            Name "SSAO_Kawase"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment KawaseBlur
                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"
            ENDHLSL
        }

        // 9 - After Opaque Kawase
        Pass
        {
            Name "SSAO_Kawase_AfterOpaque"

            ZTest Off
            ZWrite Off
            Cull Off
            Blend One SrcAlpha, Zero One
            BlendOp Add, Add

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment FragKawaseAfterOpaque

                #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/SSAO.hlsl"

                half4 FragKawaseAfterOpaque(Varyings input) : SV_Target
                {
                    half ao = KawaseBlur(input).r;
                    return half4(0.0, 0.0, 0.0, ao);
                }

            ENDHLSL
        }
    }
}
