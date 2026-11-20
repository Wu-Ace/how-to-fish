# How to Fish 原资源恢复

目标：独立 Unity 6000.3.26f1 工程，恢复原资源、12 个场景、玩法，再接原插件的 56 个礼物。旧根目录简化原型不作为验收成果。

## 两条运行路径

- `RecoveredProject/ExportedProject`：可编辑的 Unity 6000.3.26f1 工程。源码构建包在 `Builds/EditorRebuilt/HowToFishRecovered.exe`，礼物端口 6097。当前正在修复并验收，不能用编译成功替代实机通过。
- `Builds/OriginalRuntime`：保留原作编译资源和原玩法程序集、做离线/存档隔离适配的保真参照包，端口 6096。此包通过过 81 项检查，但它的通过不能算作源码独立包通过。

`RecoverySource` 是礼物面板、存档隔离、输入兼容和运行验证脚本；`GameSource` 是反编译后的原玩法源码。原插件 DLL 保留在两个运行包的 BepInEx 中。F8 打开/关闭面板。武器、鱼、首领类礼物仍遵守原插件的对象前置条件。

## 构建和验证

在根目录 PowerShell：

```powershell
& 'E:\UnityHub\6000.3.26f1\Editor\Unity.com' -batchmode -quit -projectPath "$PWD\OriginalRecovery\RecoveredProject\ExportedProject" -executeMethod RecoveryEditor.Build -logFile "$PWD\OriginalRecovery\Evidence\editor-build-current.log"
& .\OriginalRecovery\RunEditorRecovered.ps1 -Verify -ExitAfterTest
& .\OriginalRecovery\RunEditorRecovered.ps1 -Fishing -ExitAfterTest
```

Unity 输入系统使用为 6000.3 编译的官方 Input System 1.20.1 运行时，同时启用新旧输入后端。UI/字体组件由同版本官方 UGUI 包编译。Steam 启动组件只从独立包的构建场景中移除，采用原游戏已有离线传输。

## 资源和验收边界

12 场景、182 个预制体、329 份游戏反编译源码已导出。保真参照包校验了 319 个原数据文件：315 个完全相同，其余 4 个是已记录的隔离/入口适配；原插件 DLL 一致。完整记录见 `Evidence/recovery-integrity.json`。

原作 Shader Graph 和 VFX 图源未从成品中恢复。导出的占位 shader 正在用官方管线 shader 和保留原材质参数的重建代码替换。重建 shader 不是原始图源码，也不能据此声称画面已一比一。

源码独立包证据写入 `Evidence/EditorRuntime`，保真参照包证据在 `Evidence/Runtime`。原游戏安装文件和正式存档不作修改，恢复存档在 `LocalSaves`。

E 盘曾耗尽空间；恢复工程的可再生 `Library` 已迁到本聊天获准的 C 盘工作目录，并通过目录链接保留原路径。缓存可重建。

编辑器 Play 修复：RecoveryEditorOfflineGuard 在编辑态进入 Play 前移除恢复场景的 SteamworksBehaviour / SteamworksCreator，补齐原先仅在构建场景处理器中执行的离线处理。当前用户编辑器已占用，尚未完成该编辑器的停止、重编译、再次 Play 验证。另发现编辑器 InputUpdateType.Editor 异常，需与导出包兼容验证分开处理。

受伤后紫色块：Blood 1/2/3 使用未恢复的 URPDecal shader。源码改为 RecoverySurfaceMarks + Resources/RecoverySurfaceMark.shader 渲染血迹，保留开关并限制数量/寿命。当前仅源码修改，编辑器占用，尚未重建 EditorRebuilt 包或验证鱼类攻击实际截图。

抽奖机旁白色矩形：SlotMachineBackground 仍为 DummyShaderTextExporter 不透明占位 shader，已补 UI 透明混合、顶点颜色和模板/裁剪支持，并以原主次色重建背景。尚未更新正在运行的 EXE，需新包验证实际抽奖机画面。
