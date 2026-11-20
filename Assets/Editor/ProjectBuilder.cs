using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
public static class ProjectBuilder {
 public static void Prepare(){
  PlayerSettings.companyName="LocalReconstruction"; PlayerSettings.productName="How to Fish - Gift Sandbox";
  PlayerSettings.defaultScreenWidth=1600;PlayerSettings.defaultScreenHeight=900;PlayerSettings.fullScreenMode=FullScreenMode.Windowed;
  PlayerSettings.runInBackground=true;
  var graphics=new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/GraphicsSettings.asset")[0]);
  var shaders=graphics.FindProperty("m_AlwaysIncludedShaders");
  foreach(var name in new[]{"Standard","Sprites/Default","FishSandbox/Ocean","FishSandbox/VertexColor","FishSandbox/Sky"}){
   var shader=Shader.Find(name);if(shader==null)throw new System.Exception("Missing shader: "+name);bool found=false;for(int i=0;i<shaders.arraySize;i++)if(shaders.GetArrayElementAtIndex(i).objectReferenceValue==shader)found=true;
   if(!found){shaders.InsertArrayElementAtIndex(shaders.arraySize);shaders.GetArrayElementAtIndex(shaders.arraySize-1).objectReferenceValue=shader;}
  }
  graphics.ApplyModifiedPropertiesWithoutUndo();
  var so=new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/ProjectSettings.asset")[0]);
  var input=so.FindProperty("activeInputHandler");if(input!=null){input.intValue=0;so.ApplyModifiedProperties();}
  var scene=EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);
  EditorSceneManager.SaveScene(scene,"Assets/Scenes/Harbor.unity");
  EditorBuildSettings.scenes=new[]{new EditorBuildSettingsScene("Assets/Scenes/Harbor.unity",true)};
  AssetDatabase.SaveAssets();
 }
 public static void Build(){Prepare();var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Harbor.unity"},locationPathName="Builds/HowToFish/HowToFish.exe",target=BuildTarget.StandaloneWindows64,options=BuildOptions.Development});if(report.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded)throw new System.Exception("Build failed: "+report.summary.result);}
}
