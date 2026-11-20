using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.InputSystem;

/// <summary>Art integration review only; this is not the restored game's gameplay.</summary>
public class OriginalArtReview : MonoBehaviour
{
 public GameObject[] islands;
 public GameObject fisher;
 public Font font;
 GameObject land,person;Camera view;CharacterController controller;Animator animator;
 int index;bool walking;float yaw=155,pitch=32,distance=56,vertical;
 GUIStyle text,button;readonly List<string> checks=new List<string>();int failed;
 string Evidence=>Path.GetFullPath(Path.Combine(Application.dataPath,"../../../Evidence/OriginalArt/Unity"));
 IEnumerator Start()
 {
  Application.runInBackground=true;var pipeline=UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline as UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset;if(pipeline){var copy=Instantiate(pipeline);copy.renderScale=1;copy.msaaSampleCount=4;UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline=copy;QualitySettings.renderPipeline=copy;}view=Camera.main;LoadIsland(0);yield return null;
  if(Array.IndexOf(Environment.GetCommandLineArgs(),"-art-verify")>=0)yield return Verify();
 }
 void LoadIsland(int i)
 {
  if(land)DestroyImmediate(land);if(person)DestroyImmediate(person);
  index=i;land=Instantiate(islands[i]);person=Instantiate(fisher);
  person.transform.position=new Vector3(0,1.17f,24);
  animator=person.GetComponentInChildren<Animator>();
  controller=person.AddComponent<CharacterController>();controller.height=1.98f;controller.center=new Vector3(0,.99f,0);controller.radius=.24f;controller.stepOffset=.25f;controller.slopeLimit=46;
  Physics.SyncTransforms();vertical=0;walking=false;Cursor.lockState=CursorLockMode.None;Cursor.visible=true;
 }
 void Update()
 {
  var k=Keyboard.current;var m=Mouse.current;if(k==null)return;
  for(int i=0;i<5;i++)if(k[(Key)((int)Key.Digit1+i)].wasPressedThisFrame)LoadIsland(i);
  if(k.tabKey.wasPressedThisFrame){walking=!walking;if(walking){yaw=180;pitch=12;distance=4;}else{distance=66;pitch=27;}Cursor.lockState=walking?CursorLockMode.Locked:CursorLockMode.None;Cursor.visible=!walking;}
  if(k.escapeKey.wasPressedThisFrame){walking=false;Cursor.lockState=CursorLockMode.None;Cursor.visible=true;distance=66;pitch=27;}
  if(k.rKey.wasPressedThisFrame){person.transform.position=new Vector3(0,1.17f,24);vertical=0;Physics.SyncTransforms();}
  if(m!=null){if(walking||m.rightButton.isPressed){var delta=m.delta.ReadValue();yaw+=delta.x*.16f;pitch=Mathf.Clamp(pitch-delta.y*.12f,-15,75);}if(!walking)distance=Mathf.Clamp(distance-m.scroll.ReadValue().y*.025f,12,100);}
  if(walking){Vector2 input=new Vector2((k.dKey.isPressed?1:0)-(k.aKey.isPressed?1:0),(k.wKey.isPressed?1:0)-(k.sKey.isPressed?1:0));input=Vector2.ClampMagnitude(input,1);
   Vector3 move=Quaternion.Euler(0,yaw,0)*new Vector3(input.x,0,input.y);
   if(controller.isGrounded&&vertical<0)vertical=-2;if(controller.isGrounded&&k.spaceKey.wasPressedThisFrame)vertical=5.2f;vertical+=Physics.gravity.y*Time.deltaTime;
   controller.Move((move*3.5f+Vector3.up*vertical)*Time.deltaTime);
   if(move.sqrMagnitude>.01f)person.transform.rotation=Quaternion.LookRotation(move);
   if(person.transform.position.y<-8){person.transform.position=new Vector3(0,1.17f,24);vertical=0;}
   if(animator)animator.SetFloat("Speed",input.magnitude);
  }else if(animator)animator.SetFloat("Speed",0);
 }
 void LateUpdate()
 {
  if(!view||!person)return;Vector3 target=walking?person.transform.position+Vector3.up*1.25f:new Vector3(0,1,3);
  var rotation=Quaternion.Euler(pitch,yaw,0);view.transform.position=target+rotation*new Vector3(0,0,-distance);view.transform.LookAt(target);
 }
 void OnGUI()
 {
  if(text==null){text=new GUIStyle(GUI.skin.label){font=font,fontSize=19,wordWrap=true};button=new GUIStyle(GUI.skin.button){font=font,fontSize=18};}
  GUI.Box(new Rect(15,15,480,151),GUIContent.none);
  GUI.Label(new Rect(28,24,455,132),"原创美术检视 · "+new[]{"草地港湾","秋林","雪地","火山","热带"}[index]+"\n1–5 切换岛屿 · 右键拖动旋转 · 滚轮缩放\nTab 地面行走 · WASD 移动 · 空格跳跃\nR 返回码头 · Esc 返回鸟瞰",text);
  if(GUI.Button(new Rect(28,173,165,35),walking?"返回鸟瞰":"进入岛屿行走",button)){walking=!walking;distance=walking?4:56;pitch=walking?12:32;}
 }
 void Check(string label,bool ok){checks.Add((ok?"PASS ":"FAIL ")+label);if(!ok)failed++;Debug.Log("[OriginalArt] "+checks[checks.Count-1]);}
 IEnumerator Verify()
 {
  Directory.CreateDirectory(Evidence);
  for(int i=0;i<islands.Length;i++)
  {
   LoadIsland(i);yield return null;Physics.SyncTransforms();
   Check("island "+i+" original terrain collider",land.GetComponentsInChildren<MeshCollider>().Length>=3);
   // Probe the authored terrain and complete dock, including the former shoreline seam.
   foreach(float z in new[]{0f,5f,10f,14f,16f,20f,25f,29f})
   {
    bool hit=Physics.Raycast(new Vector3(0,12,z),Vector3.down,out var h,24,1<<0);
    Check("island "+i+" ground z="+z,hit&&h.collider.transform.IsChildOf(land.transform)&&h.normal.y>.45f);
   }
   Check("island "+i+" no missing materials",Array.TrueForAll(land.GetComponentsInChildren<Renderer>(),r=>Array.TrueForAll(r.sharedMaterials,m=>m&&m.shader&&m.shader.isSupported)));
   // Exercise actual CharacterController.Move on the new dock, with no old collider geometry.
   controller.enabled=false;person.transform.position=new Vector3(0,1.25f,28);controller.enabled=true;Physics.SyncTransforms();
   for(int j=0;j<100;j++)controller.Move(new Vector3(0,-.02f,-.04f));
   Check("island "+i+" dock capsule stays above deck",person.transform.position.y>.99f&&person.transform.position.y<1.4f);
   Check("island "+i+" dock capsule travels 4m",person.transform.position.z<24.2f);
   walking=false;distance=66;pitch=27;LateUpdate();yield return new WaitForEndOfFrame();ScreenCapture.CaptureScreenshot(Path.Combine(Evidence,"island-"+i+".png"));yield return null;
  }
  var skin=person.GetComponentInChildren<SkinnedMeshRenderer>();Check("fisher skinned mesh and 15 bones",skin&&skin.bones.Length==15&&skin.sharedMesh.vertexCount>1000);
  if(skin&&animator){animator.Play("Idle",0,0);animator.Update(.05f);var a=new Mesh();skin.BakeMesh(a);animator.Play("Walk",0,.2f);animator.Update(.05f);var b=new Mesh();skin.BakeMesh(b);float delta=0;var av=a.vertices;var bv=b.vertices;for(int j=0;j<Mathf.Min(av.Length,bv.Length);j++)delta+=Vector3.Distance(av[j],bv[j]);Check("walk deforms own skinned vertices",delta>1);Destroy(a);Destroy(b);}
  LoadIsland(0);controller.enabled=false;person.transform.position=new Vector3(0,1.18f,26);controller.enabled=true;walking=true;distance=3.6f;yaw=155;pitch=12;LateUpdate();
  yield return new WaitForEndOfFrame();ScreenCapture.CaptureScreenshot(Path.Combine(Evidence,"fisher-in-engine.png"));yield return null;
  File.WriteAllLines(Path.Combine(Evidence,"verification.txt"),new[]{"UTC "+DateTime.UtcNow.ToString("O"),"Checks="+checks.Count+" Failed="+failed,"These verify original-art models, import, animation and isolated island colliders; not full restored-game acceptance."});File.AppendAllLines(Path.Combine(Evidence,"verification.txt"),checks);
  Debug.Log("[OriginalArt] ART_VERIFY_COMPLETE checks="+checks.Count+" failed="+failed);
  if(Array.IndexOf(Environment.GetCommandLineArgs(),"-art-exit")>=0){yield return new WaitForSecondsRealtime(1);Application.Quit(failed==0?0:1);}
 }
}
