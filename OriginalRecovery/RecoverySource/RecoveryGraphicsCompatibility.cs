using UnityEngine;
public static class RecoveryGraphicsCompatibility {
#if RECOVERY_UNITY_PROJECT
 [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]static void Initialize(){Unity.Burst.BurstCompiler.Options.EnableBurstCompilation=false;}
#endif
}
