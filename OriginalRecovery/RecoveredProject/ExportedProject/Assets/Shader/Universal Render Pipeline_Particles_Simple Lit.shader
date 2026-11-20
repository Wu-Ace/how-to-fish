// ------------------------------------------
// Only directional light is supported for lit particles
// No shadow
// No distortion
Shader "Universal Render Pipeline/Particles/Simple Lit"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [MainColor]   _BaseColor("Base Color", Color) = (1,1,1,1)

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _SpecGlossMap("Specular", 2D) = "white" {}
        _SpecColor("Specular", Color) = (1.0, 1.0, 1.0)
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        [HDR] _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        _SmoothnessSource("Smoothness Source", Float) = 0.0
        _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0

        // -------------------------------------
        // Particle specific
        _SoftParticlesNearFadeDistance("Soft Particles Near Fade", Float) = 0.0
        _SoftParticlesFarFadeDistance("Soft Particles Far Fade", Float) = 1.0
        _CameraNearFadeDistance("Camera Near Fade", Float) = 1.0
        _CameraFarFadeDistance("Camera Far Fade", Float) = 2.0
        _DistortionBlend("Distortion Blend", Range(0.0, 1.0)) = 0.5
        _DistortionStrength("Distortion Strength", Float) = 1.0

        // -------------------------------------
        // Hidden properties - Generic
        _Surface("__surface", Float) = 0.0
        _Blend("__mode", Float) = 0.0
        _Cull("__cull", Float) = 2.0
        [ToggleUI] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _BlendOp("__blendop", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0

        // Particle specific
        _ColorMode("_ColorMode", Float) = 0.0
        [HideInInspector] _BaseColorAddSubDiff("_ColorMode", Vector) = (0,0,0,0)
        [ToggleOff] _FlipbookBlending("__flipbookblending", Float) = 0.0
        [ToggleUI] _SoftParticlesEnabled("__softparticlesenabled", Float) = 0.0
        [ToggleUI] _CameraFadingEnabled("__camerafadingenabled", Float) = 0.0
        [ToggleUI] _DistortionEnabled("__distortionenabled", Float) = 0.0
        [HideInInspector] _SoftParticleFadeParams("__softparticlefadeparams", Vector) = (0,0,0,0)
        [HideInInspector] _CameraFadeParams("__camerafadeparams", Vector) = (0,0,0,0)
        [HideInInspector] _DistortionStrengthScaled("Distortion Strength Scaled", Float) = 0.1

        // Editmode props
        _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _FlipbookMode("flipbook", Float) = 0
        [HideInInspector] _Glossiness("gloss", Float) = 0
        [HideInInspector] _Mode("mode", Float) = 0
        [HideInInspector] _Color("color", Color) = (1,1,1,1)
    }

    HLSLINCLUDE

    //Particle shaders rely on "write" to CB syntax which is not supported by DXC
    #pragma never_use_dxc

    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
            "PerformanceChecks" = "False"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "SimpleLit"
        }

        // ------------------------------------------------------------------
        //  Forward pass.
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // -------------------------------------
            // Render State Commands
            BlendOp[_BlendOp]
            Blend[_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            ZWrite[_ZWrite]
            Cull[_Cull]
            AlphaToMask[_AlphaToMask]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ParticlesLitVertex
            #pragma fragment ParticlesLitFragment

            // -------------------------------------
            // Material Keywords







            // -------------------------------------
            // Particle Keywords








            // -------------------------------------
            // Universal Pipeline keywords








            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"

            // -------------------------------------
            // Unity defined keywords



            #pragma instancing_options procedural:ParticleInstancingSetup
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Defines
            #define BUMP_SCALE_NOT_SUPPORTED 1

            // -------------------------------------
            // Includes
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesSimpleLitInput.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesSimpleLitForwardPass.hlsl"
            ENDHLSL
        }

        // ------------------------------------------------------------------
        //  GBuffer pass.
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex ParticlesLitGBufferVertex
            #pragma fragment ParticlesLitGBufferFragment

            // -------------------------------------
            // Material Keywords






            // -------------------------------------
            // Particle Keywords
            //#pragma shader_feature _ _ALPHAPREMULTIPLY_ON _ALPHAMODULATE_ON



            //#pragma shader_feature _SOFTPARTICLES_ON
            //#pragma shader_feature _FADING_ON
            //#pragma shader_feature _DISTORTION_ON

            // -------------------------------------
            // Universal Pipeline keywords

            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS




            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            // -------------------------------------
            // Unity defined keywords


            #pragma instancing_options procedural:ParticleInstancingSetup
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            //--------------------------------------
            // Defines
            #define BUMP_SCALE_NOT_SUPPORTED 1

            // -------------------------------------
            // Includes
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesSimpleLitInput.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesSimpleLitGBufferPass.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutputFormat.hlsl"
            ENDHLSL
        }

        // ------------------------------------------------------------------
        //  Depth Only pass.
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords




            // -------------------------------------
            // Unity defined keywords

            #pragma instancing_options procedural:ParticleInstancingSetup
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesSimpleLitInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesDepthOnlyPass.hlsl"
            ENDHLSL
        }
        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords





            // -------------------------------------
            // Unity defined keywords

            #pragma instancing_options procedural:ParticleInstancingSetup
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesSimpleLitInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesDepthNormalsPass.hlsl"
            ENDHLSL
        }
        // ------------------------------------------------------------------
        //  Scene view outline pass.
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }

            // -------------------------------------
            // Render State Commands
            BlendOp Add
            Blend One Zero
            ZWrite On
            Cull Off

            HLSLPROGRAM
            #define PARTICLES_EDITOR_META_PASS
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex vertParticleEditor
            #pragma fragment fragParticleSceneHighlight

            // -------------------------------------
            // Particle Keywords



            // -------------------------------------
            // Unity defined keywords

            #pragma instancing_options procedural:ParticleInstancingSetup
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesSimpleLitInput.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesEditorPass.hlsl"

            ENDHLSL
        }

        // ------------------------------------------------------------------
        //  Scene picking buffer pass.
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }

            // -------------------------------------
            // Render State Commands
            BlendOp Add
            Blend One Zero
            ZWrite On
            Cull Off

            HLSLPROGRAM
            #define PARTICLES_EDITOR_META_PASS
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex vertParticleEditor
            #pragma fragment fragParticleScenePicking

            // -------------------------------------
            // Particle Keywords



            // -------------------------------------
            // Unity defined keywords

            #pragma instancing_options procedural:ParticleInstancingSetup
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesSimpleLitInput.hlsl"
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesEditorPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Universal2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // -------------------------------------
            // Render State Commands
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords



            // -------------------------------------
            // Includes
            #include_with_pragmas "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesSimpleLitInput.hlsl"
            #include "Assets/RecoveryPipeline/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
            ENDHLSL
        }
    }

    Fallback "Universal Render Pipeline/Particles/Unlit"
    CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.ParticlesSimpleLitShader"
}
