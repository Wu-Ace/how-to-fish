// Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
Shader "Hidden/TerrainEngine/Details/UniversalPipeline/BillboardWavingDoublePass"
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
        Tags {"Queue" = "Geometry+200" "RenderType" = "GrassBillBoard" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "DisableBatching" = "True" }
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

            // -------------------------------------
            // Unity defined keywords






            //--------------------------------------
            // GPU Instancing


            #pragma vertex WavingGrassBillboardVert
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

            // -------------------------------------
            // Unity defined keywords



            //--------------------------------------
            // GPU Instancing


            #pragma vertex WavingGrassBillboardVert
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

            #pragma vertex DepthOnlyBillboardVertex
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

        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex DepthNormalOnlyBillboardVertex
            #pragma fragment DepthNormalOnlyFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON


            //--------------------------------------
            // GPU Instancing


            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Terrain/WavingGrassDepthNormalsPass.hlsl"
            ENDHLSL
        }
    }
}
