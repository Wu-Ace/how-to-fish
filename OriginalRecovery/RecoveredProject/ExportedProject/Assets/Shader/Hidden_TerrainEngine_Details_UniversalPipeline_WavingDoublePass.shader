// Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
Shader "Hidden/TerrainEngine/Details/UniversalPipeline/WavingDoublePass"
{
    Properties
    {
        _WavingTint ("Fade Color", Color) = (.7,.6,.5, 0)
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
        _WaveAndDistance ("Wave and distance", Vector) = (12, 3.6, 1, 1)
        _Cutoff ("Cutoff", float) = 0.5
    }
    SubShader
    {
        Tags {"Queue" = "Geometry+200" "RenderType" = "Grass" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "DisableBatching" = "True" }
        Cull Off
        LOD 200

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            AlphaToMask On

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Universal Pipeline keywords












            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"

            // -------------------------------------
            // Unity defined keywords






            //--------------------------------------
            // GPU Instancing

            #pragma instancing_options renderinglayer

            #pragma vertex WavingGrassVert
            #pragma fragment LitPassFragmentGrass
            #define _ALPHATEST_ON

            #if USE_DYNAMIC_BRANCH_FOG_KEYWORD && SHADER_API_VULKAN && SHADER_API_MOBILE
            #define SKIP_SHADOWS_LIGHT_INDEX_CHECK 1
            #endif

            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassPasses.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Universal Pipeline keywords







            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            // -------------------------------------
            // Unity defined keywords







            //--------------------------------------
            // GPU Instancing

            #pragma instancing_options renderinglayer

            #pragma vertex WavingGrassVert
            #pragma fragment LitPassFragmentGrass
            #define _ALPHATEST_ON
            #define TERRAIN_GBUFFER

            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassPasses.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutputFormat.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask R
            Cull Off

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON


            //--------------------------------------
            // GPU Instancing


            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassPasses.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture with the forward renderer or the depthNormal prepass with the deferred renderer.
        Pass
        {
            Name "DepthNormalsOnly"
            Tags{"LightMode" = "DepthNormalsOnly"}

            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex DepthNormalOnlyVertex
            #pragma fragment DepthNormalOnlyFragment

            // -------------------------------------
            // Universal Pipeline keywords
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON


            // -------------------------------------
            // Unity defined keywords


            //--------------------------------------
            // GPU Instancing


            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassDepthNormalsPass.hlsl"
            ENDHLSL
        }
    }
}
