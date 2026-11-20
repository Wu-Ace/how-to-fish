# How to Fish 项目交接

更新于 2026-11-20。本文汇总原恢复聊天中的需求、决定、结果与未结事项。接手时先核对文件、构建时间和对应证据，再判断当前进度。

## 目标与历史决定

1. 用户提供了 Steam 安装和 [REA 工具](https://github.com/morluto/rea)，要求用本机 Unity 6000 系列制作可编辑工程，并能手动触发插件礼物。选定 Unity 6000.3.26f1。
2. 第一版采用程序生成场景、简化钓鱼和独立礼物实现，形成了根目录原型。用户试玩后指出与原作差距过大，要求参考 Needle Haystack 的恢复路线，先恢复原场景、资源和玩法，再接礼物面板，反复对照 Steam 原版验收。
3. 后续从 Steam 成品导出 12 个场景、182 个预制体及 329 份反编译玩法源码。保真参照包核比 319 个原数据文件，315 个一致，4 个有隔离或入口适配记录。原作 Shader Graph 和 VFX 图源未恢复，部分着色器按原材质参数重建。
4. 用户要求核查原模型、场景、贴图、UI、音效、音乐和文本能否免费商用。核清的素材保留许可，授权不清的内容找明确获授权的替代或自行制作。

## 从哪里打开

| 用途 | 路径与操作 |
| --- | --- |
| 玩当前恢复版 | [HowToFishRecovered.exe](OriginalRecovery/Builds/EditorRebuilt/HowToFishRecovered.exe)，按 **F8** 切换礼物面板，本地端口 **6097** |
| 编辑恢复工程 | [打开恢复工程.cmd](打开恢复工程.cmd) 或 Unity Hub 添加 `OriginalRecovery/RecoveredProject/ExportedProject`，Unity **6000.3.26f1**，玩法场景 `Assets/Scenes/Game.unity` |
| 比对原资源和玩法 | `OriginalRecovery/Builds/OriginalRuntime`，保留原作编译资源和程序集，离线和存档隔离适配，礼物端口 **6096** |
| 看原创角色和岛屿 | [启动原创美术预览.cmd](启动原创美术预览.cmd)，**1–5** 切岛，**Tab** 上岛行走。Unity 检视场景在恢复工程下 `Assets/ArtOriginal/Scenes/OriginalArtReview.unity` |
| 看旧原型 | [启动旧简化原型.cmd](启动旧简化原型.cmd)，使用根目录的 Unity 工程和 `Builds` |
| 验证网页礼物工具 | [启动礼物控制台.cmd](启动礼物控制台.cmd)，历史配置为 Steam **6090**、独立原型 **6091**、Node **6092**。恢复版用上面的 F8 面板 |

## 代码、构建与验证

- 新检出测试发现，19 对 DLL 的导入元数据混用了旧版平台列表和 Unity 6000.3 的序列化版本。已统一为该版本的映射格式，保留 GUID 和 Editor/Player 配置。独立副本编译并导入成功。见 [检出验证记录](OriginalRecovery/Evidence/github-clean-import-20261120.md)。

- `OriginalRecovery/GameSource` 保存反编译玩法源码，`RecoverySource` 保存礼物面板、输入兼容、存档隔离和验证相关代码。运行包的 BepInEx 中保留原礼物插件，鱼、武器、首领等礼物仍有游戏状态前置条件。
- 根目录原型曾通过 184 项运行断言，网页对独立版和 Steam 原版各触发过金币并核对状态。这些结果对应当时的原型和网页接口。见 [原型验收](Evidence/acceptance.md)。
- 保真参照包有 81 项检查的记录，并验证过抛竿、上鱼和收线。源码构建包另有检查记录，包含原插件事件和计时恢复。需要按对应运行包查看 [参照包证据](OriginalRecovery/Evidence/Runtime) 和 [源码构建包证据](OriginalRecovery/Evidence/EditorRuntime)。
- 批构建用 Unity 的 `-batchmode -quit -projectPath` 指向恢复工程，并调用 `-executeMethod RecoveryEditor.Build`。构建后执行 `./OriginalRecovery/RunEditorRecovered.ps1 -Verify -ExitAfterTest`，再执行同一脚本的 `-Fishing -ExitAfterTest`。完整命令见 [恢复说明](OriginalRecovery/README.md)。
- 输入兼容使用为 Unity 6000.3 编译的 Input System 1.20.1，启用新旧输入后端。测试存档放在 `OriginalRecovery/LocalSaves`，保留 Steam 安装与正式存档。换机器后由 Unity 重新导入缓存，并核对启动脚本的本机路径。

## 最新反馈与待验收

| 现象 | 已做处理 | 仍需验证 |
| --- | --- | --- |
| Unity Play 拉起 Steam 原版 | `RecoveryEditorOfflineGuard` 在进入 Play 前处理 Steam 启动组件 | 重编译后从编辑器实际进入 Play，检查 Steam 是否保持关闭，分别复现 `InputUpdateType.Editor` 和编辑态 Destroy 日志 |
| 被鱼击中后出现亮紫色块 | 源码用 `RecoverySurfaceMarks` 与 `RecoverySurfaceMark.shader` 替换失效的血迹贴花 | 重建 EXE 后在鱼类实战中验证血迹、选项开关、自动消退 |
| 抽奖机旁有白色矩形 | 源码已重建 `SlotMachineBackground`，补透明混合、顶点颜色和遮罩 | 重建 EXE 后在实际游戏镜头验证 |
| 岛屿出现浅色三角面 | 五种岛屿已调整为连续草地着色并保留沙滩边界，Blender、FBX 和预览构建已更新 | 原创美术仍待接入原玩法，需实测角色动画、第一人称手部、持物、岛屿碰撞和关卡布置 |

先重建并核对当次构建与证据，再逐场景对照 Steam 原版验证画面、玩法及 56 项礼物。手动触发结果只覆盖本机面板和所测插件行为。完整场景、完整玩法、编辑器 Play 和现有源码修复的合并验收仍待完成。

## 美术与许可

- Blender 自制渔夫有 15 根骨骼和待机、行走动画。五种自制岛屿为草地港湾、秋林、雪地、火山、热带。源文件在 `OriginalRecovery/OriginalArt/Blender`，Unity 预制体在恢复工程的 `Assets/ArtOriginal`。独立预览曾通过 62 项检查。
- 已核查并接入 Underdog、站酷快乐体和 Noto 系列 OFL 字体，PerfectDOS 已核对作者版本及许可。Quaternius 鱼模型和 Kenney 自然、海盗、界面音效、碰撞音效及短音乐包有候选素材，按对应玩法事件和预制体逐项接入与复测。
- 目前恢复工程和运行包仍含原作代码、编译资源、HypeMyStream 插件及其他第三方组件。其复制、修改及再分发许可尚未核清。UI、文本、贴图、长音乐和其他未核清内容的替换仍待完成。见 [授权核查](OriginalRecovery/ASSET-LICENSE-AUDIT.md)、[替换执行记录](OriginalRecovery/CONTENT-REPLACEMENT.md) 和 [逐文件清单](OriginalRecovery/Evidence/original-content-replacement-inventory.csv)。

历史需求与反馈来自 [How to Fish 恢复聊天](codex://threads/01a1ed68-d686-74d1-86ce-b07e0c507e3d)。本交接保留影响继续开发和验收的信息。
