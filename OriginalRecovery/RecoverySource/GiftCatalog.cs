using System;
using System.Collections.Generic;
namespace FishSandbox {
 [Serializable] public class GiftDefinition {
  public string id, name, group, description, channel; public float duration, value;
  public GiftDefinition(string id,string name,string group,string description,float duration=0,float value=1,string channel=null){this.id=id;this.name=name;this.group=group;this.description=description;this.duration=duration;this.value=value;this.channel=channel??id;}
 }
 public static class GiftCatalog {
  public static readonly List<GiftDefinition> All=new List<GiftDefinition>{
   new("chaos/spawn_fish","召唤鱼群","召唤","在玩家前方生成指定鱼类。",0,1),
   new("chaos/launch","起飞！","整蛊","给玩家向上的冲量。",0,24),
   new("inventory/drop_all","背包散落","整蛊","将背包鱼获全部掉落到地面。"),
   new("status/ignite","烈火灼烧","状态","持续受到火焰伤害。",8),
   new("money/add","金币红包","增益","获得金币。",0,500),
   new("player/heal","恢复生命","增益","恢复生命值。",0,25),
   new("player/damage","恶作剧伤害","整蛊","扣除生命值，可导致倒地。",0,20),
   new("money/remove","金币小偷","整蛊","扣除金币，最低为零。",0,250),
   new("player/feed","加餐","增益","恢复饱食度。",0,25),
   new("status/poison","毒雾缠身","状态","持续中毒并受到伤害。",10),
   new("chaos/spawn_drip_fish","潮流鱼","召唤","生成带金色装饰的高价值鱼。"),
   new("player/return_to_spawn","回到码头","增益","立即返回出发码头。"),
   new("status/cleanse","净化","增益","清除中毒和燃烧。"),
   new("movement/speed_boost","疾速奔跑","移动","提高步行与冲刺速度。",15,2,"movement"),
   new("movement/super_jump","超级跳跃","移动","提高跳跃冲量。",15,2,"jump"),
   new("fishing/quick_bite","瞬间咬钩","钓鱼","下一次抛竿瞬间咬钩；已有浮漂时立即生效。"),
   new("fishing/fast_reel","快速收线","钓鱼","提高收线速度。",15,3,"reel"),
   new("fishing/line_guard","鱼线保护","钓鱼","降低拉力增长，保护下一次鱼获。",0,.7f),
   new("bait/refill","补充鱼饵","钓鱼","补充鱼饵。",0,5),
   new("birds/protect_catch","驱散海鸥","钓鱼","赶走附近偷鱼的海鸥，保护鱼获。"),
   new("weapon/refill_ammo","弹药补给","战斗","为步枪装满弹匣。"),
   new("weapon/steady_aim","稳定瞄准","战斗","减小散布与后坐力。",15,.25f,"weapon"),
   new("loot/next_drip","下一条潮流鱼","钓鱼","下一条钓到的鱼获得潮流外观和额外价值。"),
   new("loot/next_heavy_fish","下一条巨重鱼","钓鱼","下一条钓到的鱼重量提升。",0,3),
   new("economy/next_sale_boost","双倍售鱼","增益","下一次售鱼获得额外收益。",0,2),
   new("combat/damage_boost","伤害提升","战斗","提高步枪与近战伤害。",15,2),
   new("boat/speed_boost","快艇模式","船只","提高驾驶速度。",15,2),
   new("player/hunger","饥饿袭来","整蛊","降低饱食度。",0,25),
   new("movement/slow","步履蹒跚","移动","降低移动速度。",12,.5f,"movement"),
   new("movement/weak_jump","沉重双腿","移动","降低跳跃冲量。",12,.5f,"jump"),
   new("controls/reverse","反向操控","移动","反转前后左右移动输入。",10),
   new("controls/force_crouch","强制蹲伏","移动","强制保持蹲伏并降低视角。",5),
   new("weapon/empty_mag","弹匣清空","战斗","清空当前弹匣。"),
   new("weapon/max_recoil","强力后坐","战斗","大幅增加开枪后坐力。",10,4,"weapon"),
   new("weapon/max_spread","子弹乱飞","战斗","扩大射击散布。",10,4,"weapon"),
   new("fishing/slow_reel","缓慢收线","钓鱼","降低收线速度。",10,.5f,"reel"),
   new("fishing/slow_bite","慢悠悠咬钩","钓鱼","下一次抛竿的等待时间延长。",0,2),
   new("birds/raid","海鸥突袭","召唤","海鸥飞来争抢背包中的鱼获。",0,1),
   new("boss/heal","首领回血","战斗","为存活首领恢复最大生命的百分比。",0,10),
   new("visual/hide_hud","隐藏 HUD","视觉","隐藏游戏 HUD；礼物控制面板保持可用。",8),
   new("visual/deep_fog","海上浓雾","视觉","用浓雾遮蔽远处景物。",8,.06f),
   new("player/freeze","原地冰封","移动","冻结移动和跳跃。",5),
   new("chaos/yeet_held_item","扔飞手持物","整蛊","将手中鱼或工具向前抛出，可拾回。",0,24),
   new("chaos/spawn_item","物资空投","召唤","生成物资箱，可拾取获得补给。"),
   new("chaos/spawn_giant_fish","巨型鱼","召唤","在前方生成巨大鱼类。",0,3),
   new("chaos/spawn_tiny_fish","迷你鱼","召唤","在前方生成微型鱼类。",0,.35f),
   new("chaos/spawn_boss","召唤首领","召唤","召唤带血条、会攻击玩家的巨型鱼首领。"),
   new("chaos/dynamite","炸药惊喜","召唤","生成倒计时炸药，范围内受到伤害与冲量。",0,3),
   new("chaos/boat_boost","船只冲刺","船只","给船只向前的冲量。",0,18),
   new("chaos/boat_spin","旋转小船","船只","给船只旋转冲量。",0,2),
   new("chaos/random_skin","随机换装","整蛊","改变当前手持物的配色。"),
   new("chaos/cook_held_fish","即刻烤鱼","钓鱼","将手持鱼烤熟，可食用或出售。"),
   new("visual/sunset","落日时分","视觉","切换为温暖的日落光照。",30),
   new("visual/vignette_flash","彩色冲击","视觉","短时间显示彩色屏幕边缘。",5),
   new("visual/slow_motion","慢动作","视觉","减慢世界时间，持续时间按真实时间计算。",8,.5f,"time"),
   new("visual/speed_up","时间加速","视觉","加快世界时间，与慢动作依次执行。",8,1.5f,"time")
  };
  public static GiftDefinition Find(string id)=>All.Find(x=>x.id==id);
 }
}
