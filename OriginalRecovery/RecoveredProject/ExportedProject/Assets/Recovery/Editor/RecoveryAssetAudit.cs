using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
public static class RecoveryAssetAudit {
 public static void Check(){var lines=new System.Collections.Generic.List<string>();foreach(var name in new[]{"MetaVoiceChat/MetaVc.cs","RigidbodySync.cs","Item.cs"}){var s=AssetDatabase.LoadAssetAtPath<MonoScript>("Assets/Scripts/Assembly-CSharp/"+name);lines.Add(name+" => "+(s?s.GetClass()?.FullName:"missing asset"));}
 foreach(var path in AssetDatabase.FindAssets("t:Prefab",new[]{"Assets/Resources"}).Select(AssetDatabase.GUIDToAssetPath)){var o=AssetDatabase.LoadAssetAtPath<GameObject>(path);int missing=o.GetComponentsInChildren<Transform>(true).Sum(t=>GameObjectUtility.GetMonoBehavioursWithMissingScriptCount(t.gameObject));if(missing>0)lines.Add("MISSING "+missing+" "+path);}
 File.WriteAllLines("../../Evidence/editor-script-bindings.txt",lines);Debug.Log("[RecoveryAudit] "+string.Join("; ",lines));}
}
