using System.IO;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEditor;
using UnityEngine;
using UnityEngine.TextCore.LowLevel;
public static class RecoveryFonts {
 public static void Rebuild(){const string marker="../../Evidence/font-rebuild-v2-official-ofl.txt";if(File.Exists(marker))return;var log=new List<string>();var materials=AssetDatabase.FindAssets("t:Material",new[]{"Assets"}).Select(AssetDatabase.GUIDToAssetPath).Select(AssetDatabase.LoadAssetAtPath<Material>).Where(m=>m).ToArray();
 foreach(var path in AssetDatabase.FindAssets("t:TMP_FontAsset",new[]{"Assets"}).Select(AssetDatabase.GUIDToAssetPath).ToArray()){
 var old=AssetDatabase.LoadAssetAtPath<TMP_FontAsset>(path);var source=old.sourceFontFile;if(!source){log.Add("NO SOURCE "+path);continue;}var fallback=old.fallbackFontAssetTable;var originalMat=old.material;
 var fresh=TMP_FontAsset.CreateFontAsset(source,64,6,GlyphRenderMode.SDFAA,2048,2048,AtlasPopulationMode.Dynamic,true);if(!fresh){log.Add("CREATE FAILED "+path);continue;}
 var mat=fresh.material;var atlas=fresh.atlasTextures[0];atlas.name=source.name+" Recovered Atlas";AssetDatabase.AddObjectToAsset(atlas,old);if(!originalMat){AssetDatabase.AddObjectToAsset(mat,old);originalMat=mat;}
 var matching=materials.Where(m=>m==originalMat||m.name.StartsWith(source.name+" Atlas")).ToArray();foreach(var target in matching){var face=target.HasProperty("_FaceColor")?target.GetColor("_FaceColor"):Color.white;EditorUtility.CopySerialized(mat,target);target.SetColor("_FaceColor",face);target.SetTexture("_MainTex",atlas);EditorUtility.SetDirty(target);}
 EditorUtility.CopySerialized(fresh,old);old.material=originalMat;old.fallbackFontAssetTable=fallback;old.name=Path.GetFileNameWithoutExtension(path);old.TryAddCharacters("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:!?-/()[]渔力全开创建加入房间角色选项制作人员退出礼物钓鱼金币生命饱食移动跳跃返回单机游戏开始保存菜单");EditorUtility.SetDirty(old);var detached=new SerializedObject(fresh);detached.FindProperty("m_AtlasTextures").ClearArray();detached.ApplyModifiedPropertiesWithoutUndo();Object.DestroyImmediate(fresh);log.Add("REBUILT "+path+" source="+source.name+" materials="+matching.Length);
 }
 AssetDatabase.SaveAssets();File.WriteAllLines(marker,log);Debug.Log("[RecoveryFonts] "+string.Join("; ",log));}
}
