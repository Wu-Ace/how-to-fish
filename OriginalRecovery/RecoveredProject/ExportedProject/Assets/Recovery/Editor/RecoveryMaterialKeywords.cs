using System.Linq;
using UnityEditor;
using UnityEngine;
public static class RecoveryMaterialKeywords {
 public static void Restore(){int count=0;foreach(var path in AssetDatabase.FindAssets("t:Material",new[]{"Assets"}).Select(AssetDatabase.GUIDToAssetPath)){var mat=AssetDatabase.LoadAssetAtPath<Material>(path);if(!mat||!mat.shader)continue;var p=new SerializedObject(mat).FindProperty("m_InvalidKeywords");if(p==null||!p.isArray)continue;var names=Enumerable.Range(0,p.arraySize).Select(i=>p.GetArrayElementAtIndex(i).stringValue).ToArray();foreach(var name in names)if(mat.shader.keywordSpace.FindKeyword(name).isValid){mat.EnableKeyword(name);EditorUtility.SetDirty(mat);count++;}}AssetDatabase.SaveAssets();System.IO.File.WriteAllText("../../Evidence/restored-material-keywords.txt",count.ToString());}
}
