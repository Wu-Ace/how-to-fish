using System;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
public static class RecoveryEditor {
 [MenuItem("Recovery/Open original Game scene")]public static void OpenGame(){EditorSceneManager.OpenScene("Assets/Scenes/Game.unity");}
 public static void Build(){RecoveryLocalizationRegistry.Bake();RecoveryFonts.Rebuild();RecoveryMaterialKeywords.Restore();RecoveryAssetAudit.Check();UnityEditor.PlayerSettings.companyName="HowToFishRecovery";UnityEditor.PlayerSettings.productName="How to Fish Recovered";UnityEditor.PlayerSettings.runInBackground=true;UnityEditor.PlayerSettings.fullScreenMode=FullScreenMode.Windowed;UnityEditor.PlayerSettings.defaultScreenWidth=1280;UnityEditor.PlayerSettings.defaultScreenHeight=720;
 var settings=AssetDatabase.LoadAssetAtPath<UnityEngine.Localization.Settings.LocalizationSettings>("Assets/MonoBehaviour/Localization Settings.asset");UnityEngine.Localization.Settings.LocalizationSettings.Instance=settings;EditorBuildSettings.AddConfigObject("com.unity.localization.settings",settings,true);UnityEditor.PlayerSettings.SetPreloadedAssets(UnityEditor.PlayerSettings.GetPreloadedAssets().Where(a=>a!=null&&a!=settings).Concat(new UnityEngine.Object[]{settings}).ToArray());
 var scenes=EditorBuildSettings.scenes.Where(s=>s.enabled).Select(s=>s.path).ToArray();var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=scenes,locationPathName="../../Builds/EditorRebuilt/HowToFishRecovered.exe",target=BuildTarget.StandaloneWindows64,options=BuildOptions.Development|BuildOptions.CleanBuildCache});System.IO.File.WriteAllText("../../Evidence/editor-build-result.txt",report.summary.result+"; errors="+report.summary.totalErrors+"; warnings="+report.summary.totalWarnings);if(report.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded)throw new Exception("Recovered editor build failed");}
}

