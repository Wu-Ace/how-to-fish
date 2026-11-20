using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;
using UnityEngine.SceneManagement;
// The independent player uses the recovered game's original offline transport.
// Remove Steam bootstrap components from build scenes; keep the source scenes intact.
public class RecoveryPlatformScene:IProcessSceneWithReport {
 public int callbackOrder=>-1000;
 public void OnProcessScene(Scene scene,BuildReport report){foreach(var root in scene.GetRootGameObjects()){
  foreach(var c in root.GetComponentsInChildren<HeathenEngineering.SteamworksIntegration.SteamworksBehaviour>(true))Object.DestroyImmediate(c);
  foreach(var c in root.GetComponentsInChildren<HeathenEngineering.SteamworksIntegration.SteamworksCreator>(true))Object.DestroyImmediate(c);
  foreach(var c in root.GetComponentsInChildren<UnityEngine.VFX.VisualEffect>(true))Object.DestroyImmediate(c);
 }}
}
