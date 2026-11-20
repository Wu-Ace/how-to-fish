Shader "Hidden/Universal Render Pipeline/ClusterDeferred"
{
    Properties {
        _LitStencilRef ("LitStencilRef", Int) = 0
        _LitStencilReadMask ("LitStencilReadMask", Int) = 0
        _LitStencilWriteMask ("LitStencilWriteMask", Int) = 0

        _SimpleLitStencilRef ("SimpleLitStencilRef", Int) = 0
        _SimpleLitStencilReadMask ("SimpleLitStencilReadMask", Int) = 0
        _SimpleLitStencilWriteMask ("SimpleLitStencilWriteMask", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        // 0 - Clustered Lights - Lit
        Pass
        {
            Name "Deferred Clustered Lights (Lit)"

            // -------------------------------------
            // Render State Commands
            ZTest NotEqual
            ZWrite Off
            Cull Off
            Blend One SrcAlpha, Zero One

            // -------------------------------------
            // Stencil Settings
            Stencil {
                Ref [_LitStencilRef]
                ReadMask [_LitStencilReadMask]
                WriteMask [_LitStencilWriteMask]
                Comp Equal
                Pass Keep
                Fail Keep
                ZFail Keep
            }

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex VertexFullScreen
            #pragma fragment DeferredShadingClustered

            // -------------------------------------
            // Defines
            #define _CLUSTER_LIGHT_LOOP
            #define _LIT

            // -------------------------------------
            // Universal Pipeline keywords











            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/ClusterDeferred.hlsl"

            ENDHLSL
        }

        // 1 - Clustered Lights - SimpleLit
        Pass
        {
            Name "Deferred Clustered Lights (SimpleLit)"

            // -------------------------------------
            // Render State Commands
            ZTest NotEqual
            ZWrite Off
            Cull Off
            Blend One SrcAlpha, Zero One

            // -------------------------------------
            // Stencil Settings
            Stencil {
                Ref [_SimpleLitStencilRef]
                ReadMask [_SimpleLitStencilReadMask]
                WriteMask [_SimpleLitStencilWriteMask]
                Comp Equal
                Pass Keep
                Fail Keep
                ZFail Keep
            }

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex VertexFullScreen
            #pragma fragment DeferredShadingClustered

            // -------------------------------------
            // Defines
            #define _CLUSTER_LIGHT_LOOP
            #define _SIMPLELIT

            // -------------------------------------
            // Universal Pipeline keywords











            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/ClusterDeferred.hlsl"

            ENDHLSL
        }

        // 2 - Legacy fog (reused from StencilDeferred)
        Pass
        {
            Name "Fog"

            // -------------------------------------
            // Render State Commands
            ZTest NotEqual
            ZWrite Off
            Cull Off
            Blend OneMinusSrcAlpha SrcAlpha, Zero One
            BlendOp Add, Add

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex Vertex
            #pragma fragment Frag

            // -------------------------------------
            // Defines
            #define _FOG

            // -------------------------------------
            // Universal Pipeline keywords

            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/FogDeferred.hlsl"

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
