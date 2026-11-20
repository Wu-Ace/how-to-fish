using UnityEngine;
namespace FishSandbox {
 public enum EntityKind{Fish,Item,Tool,Bird,Boss,Dynamite}
 public class WorldEntity:MonoBehaviour {
  public FishingGame game;public EntityKind kind;public CatchData catchData;public float health=20,maxHealth=20,life=120;public int toolIndex;public Vector3 velocity;float hitAt,age;bool stolen;
  void Update(){age+=Time.deltaTime;life-=Time.deltaTime;if(kind==EntityKind.Boss){var target=game.body.transform.position;var delta=target-transform.position;delta.y=0;float d=delta.magnitude;if(d>3)velocity=delta.normalized*2.3f;else{velocity=Vector3.zero;if(Time.time>hitAt){game.Damage(12);game.impulse+=delta.normalized*5;hitAt=Time.time+2;}}if(delta.sqrMagnitude>0.1f)transform.rotation=Quaternion.LookRotation(delta);transform.position+=velocity*Time.deltaTime;var p=transform.position;p.y=Ground(p)+2+Mathf.Sin(Time.time*2)*.3f;transform.position=p;return;}
   if(kind==EntityKind.Bird){var target=game.body.transform.position+Vector3.up*2;transform.position=Vector3.MoveTowards(transform.position,target,5*Time.deltaTime);if(Vector3.Distance(transform.position,target)<1.3f&&!stolen){stolen=true;if(game.bag.Count>0){var c=game.bag[game.bag.Count-1];game.bag.RemoveAt(game.bag.Count-1);if(game.held==c){game.held=game.bag.Count>0?game.bag[game.bag.Count-1]:null;game.ShowHeld();}game.Notice("海鸥偷走了一条鱼！");}life=Mathf.Min(life,3);}if(stolen)transform.position+=Vector3.up*4*Time.deltaTime;if(life<=0)Remove();return;}
   velocity.y-=9*Time.deltaTime;transform.position+=velocity*Time.deltaTime;float floor=Ground(transform.position)+.4f;if(transform.position.y<floor){var p=transform.position;p.y=floor;transform.position=p;velocity=new Vector3(velocity.x*.9f,Mathf.Abs(velocity.y)*.18f,velocity.z*.9f);}if(kind==EntityKind.Dynamite){transform.localScale=Vector3.one*(1+Mathf.Sin(age*16)*.08f);if(life<=0){Explode();return;}}else if(life<=0)Remove();
  }
  float Ground(Vector3 p){float height=-.3f;foreach(var hit in Physics.RaycastAll(p+Vector3.up*80,Vector3.down,160)){if(hit.collider.GetComponentInParent<WorldEntity>()||hit.collider is CharacterController)continue;height=Mathf.Max(height,hit.point.y);}return height;}
  public void Hit(float damage){health-=damage;if(health<=0){if(kind==EntityKind.Boss){game.coins+=200;game.Notice("击败首领！金币 +200");game.SpawnFish(transform.position,1.8f,true,false);}Remove();}}
  public void Explode(){var pos=transform.position;var blast=game.world.Shape("Explosion",PrimitiveType.Sphere,pos,Vector3.one*7,new Color(1,.45f,.08f),null,false);Destroy(blast,.2f);float d=Vector3.Distance(pos,game.body.transform.position);if(d<8){game.Damage(Mathf.Lerp(50,5,d/8));game.impulse+=(game.body.transform.position-pos).normalized*15;game.vertical=8;}foreach(var e in game.entities.ToArray())if(e&&e!=this&&Vector3.Distance(e.transform.position,pos)<8)e.Hit(100);game.Notice("轰！炸药爆炸");Remove();}
  public void Remove(){game.entities.Remove(this);Destroy(gameObject);}
 }
}
