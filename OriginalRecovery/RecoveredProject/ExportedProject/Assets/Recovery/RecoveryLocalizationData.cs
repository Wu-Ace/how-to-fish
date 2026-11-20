using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.Localization.Settings;
using UnityEngine.Localization.Tables;
public class RecoveryLocalizationData:ScriptableObject {
 public LocalizationSettings settings;public Locale[] locales;public StringTable[] tables;public Font consoleFont;
}
