using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Animations;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
public static class OriginalArtBuilder
{
 const string Root="Assets/ArtOriginal";
 [Serializable]class Palette{public Swatch[] colors;}
 [Serializable]class Swatch{public string name;public float r,g,b;}
 [Serializable]class TreePlacement{public Tree[] trees;}
 [Serializable]class Tree{public float x,y,z,height;}
 public static void Prepare()
 {
  Directory.CreateDirectory(Root+"/Materials");Directory.CreateDirectory(Root+"/Prefabs");Directory.CreateDirectory(Root+"/Scenes");AssetDatabase.Refresh();
  var palette=JsonUtility.FromJson<Palette>(File.ReadAllText(Root+"/authored-palette.json"));
  foreach(var c in palette.colors){var path=Root+"/Materials/"+c.name+".mat";var m=AssetDatabase.LoadAssetAtPath<Material>(path);if(!m){m=new Material(Shader.Find("ProjectOriginal/FacetedArt"));AssetDatabase.CreateAsset(m,path);}m.shader=Shader.Find("ProjectOriginal/FacetedArt");m.SetColor("_BaseColor",new Color(c.r,c.g,c.b));EditorUtility.SetDirty(m);}
  foreach(var path in AssetDatabase.FindAssets("t:Model",new[]{Root+"/Models"}).Select(AssetDatabase.GUIDToAssetPath))
  {
   var importer=(ModelImporter)AssetImporter.GetAtPath(path);importer.globalScale=1;importer.isReadable=true;importer.importCameras=false;importer.importLights=false;importer.materialImportMode=ModelImporterMaterialImportMode.ImportStandard;
   if(path.Contains("Fisher")){importer.animationType=ModelImporterAnimationType.Generic;importer.avatarSetup=ModelImporterAvatarSetup.CreateFromThisModel;var clips=importer.defaultClipAnimations;foreach(var clip in clips){clip.loopTime=true;clip.loopPose=true;}importer.clipAnimations=clips;}
   importer.SaveAndReimport();
   var model=AssetDatabase.LoadAssetAtPath<GameObject>(path);var go=(GameObject)PrefabUtility.InstantiatePrefab(model);
   foreach(var r in go.GetComponentsInChildren<Renderer>(true)){r.sharedMaterials=r.sharedMaterials.Select(m=>{string n=m.name.Replace(" (Instance)","");var replacement=AssetDatabase.LoadAssetAtPath<Material>(Root+"/Materials/"+n+".mat");if(!replacement)throw new Exception("Unknown authored material "+n);return replacement;}).ToArray();}
   if(path.Contains("Fisher"))
   {
    string controllerPath=Root+"/FisherAnimator.controller";var ctrl=AssetDatabase.LoadAssetAtPath<AnimatorController>(controllerPath);
    if(!ctrl){ctrl=AnimatorController.CreateAnimatorControllerAtPath(controllerPath);ctrl.AddParameter("Speed",AnimatorControllerParameterType.Float);var sm=ctrl.layers[0].stateMachine;var clips=AssetDatabase.LoadAllAssetsAtPath(path).OfType<AnimationClip>().Where(c=>!c.name.StartsWith("__")).ToArray();var idle=sm.AddState("Idle");idle.motion=clips.First(c=>c.name.Contains("Idle"));var walk=sm.AddState("Walk");walk.motion=clips.First(c=>c.name.Contains("Walk"));sm.defaultState=idle;var t=idle.AddTransition(walk);t.hasExitTime=false;t.duration=.15f;t.AddCondition(AnimatorConditionMode.Greater,.1f,"Speed");t=walk.AddTransition(idle);t.hasExitTime=false;t.duration=.15f;t.AddCondition(AnimatorConditionMode.Less,.1f,"Speed");}
    var anim=go.GetComponent<Animator>();if(!anim)anim=go.AddComponent<Animator>();anim.runtimeAnimatorController=ctrl;anim.applyRootMotion=false;anim.cullingMode=AnimatorCullingMode.AlwaysAnimate;
   }
   else {
    foreach(var filter in go.GetComponentsInChildren<MeshFilter>()){if(filter.name.StartsWith("Vegetation"))continue;var collider=filter.gameObject.AddComponent<MeshCollider>();collider.sharedMesh=filter.sharedMesh;}
    var kind=Path.GetFileNameWithoutExtension(path).Replace("Island_","").Replace("_Original","").ToLowerInvariant();
    var placement=JsonUtility.FromJson<TreePlacement>(File.ReadAllText(Root+"/island-"+kind+"-placement.json"));
    foreach(var tree in placement.trees){var trunk=new GameObject("Authored tree trunk collider");trunk.transform.SetParent(go.transform,false);trunk.transform.localPosition=new Vector3(tree.x,tree.y,tree.z);var col=trunk.AddComponent<CapsuleCollider>();col.height=tree.height;col.center=new Vector3(0,tree.height*.5f,0);col.radius=tree.height*.11f;}
   }
   PrefabUtility.SaveAsPrefabAsset(go,Root+"/Prefabs/"+Path.GetFileNameWithoutExtension(path)+".prefab");UnityEngine.Object.DestroyImmediate(go);
  }
  var scene=EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);
  var cgo=new GameObject("Art review camera");cgo.tag="MainCamera";var camera=cgo.AddComponent<Camera>();camera.nearClipPlane=.1f;camera.farClipPlane=500;camera.backgroundColor=new Color(.19f,.29f,.35f);camera.clearFlags=CameraClearFlags.SolidColor;
  cgo.AddComponent<AudioListener>();var l=new GameObject("Review sunlight").AddComponent<Light>();l.type=LightType.Directional;l.intensity=1.2f;l.transform.rotation=Quaternion.Euler(45,-35,0);l.shadows=LightShadows.Soft;
  RenderSettings.ambientMode=AmbientMode.Flat;RenderSettings.ambientLight=new Color(.43f,.48f,.52f);RenderSettings.fog=false;
  var water=GameObject.CreatePrimitive(PrimitiveType.Cube);water.name="Own preview ocean";water.transform.position=new Vector3(0,-.75f,0);water.transform.localScale=new Vector3(3000,.1f,3000);water.GetComponent<Renderer>().sharedMaterial=AssetDatabase.LoadAssetAtPath<Material>(Root+"/Materials/Water.mat");UnityEngine.Object.DestroyImmediate(water.GetComponent<Collider>());
  var review=new GameObject("Original art review").AddComponent<OriginalArtReview>();review.islands=new[]{"Harbour","Autumn","Snow","Volcanic","Tropical"}.Select(n=>AssetDatabase.LoadAssetAtPath<GameObject>(Root+"/Prefabs/Island_"+n+"_Original.prefab")).ToArray();review.fisher=AssetDatabase.LoadAssetAtPath<GameObject>(Root+"/Prefabs/Fisher_Original.prefab");review.font=AssetDatabase.LoadAssetAtPath<Font>("Assets/Font/NotoSansSC-VariableFont_wght.ttf");
  EditorSceneManager.SaveScene(scene,Root+"/Scenes/OriginalArtReview.unity");AssetDatabase.SaveAssets();Debug.Log("[OriginalArt] PREPARE_COMPLETE six original prefabs");
 }
 public static void Build()
 {
  Prepare();var result=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{Root+"/Scenes/OriginalArtReview.unity"},locationPathName="../../Builds/OriginalArtReview/OriginalArtReview.exe",target=BuildTarget.StandaloneWindows64,options=BuildOptions.Development});
  File.WriteAllText("../../Evidence/OriginalArt/unity-build.txt",result.summary.result+" errors="+result.summary.totalErrors+" warnings="+result.summary.totalWarnings);if(result.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded||result.summary.totalErrors>0)throw new Exception("Original art build failed");
 }
}
