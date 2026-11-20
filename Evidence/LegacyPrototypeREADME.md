# How to Fish：独立玩法重实现与礼物控制台

工程版本：**Unity 6000.3.26f1**。双击 `启动游戏.cmd` 或 `Builds/HowToFish/HowToFish.exe` 启动。

## 游戏内操作

右侧面板有 HypeMyStream 0.2.3 插件对应的 **56 个事件**。按类别或名称搜索，选择礼物，调节时间、数值、数量并触发。“恢复全部”清除持续、排队和待用效果。

Tab / F1 收起面板；WASD 移动，鼠标转向，Space 跳跃，Shift 冲刺，Ctrl 蹲伏。1 鱼竿，2 步枪，3 手持鱼；E 交互，F 近战，G 抛出。

到码头边朝海面点击左键抛竿，咬钩后点击提竿，按住左键收线，张力过高时松开。右键取消。靠近鱼市按 E 售鱼，靠近营火按 E 烤鱼；手持鱼时左键食用。靠近船按 E 驾驶，W/S 前后，A/D 转向，E 下船。步枪按 R 花费金币补弹。倒地后 Enter 复活。

同一移动、跳跃、收线、武器、时间通道中的持续礼物依次执行，按真实秒数计时。咬钩礼物按触发顺序消耗。

## 网页控制台

双击 `启动礼物控制台.cmd`，打开 `http://127.0.0.1:6092/`。需要本机已有的 Node.js，不需要 npm 安装。游戏内面板无需 Node.js。

- **独立重实现 · 6091**：控制本工程导出的游戏。
- **Steam 原版 + 插件 · 6090**：直接触发原游戏插件的实际礼物，需从 Steam 启动原游戏并进入存档，且加载 HypeMyStream 插件。

部分原版礼物需要手持鱼、武器、现存首领、正在钓鱼或可用船只。接口“请求已接收”表示进入主线程队列，实际失败原因看状态区。所有服务仅监听本机，不连接直播平台。

## 交付范围与边界

独立版包含第一人称群岛、钓鱼张力、背包、售鱼、烤鱼进食、生命饥饿、船只、步枪近战、首领、海鸥、爆炸和 56 个事件的对应实现。场景与模型由本工程程序生成，没有复制原游戏 EXE、DLL 或美术资源。

**这不是原作全部内容的 1:1 重建。** 完整原作地图、美术模型、剧情任务、全部生物行为与武器、角色系统和 Steam 联机没有完整复刻。原版 11 个鱼种名称已作为独立版数据标签，模型与 AI 仍为简化实现。独立版礼物在自己的玩法对象上生效，视觉和数值细节不保证逐项相同。需要原版实际表现时可使用网页控制台的原版模式。

## 验证与开发

最终候选 Windows 包通过 **184 项运行时断言，0 失败**。包括全部事件、状态变化、队列和到期恢复、实际位移碰撞、完整钓鱼推进、净化停止伤害、射线命中首领和隔离存档序列化。完整人工游玩、全图遍历、全部原版礼物逐项画面对照和多设备测试并未全部完成。详见 `Evidence/acceptance.md`。

正常存档：`AppData/LocalLow/LocalReconstruction/How to Fish - Gift Sandbox/harbor-save.json`。不读取原游戏存档；自动回归不覆盖正常存档。

场景：`Assets/Scenes/Harbor.unity`。入口：`Assets/Scripts/FishingGame.cs`。礼物目录：`Assets/Scripts/GiftCatalog.cs`。

批量构建：`Unity.com -batchmode -nographics -quit -projectPath "工程路径" -executeMethod ProjectBuilder.Build -logFile "日志路径"`。

回归：`HowToFish.exe -fish-selftest -screen-width 1600 -screen-height 900 -screen-fullscreen 0 -logFile "日志路径"`，结果写入工程 `Evidence`。

