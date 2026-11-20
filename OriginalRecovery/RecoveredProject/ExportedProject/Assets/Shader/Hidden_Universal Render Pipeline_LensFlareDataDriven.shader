Shader "Hidden/Universal Render Pipeline/LensFlareDataDriven"
{
    SubShader
    {
        Tags{ "RenderPipeline" = "UniversalPipeline" }
        
        // Additive
        Pass
        {
            Name "LensFlareAdditive"
            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
            LOD 100

            Blend One One
            ZWrite Off
            Cull Off
            ZTest Always

            HLSLPROGRAM

            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag




            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            #define FLARE_ADDITIVE_BLEND
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/Runtime/PostProcessing/Shaders/LensFlareCommon.hlsl"

            ENDHLSL
        }
        // Screen
        Pass
        {
            Name "LensFlareScreen"
            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
            LOD 100

            Blend One OneMinusSrcColor
            BlendOp Max
            ZWrite Off
            Cull Off
            ZTest Always

            HLSLPROGRAM

            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag




            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            #define FLARE_SCREEN_BLEND
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/Runtime/PostProcessing/Shaders/LensFlareCommon.hlsl"

            ENDHLSL
        }
        // Premultiply
        Pass
        {
            Name "LensFlarePremultiply"
            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
            LOD 100

            Blend One OneMinusSrcAlpha
            ColorMask RGB
            ZWrite Off
            Cull Off
            ZTest Always

            HLSLPROGRAM

            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag




            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            #define FLARE_PREMULTIPLIED_BLEND
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/Runtime/PostProcessing/Shaders/LensFlareCommon.hlsl"

            ENDHLSL
        }
        // Lerp
        Pass
        {
            Name "LensFlareLerp"
            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
            LOD 100

            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            ZWrite Off
            Cull Off
            ZTest Always

            HLSLPROGRAM

            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag




            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            #define FLARE_LERP_BLEND
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/Runtime/PostProcessing/Shaders/LensFlareCommon.hlsl"

            ENDHLSL
        }
        // OcclusionOnly
        Pass
        {
            Name "LensFlareOcclusion"

            Blend Off
            Cull Off
            ZWrite Off
            ZTest Always

            HLSLPROGRAM

            #pragma target 3.0
            #pragma vertex vertOcclusion
            #pragma fragment fragOcclusion
            #pragma exclude_renderers gles

            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            #define FLARE_COMPUTE_OCCLUSION
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.core/Runtime/PostProcessing/Shaders/LensFlareCommon.hlsl"

            ENDHLSL
        }
    }
}
