using System;
using System.IO;
using System.Collections.Generic;
using System.Globalization;
using Newtonsoft.Json;
using UnityEngine;
public static class RecoveryIsolation
{
    public static bool Enabled => true;
    public static string PersistentDataPath { get { var p=Path.GetFullPath(Path.Combine(Application.dataPath,"../../../LocalSaves"));Directory.CreateDirectory(p);return p;} }
}
public static class RecoveryPrefs
{
    static Dictionary<string,string> data;
    public static int GetInt(string key)=>GetInt(key,0);
    public static float GetFloat(string key)=>GetFloat(key,0f);
    public static string GetString(string key)=>GetString(key,"");
    static string FilePath=>Path.Combine(RecoveryIsolation.PersistentDataPath,"isolated-playerprefs.json");
    static Dictionary<string,string> Data { get {if(data==null){try{data=File.Exists(FilePath)?JsonConvert.DeserializeObject<Dictionary<string,string>>(File.ReadAllText(FilePath)):null;}catch{}data=data??new Dictionary<string,string>();}return data;} }
    public static bool HasKey(string key)=>Data.ContainsKey(key);
    public static string GetString(string key,string defaultValue="")=>Data.TryGetValue(key,out var v)?v:defaultValue;
    public static int GetInt(string key,int defaultValue=0)=>int.TryParse(GetString(key),NumberStyles.Integer,CultureInfo.InvariantCulture,out var v)?v:defaultValue;
    public static float GetFloat(string key,float defaultValue=0)=>float.TryParse(GetString(key),NumberStyles.Float,CultureInfo.InvariantCulture,out var v)?v:defaultValue;
    public static void SetString(string key,string value){Data[key]=value??"";Save();}
    public static void SetInt(string key,int value)=>SetString(key,value.ToString(CultureInfo.InvariantCulture));
    public static void SetFloat(string key,float value)=>SetString(key,value.ToString("R",CultureInfo.InvariantCulture));
    public static void DeleteKey(string key){Data.Remove(key);Save();}
    public static void DeleteAll(){Data.Clear();Save();}
    public static void Save()=>File.WriteAllText(FilePath,JsonConvert.SerializeObject(Data));
}

