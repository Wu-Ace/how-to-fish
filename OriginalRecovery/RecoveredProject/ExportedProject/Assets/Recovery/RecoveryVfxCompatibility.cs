using UnityEngine;
public static class RecoveryVfxCompatibility {
 public static int Spawned {get;private set;}
 static Material material;static Mesh triangle;
 public static void Play(string type,Vector3 position,Vector3 direction){if(position.y< -500||string.IsNullOrEmpty(type))return;Spawned++;
 if(!material){material=new Material(Shader.Find("Shader Graphs/DefaultParticle"));material.SetColor("_Color",Color.white);}
 if(!triangle){triangle=new Mesh{name="Recovered VFX triangle"};triangle.vertices=new[]{new Vector3(-.5f,-.4f,0),new Vector3(.5f,-.4f,0),new Vector3(0,.6f,0)};triangle.uv=new[]{Vector2.zero,Vector2.right,Vector2.up};triangle.triangles=new[]{0,1,2};triangle.RecalculateNormals();}
 string name=type.ToLowerInvariant();bool water=name.Contains("water"),blood=name.Contains("blood"),lava=name.Contains("lava")||name.Contains("volcano"),poison=name.Contains("poison"),explosion=name.Contains("explosion");Color color=water?new Color(.7f,.87f,1):blood?new Color(.65f,.03f,.02f):lava?new Color(1,.32f,.025f):poison?new Color(.3f,.85f,.12f):new Color(.65f,.57f,.46f);
 var o=new GameObject("Recovered effect "+type);o.transform.position=position;if(direction.sqrMagnitude>.01f)o.transform.rotation=Quaternion.LookRotation(direction.normalized);else o.transform.rotation=Quaternion.LookRotation(Vector3.up);
 var ps=o.AddComponent<ParticleSystem>();ps.Stop(true,ParticleSystemStopBehavior.StopEmittingAndClear);var main=ps.main;main.playOnAwake=false;main.loop=false;main.duration=.2f;main.simulationSpace=ParticleSystemSimulationSpace.World;main.startLifetime=new ParticleSystem.MinMaxCurve(.35f,explosion?1.4f:.8f);main.startSpeed=new ParticleSystem.MinMaxCurve(explosion?3:1,explosion?8:3.2f);main.startSize=new ParticleSystem.MinMaxCurve(blood ? .03f : .055f,explosion ? .32f : .16f);main.startColor=color;main.gravityModifier=water||blood?1:.3f;main.maxParticles=256;
 var emission=ps.emission;emission.rateOverTime=0;emission.SetBursts(new[]{new ParticleSystem.Burst(0,(short)(explosion?110:38))});var shape=ps.shape;shape.shapeType=ParticleSystemShapeType.Cone;shape.angle=explosion?80:48;shape.radius=explosion ? .65f : .12f;
 var lifetime=ps.colorOverLifetime;lifetime.enabled=true;var gradient=new Gradient();gradient.SetKeys(new[]{new GradientColorKey(Color.white,0),new GradientColorKey(Color.white,1)},new[]{new GradientAlphaKey(1,0),new GradientAlphaKey(0,1)});lifetime.color=gradient;
 var renderer=ps.GetComponent<ParticleSystemRenderer>();renderer.sharedMaterial=material;renderer.renderMode=ParticleSystemRenderMode.Mesh;renderer.mesh=triangle;renderer.alignment=ParticleSystemRenderSpace.View;ps.Play();Object.Destroy(o,3);}
}
