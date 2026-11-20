using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
public static class RecoveryArtInspection
{
 public static void Inspect()
 {
  var prefab=AssetDatabase.LoadAssetAtPath<GameObject>("Assets/Resources/other/PlayerHolder.prefab");
  var character=prefab.GetComponentsInChildren<Transform>(true).First(t=>t.name=="Character");
  var lines=new System.Collections.Generic.List<string>();
  foreach(var t in character.GetComponentsInChildren<Transform>(true))
   lines.Add("NODE "+t.name+" pos="+character.InverseTransformPoint(t.position).ToString("F4")+" parent="+(t.parent?t.parent.name:"-")+" scale="+t.localScale.ToString("F3"));
  foreach(var r in prefab.GetComponentsInChildren<SkinnedMeshRenderer>(true))
   lines.Add("SKIN "+r.name+" mesh="+(r.sharedMesh?AssetDatabase.GetAssetPath(r.sharedMesh):"null")+" bounds="+r.localBounds+" bones="+string.Join(",",r.bones.Select(b=>b?b.name:"null")));
  File.WriteAllLines("../../Evidence/art-original-rig-inspection.txt",lines);
  Debug.Log("[Art] Rig inspection complete");
 }
}
