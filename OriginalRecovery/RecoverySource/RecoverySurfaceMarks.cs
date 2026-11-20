using System.Collections.Generic;
using UnityEngine;
public class RecoverySurfaceMarks:MonoBehaviour
{
 static readonly Queue<RecoverySurfaceMarks> active=new Queue<RecoverySurfaceMarks>();
 static Material material;Mesh mesh;Renderer surface;float born;
 public static void Spawn(string kind,Vector3 position,Vector3 normal,float size)
 {
  if(!material){var shader=Resources.Load<Shader>("RecoverySurfaceMark");if(!shader||!shader.isSupported){Debug.LogError("[Recovery] Surface mark shader unavailable");return;}material=new Material(shader);}
  while(active.Count>=48){var old=active.Dequeue();if(old)Destroy(old.gameObject);}
  var o=new GameObject("Recovered surface mark "+kind);var effect=o.AddComponent<RecoverySurfaceMarks>();
  normal=normal.sqrMagnitude>.001f?normal.normalized:Vector3.up;o.transform.SetPositionAndRotation(position+normal*.018f,Quaternion.LookRotation(normal));
  var v=new Vector3[25];var tri=new int[72];float radius=Mathf.Clamp(size,.03f,5)*.5f;
  for(int i=0;i<24;i++){float angle=i*Mathf.PI/12;float edge=radius*(.80f+.13f*Mathf.Sin(i*2.7f)+.07f*Mathf.Cos(i*4.1f));v[i+1]=new Vector3(Mathf.Cos(angle)*edge,Mathf.Sin(angle)*edge,0);tri[i*3]=0;tri[i*3+1]=i+1;tri[i*3+2]=(i+1)%24+1;}
  effect.mesh=new Mesh{name="Recovered irregular surface splat"};effect.mesh.vertices=v;effect.mesh.triangles=tri;effect.mesh.RecalculateBounds();o.AddComponent<MeshFilter>().sharedMesh=effect.mesh;
  effect.surface=o.AddComponent<MeshRenderer>();effect.surface.sharedMaterial=material;effect.surface.shadowCastingMode=UnityEngine.Rendering.ShadowCastingMode.Off;effect.surface.receiveShadows=false;effect.born=Time.time;active.Enqueue(effect);
 }
 void Update(){float age=Time.time-born;var p=new MaterialPropertyBlock();p.SetColor("_Color",new Color(.32f,.012f,.008f,Mathf.Clamp01((24-age)/4)*.78f));surface.SetPropertyBlock(p);if(age>24)Destroy(gameObject);}
 void OnDestroy(){if(mesh)Destroy(mesh);}
}
