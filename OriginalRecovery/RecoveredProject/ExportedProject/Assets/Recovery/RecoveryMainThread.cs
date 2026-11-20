using System;
using System.Collections.Concurrent;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using UnityEngine;
public class RecoveryMainThread:MonoBehaviour {
 static readonly ConcurrentQueue<Action> pending=new ConcurrentQueue<Action>();static int mainThread;
 [UnityEngine.Scripting.Preserve]public static bool ShouldDispatch=>Thread.CurrentThread.ManagedThreadId!=mainThread;
 [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]static void Install(){mainThread=Thread.CurrentThread.ManagedThreadId;var o=new GameObject("Recovered main thread dispatch");DontDestroyOnLoad(o);o.AddComponent<RecoveryMainThread>();}
 [UnityEngine.Scripting.Preserve]public static object Invoke(object target,string method){if(!ShouldDispatch)return Call(target,method);var result=new TaskCompletionSource<object>();pending.Enqueue(()=>{try{result.SetResult(Call(target,method));}catch(Exception e){result.SetException(e);}});if(!result.Task.Wait(5000))throw new TimeoutException("Game state snapshot timed out");return result.Task.Result;}
 // The original GET-state handler has one unused string argument.
 static object Call(object target,string method){var m=target.GetType().GetMethod(method,BindingFlags.Instance|BindingFlags.Public|BindingFlags.NonPublic);return m.Invoke(target,m.GetParameters().Length==0?null:new object[]{null});}
 void Update(){while(pending.TryDequeue(out var action))action();}
}
