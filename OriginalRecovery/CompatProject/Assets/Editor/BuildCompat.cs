using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
public static class BuildCompat {
 public static void Build(){var scene=EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);new GameObject("UI",typeof(RectTransform),typeof(Canvas),typeof(UnityEngine.UI.Button),typeof(TMPro.TextMeshProUGUI));new GameObject("Input",typeof(UnityEngine.InputSystem.PlayerInput));new GameObject("URP",typeof(Camera),typeof(UnityEngine.Rendering.Universal.UniversalAdditionalCameraData));EditorSceneManager.SaveScene(scene,"Assets/Compat.unity");PlayerSettings.SetManagedStrippingLevel(UnityEditor.Build.NamedBuildTarget.Standalone,ManagedStrippingLevel.Disabled);var report=BuildPipeline.BuildPlayer(new[]{"Assets/Compat.unity"},"../Builds/Compat/Compat.exe",BuildTarget.StandaloneWindows64,BuildOptions.Development);if(report.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded)throw new System.Exception("Compatibility build failed");}
}
