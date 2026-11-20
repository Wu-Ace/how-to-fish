using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
namespace FishSandbox {
 public class GiftSegment { public GiftDefinition gift; public float remaining,value; public int count; public string target; }
 public class GiftEngine {
  public readonly List<GiftSegment> active=new(); public readonly Dictionary<string,Queue<GiftSegment>> queues=new();
  public readonly Queue<string> log=new(); public readonly Dictionary<string,int> counts=new();
  public int EventCount{get;private set;} public string LastEvent="", LastError=""; readonly FishingGame game;
  public GiftEngine(FishingGame game){this.game=game;}
  public float Value(string id,float fallback=1){var a=active.Find(x=>x.gift.id==id);return a==null?fallback:a.value;}
  public bool Has(string id)=>active.Exists(x=>x.gift.id==id);
  public void Note(string text){log.Enqueue(DateTime.Now.ToString("HH:mm:ss")+"  "+text);while(log.Count>30)log.Dequeue();game.Notice(text);}
  public bool Trigger(string id,float duration=-1,float value=float.NaN,int count=1,string target="random"){
   var d=GiftCatalog.Find(id);if(d==null){LastError="未知礼物："+id;return false;}
   var seg=new GiftSegment{gift=d,remaining=Mathf.Clamp(duration<0?d.duration:duration,0,120),value=float.IsNaN(value)?d.value:Mathf.Clamp(value,-10000,10000),count=Mathf.Clamp(count,1,20),target=target};
   if(d.duration>0&&seg.remaining<=0)seg.remaining=1;
   if(!game.CanApply(d,out var reason)){LastError=reason;Note(d.name+"："+reason);return false;}
   EventCount++;LastEvent=id;LastError="";counts[id]=counts.TryGetValue(id,out var n)?n+1:1;
   if(d.duration>0){if(active.Exists(x=>x.gift.channel==d.channel)){if(!queues.TryGetValue(d.channel,out var q)){q=new();queues[d.channel]=q;}q.Enqueue(seg);Note(d.name+" 已排队");}else{active.Add(seg);Note(d.name+" 已生效");}}
   else{game.ApplyInstant(seg);Note(d.name+" 已触发");}return true;
  }
  public void Tick(float realDelta){for(int i=active.Count-1;i>=0;i--){var a=active[i];a.remaining-=realDelta;if(a.remaining<=0){active.RemoveAt(i);if(queues.TryGetValue(a.gift.channel,out var q)&&q.Count>0){var next=q.Dequeue();active.Add(next);Note(next.gift.name+" 接续生效");}}}Time.timeScale=Has("visual/slow_motion")?Mathf.Clamp(Value("visual/slow_motion"),.1f,1):Has("visual/speed_up")?Mathf.Clamp(Value("visual/speed_up"),1,3):1;Time.fixedDeltaTime=.02f*Time.timeScale;}
  public void Remove(string id){active.RemoveAll(x=>x.gift.id==id);foreach(var key in queues.Keys.ToArray())queues[key]=new Queue<GiftSegment>(queues[key].Where(x=>x.gift.id!=id));}
  public void Clear(){active.Clear();queues.Clear();game.ClearPendingGifts();Time.timeScale=1;Time.fixedDeltaTime=.02f;}
  public int QueueCount(string channel)=>queues.TryGetValue(channel,out var q)?q.Count:0;
 }
}
