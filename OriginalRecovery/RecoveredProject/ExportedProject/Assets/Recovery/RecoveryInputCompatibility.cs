using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;
public class RecoveryInputCompatibility:MonoBehaviour {
#if RECOVERY_UNITY_PROJECT
 [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Install(){if(UnityEngine.SceneManagement.SceneManager.GetActiveScene().name=="OriginalArtReview")return;var o=new GameObject("Recovered input initialization");DontDestroyOnLoad(o);o.AddComponent<RecoveryInputCompatibility>();}
 IEnumerator Start(){yield return null;var input=GameInfo.Input;if(input==null){Debug.LogError("[RecoveryInput] Missing original PlayerInput");yield break;}
 Debug.Log("[RecoveryInput] enabled="+input.enabled+" active="+input.gameObject.activeInHierarchy+" user="+input.user.valid+" actions="+(input.actions!=null));
 if(!input.user.valid){input.enabled=false;input.defaultControlScheme="Keyboard";input.enabled=true;input.ActivateInput();}
 Debug.Log("[RecoveryInput] ready="+input.user.valid+" scheme="+input.currentControlScheme);
 }
#endif
}
