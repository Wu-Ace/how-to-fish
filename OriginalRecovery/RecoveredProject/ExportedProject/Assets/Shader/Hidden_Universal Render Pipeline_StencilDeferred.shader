Shader "Hidden/Universal Render Pipeline/StencilDeferred"
{
    Properties {
        _StencilRef ("StencilRef", Int) = 0
        _StencilReadMask ("StencilReadMask", Int) = 0
        _StencilWriteMask ("StencilWriteMask", Int) = 0

        _LitPunctualStencilRef ("LitPunctualStencilWriteMask", Int) = 0
        _LitPunctualStencilReadMask ("LitPunctualStencilReadMask", Int) = 0
        _LitPunctualStencilWriteMask ("LitPunctualStencilWriteMask", Int) = 0

        _SimpleLitPunctualStencilRef ("SimpleLitPunctualStencilWriteMask", Int) = 0
        _SimpleLitPunctualStencilReadMask ("SimpleLitPunctualStencilReadMask", Int) = 0
        _SimpleLitPunctualStencilWriteMask ("SimpleLitPunctualStencilWriteMask", Int) = 0

        _LitDirStencilRef ("LitDirStencilRef", Int) = 0
        _LitDirStencilReadMask ("LitDirStencilReadMask", Int) = 0
        _LitDirStencilWriteMask ("LitDirStencilWriteMask", Int) = 0

        _SimpleLitDirStencilRef ("SimpleLitDirStencilRef", Int) = 0
        _SimpleLitDirStencilReadMask ("SimpleLitDirStencilReadMask", Int) = 0
        _SimpleLitDirStencilWriteMask ("SimpleLitDirStencilWriteMask", Int) = 0

        _ClearStencilRef ("ClearStencilRef", Int) = 0
        _ClearStencilReadMask ("ClearStencilReadMask", Int) = 0
        _ClearStencilWriteMask ("ClearStencilWriteMask", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        // 0 - Stencil pass
        Pass
        {
            Name "Stencil Volume"

            // -------------------------------------
            // Render State Commands
            ZTest LEQual
            ZWrite Off
            ZClip false
            Cull Off
            ColorMask 0

            // -------------------------------------
            // Stencil Settings
            Stencil {
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                CompFront NotEqual
                PassFront Keep
                ZFailFront Invert
                CompBack NotEqual
                PassBack Keep
                ZFailBack Invert
            }

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex Vertex
            #pragma fragment FragWhite

            // -------------------------------------
            // Universal Pipeline keywords

            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/StencilDeferred.hlsl"

            ENDHLSL
        }

        // 1 - Deferred Punctual Light (Lit)
        Pass
        {
            Name "Deferred Punctual Light (Lit)"

            // -------------------------------------
            // Render State Commands
            ZTest GEqual
            ZWrite Off
            ZClip false
            Cull Front
            Blend One One, Zero One
            BlendOp Add, Add

            // -------------------------------------
            // Stencil Settings
            Stencil {
                Ref [_LitPunctualStencilRef]
                ReadMask [_LitPunctualStencilReadMask]
                WriteMask [_LitPunctualStencilWriteMask]
                Comp Equal
                Pass Zero
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
            #pragma vertex Vertex
            #pragma fragment DeferredShading

            // -------------------------------------
            // Defines
            #define _LIT

            // -------------------------------------
            // Universal Pipeline keywords











            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/StencilDeferred.hlsl"

            ENDHLSL
        }

        // 2 - Deferred Punctual Light (SimpleLit)
        Pass
        {
            Name "Deferred Punctual Light (SimpleLit)"

            // -------------------------------------
            // Render State Commands
            ZTest GEqual
            ZWrite Off
            ZClip false
            Cull Front
            Blend One One, Zero One
            BlendOp Add, Add

            // -------------------------------------
            // Stencil Settings
            Stencil {
                Ref [_SimpleLitPunctualStencilRef]
                ReadMask [_SimpleLitPunctualStencilReadMask]
                WriteMask [_SimpleLitPunctualStencilWriteMask]
                CompBack Equal
                PassBack Zero
                FailBack Keep
                ZFailBack Keep
            }

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex Vertex
            #pragma fragment DeferredShading

            // -------------------------------------
            // Defines
            #define _SIMPLELIT

            // -------------------------------------
            // Universal Pipeline keywords











            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/StencilDeferred.hlsl"

            ENDHLSL
        }

        // 3 - Deferred Directional Light (Lit)
        Pass
        {
            Name "Deferred Directional Light (Lit)"

            // -------------------------------------
            // Render State Commands
            ZTest NotEqual
            ZWrite Off
            Cull Off
            Blend One SrcAlpha, Zero One
            BlendOp Add, Add

            // -------------------------------------
            // Stencil Settings
            Stencil {
                Ref [_LitDirStencilRef]
                ReadMask [_LitDirStencilReadMask]
                WriteMask [_LitDirStencilWriteMask]
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
            #pragma vertex Vertex
            #pragma fragment DeferredShading

            // -------------------------------------
            // Defines
            #define _LIT
            #define _DIRECTIONAL

            // -------------------------------------
            // Universal Pipeline keywords













            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/StencilDeferred.hlsl"

            ENDHLSL
        }

        // 4 - Deferred Directional Light (SimpleLit)
        Pass
        {
            Name "Deferred Directional Light (SimpleLit)"

            // -------------------------------------
            // Render State Commands
            ZTest NotEqual
            ZWrite Off
            Cull Off
            Blend One SrcAlpha, Zero One
            BlendOp Add, Add

            // -------------------------------------
            // Stencil Settings
            Stencil {
                Ref [_SimpleLitDirStencilRef]
                ReadMask [_SimpleLitDirStencilReadMask]
                WriteMask [_SimpleLitDirStencilWriteMask]
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
            #pragma vertex Vertex
            #pragma fragment DeferredShading

            // -------------------------------------
            // Universal Pipeline keywords
            #define _SIMPLELIT
            #define _DIRECTIONAL

            // -------------------------------------
            // Universal Pipeline keywords













            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/StencilDeferred.hlsl"

            ENDHLSL
        }

        // 5 - Legacy fog
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

        // 6 - SSAO Only
        // This pass only runs when there is no fullscreen deferred light rendered (no directional light). It will adjust indirect/baked lighting with realtime occlusion
        // by rendering just before deferred shading pass.
        // This pass is also completely discarded from vertex shader when SSAO renderer feature is not enabled.
        Pass
        {
            Name "SSAOOnly"

            // -------------------------------------
            // Render State Commands
            ZTest NotEqual
            ZWrite Off
            Cull Off
            Blend One SrcAlpha, Zero One
            BlendOp Add, Add

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex Vertex
            #pragma fragment FragSSAOOnly

            // -------------------------------------
            // Defines
            #define _SSAO_ONLY

            // -------------------------------------
            // Universal Pipeline keywords


            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/StencilDeferred.hlsl"

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
