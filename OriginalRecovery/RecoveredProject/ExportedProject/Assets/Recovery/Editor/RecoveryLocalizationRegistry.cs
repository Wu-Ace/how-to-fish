using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.Localization.Settings;
using UnityEngine.Localization.Tables;
public static class RecoveryLocalizationRegistry {
 public static void Bake(){const string path="Assets/Resources/RecoveryLocalization.asset";var registry=AssetDatabase.LoadAssetAtPath<RecoveryLocalizationData>(path);if(!registry){registry=ScriptableObject.CreateInstance<RecoveryLocalizationData>();AssetDatabase.CreateAsset(registry,path);}registry.settings=AssetDatabase.LoadAssetAtPath<LocalizationSettings>("Assets/MonoBehaviour/Localization Settings.asset");registry.consoleFont=AssetDatabase.LoadAssetAtPath<Font>("Assets/Font/NotoSansSC-VariableFont_wght.ttf");registry.locales=AssetDatabase.FindAssets("t:Locale",new[]{"Assets/Localization"}).Select(AssetDatabase.GUIDToAssetPath).Select(AssetDatabase.LoadAssetAtPath<Locale>).Where(l=>l).OrderBy(l=>new SerializedObject(l).FindProperty("m_SortOrder").intValue).ToArray();registry.tables=AssetDatabase.FindAssets("t:StringTable",new[]{"Assets"}).Select(AssetDatabase.GUIDToAssetPath).Select(AssetDatabase.LoadAssetAtPath<StringTable>).Where(t=>t).ToArray();EditorUtility.SetDirty(registry);AssetDatabase.SaveAssets();Debug.Log("[RecoveryLocaleBake] "+registry.locales.Length+" locales "+registry.tables.Length+" tables");}
}
