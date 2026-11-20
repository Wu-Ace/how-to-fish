using System;
using System.Linq;
using System.Collections.Generic;
using Mono.Cecil;
using Mono.Cecil.Cil;
public static class OriginalRecoveryPatcher {
 static ModuleDefinition target,extension; static int changed;
 static MethodReference Ext(string type,string name,int parameters){return target.ImportReference(extension.Types.Single(t=>t.Name==type).Methods.First(m=>m.Name==name&&m.Parameters.Count==parameters));}
 static IEnumerable<TypeDefinition> Types(IEnumerable<TypeDefinition> types){foreach(var t in types){yield return t;foreach(var n in Types(t.NestedTypes))yield return n;}}
 static MethodDefinition Method(string type,string method)=>target.Types.Single(t=>t.Name==type&&t.Namespace=="").Methods.First(m=>m.Name==method);
 static ILProcessor Reset(MethodDefinition m){m.Body=new MethodBody(m);changed++;return m.Body.GetILProcessor();}
 public static void Run(string original,string extra,string output){var resolver=new DefaultAssemblyResolver();resolver.AddSearchDirectory(System.IO.Path.GetDirectoryName(original));resolver.AddSearchDirectory(System.IO.Path.GetDirectoryName(extra));var assembly=AssemblyDefinition.ReadAssembly(original,new ReaderParameters{AssemblyResolver=resolver});target=assembly.MainModule;extension=AssemblyDefinition.ReadAssembly(extra).MainModule;changed=0;
 foreach(var t in Types(target.Types))foreach(var m in t.Methods){if(!m.HasBody)continue;bool did=false;foreach(var i in m.Body.Instructions){if(!(i.Operand is MethodReference call))continue;MethodReference replace=null;
 if(call.DeclaringType.FullName=="UnityEngine.Application"&&call.Name=="get_persistentDataPath")replace=Ext("RecoveryIsolation","get_PersistentDataPath",0);
 if(call.DeclaringType.FullName=="UnityEngine.PlayerPrefs")replace=Ext("RecoveryPrefs",call.Name,call.Parameters.Count);
 if(call.DeclaringType.FullName=="Steamworks.SteamUser"&&call.Name=="GetSteamID")replace=Ext("RecoveryPlatform","GetSteamID",0);
 if(call.DeclaringType.FullName=="Steamworks.SteamFriends"&&call.Name=="GetPersonaName")replace=Ext("RecoveryPlatform","GetPersonaName",0);
 if(call.DeclaringType.FullName=="Steamworks.SteamFriends"&&call.Name=="GetFriendPersonaName")replace=Ext("RecoveryPlatform","GetFriendPersonaName",1);
 if(call.DeclaringType.FullName=="Steamworks.SteamUtils"&&call.Name=="GetSteamUILanguage")replace=Ext("RecoveryPlatform","GetLanguage",0);
 if(replace!=null){i.Operand=replace;did=true;}}
 if(did)changed++;}
 var steam=target.Types.Single(t=>t.Name=="SteamManager");var il=Reset(Method("SteamManager","Awake"));il.Emit(OpCodes.Ldarg_0);il.Emit(OpCodes.Stsfld,steam.Fields.Single(f=>f.Name=="_instance"));il.Emit(OpCodes.Ret);
 il=Reset(Method("SteamManager","Start"));il.Emit(OpCodes.Ret);
 foreach(var i in Method("SteamManager","OnDestroy").Body.Instructions)if(i.Operand is MethodReference mr&&mr.DeclaringType.FullName=="Steamworks.SteamAPI"&&mr.Name=="Shutdown"){i.OpCode=OpCodes.Nop;i.Operand=null;changed++;}
 il=Reset(Method("SteamManager","CreateLobby"));il.Emit(OpCodes.Ldsfld,target.Types.Single(t=>t.Name=="ConnectionManager").Fields.Single(f=>f.Name=="Instance"));il.Emit(OpCodes.Callvirt,Method("ConnectionManager","CreateOfflineLobby"));il.Emit(OpCodes.Ret);
 var awake=Method("ConnectionManager","Awake");foreach(var i in awake.Body.Instructions.ToArray())if(i.Operand is MethodReference mr&&mr.Name=="Create"&&mr.DeclaringType.FullName.StartsWith("Steamworks.Callback")){i.OpCode=OpCodes.Pop;i.Operand=null;awake.Body.GetILProcessor().InsertAfter(i,Instruction.Create(OpCodes.Ldnull));changed++;}
 il=Reset(Method("AchievementManager","UnlockAchievement"));il.Emit(OpCodes.Ldstr,"achievement:");il.Emit(OpCodes.Ldarg_0);var concat=typeof(string).GetMethod("Concat",new[]{typeof(string),typeof(string)});var concatRef=new MethodReference("Concat",target.TypeSystem.String,target.TypeSystem.String){HasThis=false};concatRef.Parameters.Add(new ParameterDefinition(target.TypeSystem.String));concatRef.Parameters.Add(new ParameterDefinition(target.TypeSystem.String));il.Emit(OpCodes.Call,concatRef);il.Emit(OpCodes.Ldc_I4_1);il.Emit(OpCodes.Call,Ext("RecoveryPrefs","SetInt",2));il.Emit(OpCodes.Ret);
 il=Reset(Method("AchievementManager","HasAchievement"));il.Emit(OpCodes.Ldstr,"achievement:");il.Emit(OpCodes.Ldarg_0);il.Emit(OpCodes.Call,concatRef);il.Emit(OpCodes.Ldc_I4_0);il.Emit(OpCodes.Call,Ext("RecoveryPrefs","GetInt",2));il.Emit(OpCodes.Ret);
 il=Reset(Method("AchievementManager","ToggleAllAchievements"));il.Emit(OpCodes.Ret);
 var gate=Method("Player","get_BlockInputs");il=gate.Body.GetILProcessor();var first=gate.Body.Instructions[0];var open=target.ImportReference(extension.Types.Single(t=>t.Name=="RecoveryGiftPanel").Fields.Single(f=>f.Name=="IsOpen"));il.InsertBefore(first,Instruction.Create(OpCodes.Ldsfld,open));il.InsertBefore(first,Instruction.Create(OpCodes.Brfalse,first));il.InsertBefore(first,Instruction.Create(OpCodes.Ldc_I4_1));il.InsertBefore(first,Instruction.Create(OpCodes.Ret));changed++;
 // ToggleMouse must not relock while the gift panel is visible.
 var toggle=Method("PlayerCamera","ToggleMouse");il=toggle.Body.GetILProcessor();first=toggle.Body.Instructions[0];il.InsertBefore(first,Instruction.Create(OpCodes.Ldsfld,open));il.InsertBefore(first,Instruction.Create(OpCodes.Brfalse,first));il.InsertBefore(first,Instruction.Create(OpCodes.Ldc_I4_1));il.InsertBefore(first,Instruction.Create(OpCodes.Starg_S,toggle.Parameters[0]));changed++;
 assembly.Write(output);Console.WriteLine("Original metadata preserved; isolated/adapter method changes: "+changed);
 }
}


