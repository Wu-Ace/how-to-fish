from pathlib import Path
p=Path(__file__).resolve().parents[1]/'RecoverySource/RecoveryGiftPanel.cs'
s=p.read_text(encoding='utf-8-sig')
s=s.replace('using FishSandbox;', 'using FishSandbox;\nusing Newtonsoft.Json.Linq;')
s=s.replace('string fish="random";', 'string fish="random",numberText="1";')
s=s.replace('[Recovery] Original source runtime;', '[Recovery] Original gameplay with isolated recovery extension;')
s=s.replace('number=d.value;quantity=1;', 'number=d.value;numberText=number.ToString(System.Globalization.CultureInfo.InvariantCulture);quantity=1;')
s=s.replace('GUI.Box(new Rect(900,10,690,880),"");', 'var savedColor=GUI.color;GUI.color=new Color(.045f,.075f,.095f,.97f);GUI.DrawTexture(new Rect(900,10,690,880),Texture2D.whiteTexture);GUI.color=savedColor;')
s=s.replace('list[i].name+"   "+list[i].id','list[i].name')
s=s.replace('string n=GUI.TextField(new Rect(1115,673,120,30),number.ToString(System.Globalization.CultureInfo.InvariantCulture),field);if(float.TryParse(n,','numberText=GUI.TextField(new Rect(1115,673,120,30),numberText,field);if(float.TryParse(numberText,')
s=s.replace('GUI.Label(new Rect(925,762,630,48),result,small);GUI.Label(new Rect(925,812,630,65),state,small);', 'GUI.Label(new Rect(925,762,630,48),FriendlyResult(),small);GUI.Label(new Rect(925,812,630,65),FriendlyState(),small);')
insert='''
 string FriendlyResult(){if(string.IsNullOrEmpty(result))return "先选择礼物，再点击触发。武器、鱼和首领类礼物需要对应对象。";try{var j=JObject.Parse(result);return (bool?)j["ok"]==true?"礼物已发送，执行结果见下方状态。":(string)j["error"]??result;}catch{return result;}}
 string FriendlyState(){try{var j=JObject.Parse(state);if((bool?)j["inWorld"]!=true)return "礼物模块已连接 · 进入存档后即可触发";string error=(string)j["lastError"];string last=(string)j["lastEvent"];var gift=GiftCatalog.All.FirstOrDefault(g=>g.id==last);return "生命 "+j["health"]+"  ·  饱食 "+j["fullness"]+"  ·  金币 "+j["money"]+"  ·  已执行 "+j["eventCount"]+" 次\\n"+(string.IsNullOrEmpty(error)?(gift==null?"已准备就绪":"最近执行："+gift.name):"未生效："+error);}catch{return state;}}
'''
s=s.replace(' string Body(string id)',insert+' string Body(string id)')
p.write_text(s,encoding='utf-8')
