using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

// Editor Play does not execute the standalone-player scene build processor.
// Strip native platform bootstrap components before any scene Awake can run.
[InitializeOnLoad]
public static class RecoveryEditorOfflineGuard
{
 static RecoveryEditorOfflineGuard()
 {
  EditorApplication.playModeStateChanged += OnPlayMode;
  EditorSceneManager.sceneOpened += OnSceneOpened;
  EditorApplication.delayCall += PrepareOpenScenes;
 }
 static void OnSceneOpened(Scene scene, OpenSceneMode mode)
 {
  if(!EditorApplication.isPlayingOrWillChangePlaymode)Strip(scene);
 }
 static void OnPlayMode(PlayModeStateChange state)
 {
  if(state==PlayModeStateChange.ExitingEditMode)PrepareOpenScenes();
 }
 static void PrepareOpenScenes()
 {
  if(EditorApplication.isPlaying)return;
  for(int i=0;i<SceneManager.sceneCount;i++)Strip(SceneManager.GetSceneAt(i));
 }
 static void Strip(Scene scene)
 {
  if(!scene.IsValid()||!scene.isLoaded)return;
  int count=0;
  foreach(var root in scene.GetRootGameObjects())
  {
   foreach(var c in root.GetComponentsInChildren<HeathenEngineering.SteamworksIntegration.SteamworksBehaviour>(true)){Undo.DestroyObjectImmediate(c);count++;}
   foreach(var c in root.GetComponentsInChildren<HeathenEngineering.SteamworksIntegration.SteamworksCreator>(true)){Undo.DestroyObjectImmediate(c);count++;}
  }
  if(count>0)Debug.Log("[RecoveryOffline] Removed "+count+" Steam startup components before Play in "+scene.name);
 }
}
