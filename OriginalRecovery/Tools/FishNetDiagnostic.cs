using System;
using Mono.Cecil;
public static class FishNetDiagnostic {
 public static void Patch(string source,string output){var resolver=new DefaultAssemblyResolver();resolver.AddSearchDirectory(System.IO.Path.GetDirectoryName(source));var a=AssemblyDefinition.ReadAssembly(source,new ReaderParameters{AssemblyResolver=resolver});int count=0;foreach(var t in a.MainModule.Types){if(t.FullName!="FishNet.Managing.Client.ClientManager")continue;foreach(var m in t.Methods){if(!m.HasBody)continue;foreach(var i in m.Body.Instructions){var r=i.Operand as MethodReference;if(r!=null&&r.Name=="get_Message"&&r.DeclaringType.FullName=="System.Exception"){r.Name="ToString";count++;}}}}a.Write(output+".patched");System.IO.File.Copy(output+".patched",output,true);System.IO.File.Delete(output+".patched");Console.WriteLine("Client exception diagnostics: "+count);}
}
