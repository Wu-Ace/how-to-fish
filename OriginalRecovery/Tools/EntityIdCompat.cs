using System;
using System.Collections.Generic;
using Mono.Cecil;
using Mono.Cecil.Cil;
public static class EntityIdCompat {
 static IEnumerable<TypeDefinition> Types(IEnumerable<TypeDefinition> ts){foreach(var t in ts){yield return t;foreach(var n in Types(t.NestedTypes))yield return n;}}
 public static void Patch(string source,string output){var resolver=new DefaultAssemblyResolver();resolver.AddSearchDirectory(System.IO.Path.GetDirectoryName(source));var a=AssemblyDefinition.ReadAssembly(source,new ReaderParameters{AssemblyResolver=resolver});var module=a.MainModule;var calls=new List<Instruction>();MethodReference old=null;
 foreach(var t in Types(module.Types))foreach(var m in t.Methods){if(!m.HasBody)continue;foreach(var i in m.Body.Instructions){var r=i.Operand as MethodReference;if(r!=null&&r.DeclaringType.FullName=="UnityEngine.EntityId"&&r.Name=="ToULong"){old=r;calls.Add(i);}}}
 if(old==null){Console.WriteLine("No EntityId adapter needed: "+source);return;}
 var bridge=new TypeDefinition("RecoveryCompat","EntityIdBridge",TypeAttributes.NotPublic|TypeAttributes.Abstract|TypeAttributes.Sealed,module.TypeSystem.Object);module.Types.Add(bridge);var method=new MethodDefinition("ToULong",MethodAttributes.Public|MethodAttributes.Static,module.TypeSystem.UInt64);method.Parameters.Add(new ParameterDefinition(old.DeclaringType));bridge.Methods.Add(method);
 var convert=new MethodReference("op_Implicit",module.TypeSystem.Int32,old.DeclaringType){HasThis=false};convert.Parameters.Add(new ParameterDefinition(old.DeclaringType));var il=method.Body.GetILProcessor();il.Emit(OpCodes.Ldarg_0);il.Emit(OpCodes.Call,convert);il.Emit(OpCodes.Conv_U8);il.Emit(OpCodes.Ret);
 foreach(var i in calls)i.Operand=method;a.Write(output+".patched");System.IO.File.Copy(output+".patched",output,true);System.IO.File.Delete(output+".patched");Console.WriteLine("6000.3 EntityId compatibility calls: "+calls.Count);
 }
}
