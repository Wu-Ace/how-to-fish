using System;
using System.Linq;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.Localization;
using UnityEngine.Localization.Settings;
using UnityEngine.Localization.Tables;
using UnityEngine.ResourceManagement.AsyncOperations;
public static class RecoveryLocalizationCompatibility {
#if RECOVERY_UNITY_PROJECT
 [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]static void Install(){var data=Resources.Load<RecoveryLocalizationData>("RecoveryLocalization");if(!data){Debug.LogError("[RecoveryLocale] Missing recovered locale registry");return;}LocalizationSettings.Instance=data.settings;LocalizationSettings.PreloadBehavior=(PreloadBehavior)0;var provider=new LocalesProvider();foreach(var locale in data.locales)if(locale)provider.AddLocale(locale);if(provider.Locales.Count==0){provider.AddLocale(Locale.CreateLocale("en"));provider.AddLocale(Locale.CreateLocale("zh-CN"));Debug.LogWarning("[RecoveryLocale] Locale assets unavailable; using explicit English/Chinese locale descriptors");}LocalizationSettings.AvailableLocales=provider;LocalizationSettings.StringDatabase.TableProvider=new TableProvider(data.tables);LocalizationSettings.ProjectLocale=provider.GetLocale("en");LocalizationSettings.SelectedLocale=provider.GetLocale("zh-CN")??provider.Locales.First();Debug.Log("[RecoveryLocale] "+data.locales.Length+" locales, "+data.tables.Length+" original string tables; selected="+LocalizationSettings.SelectedLocale.Identifier.Code);}
 class TableProvider:ITableProvider {readonly StringTable[] tables;public TableProvider(StringTable[] t){tables=t;}
 static string Key(string s){if(s.StartsWith("GUID:",StringComparison.OrdinalIgnoreCase))s=s.Substring(5);return s.Replace("-","").Trim('{','}').ToLowerInvariant();}
 public AsyncOperationHandle<TTable> ProvideTableAsync<TTable>(string name,Locale locale) where TTable:LocalizationTable {string key=Key(name);var table=tables.FirstOrDefault(t=>t.LocaleIdentifier.Code==locale.Identifier.Code&&(Key(t.SharedData.TableCollectionName)==key||Key(t.SharedData.TableCollectionNameGuid.ToString())==key));if(!table)return default(AsyncOperationHandle<TTable>);return Addressables.ResourceManager.CreateCompletedOperation((TTable)(object)table,(string)null);}}
#endif
}
