# 美术来源与商用许可核查（进行中）

截至 2026-11-18。仅有相似风格、文件名或 Unity `.meta` 中的 `licenseType: Free`，不作为素材商用授权证明。

| 资源 | 可确认来源 / 证据 | 状态 | 当前处理 |
|---|---|---|---|
| 原游戏模型、岛屿、贴图、角色 | Steam 成品提取；场景片尾有 Graphics 署名 Melvin Olsson / Carl-Vilhelm Johansson；[开发商官网](https://dazed.games/) | 未找到用于另一款商业游戏的免费许可 | 保留为本地还原和比对参考；不能宣称商业授权已清 |
| Underdog 字体 | [Google Fonts 上游及 OFL](https://github.com/google/fonts/tree/main/ofl/underdog) | OFL-1.1，可随软件商用分发，需附版权和许可 | 已从官方仓库下载，替换两份同名字体文件，保留原 GUID |
| 站酷快乐体 | [Google Fonts 上游及 OFL](https://github.com/google/fonts/tree/main/ofl/zcoolkuaile) | OFL-1.1，同上 | 已换入官方文件 |
| Noto Sans SC / JP / KR / TC | [Google Fonts](https://github.com/google/fonts/tree/main/ofl/notosanssc) 及各家族 OFL | OFL-1.1，同上 | 已换入官方家族文件，共 12 处引用文件 |
| Quaternius Animated Fish Pack | [作者原页](https://quaternius.com/packs/animatedfish.html)，页面明确 CC0 和个人/商业用途 | CC0-1.0 | 从作者链接的公开 Drive 目录获取 7 个 FBX，作为可商用替换候选；未证明它就是原游戏来源 |
| Kenney Fish Pack | [作者原页](https://kenney.nl/assets/fish-pack) | CC0-1.0，2D 素材 | 仅作 UI 图标候选，不冒充原作 3D 模型来源 |
| PerfectDOSVGA437 字体 | [作者发布页](https://www.dafont.com/perfect-dos-vga-437.font) 下载包内 `dos437.txt`，署名 Zeh Fernando | 作者自定义许可允许分发、电子游戏等用途，禁止单独售卖字体；不是 CC0/OFL | 已保存原包、作者说明及工程内许可副本；项目字体版本核对见补充记录 |
| Kenney Nature Kit 2.1 | [官方页面](https://kenney.nl/assets/nature-kit)及压缩包内 License.txt | CC0-1.0，允许商业用途 | 已下载核验，暂存 LicensedArtSources/Kenney/nature-kit；用于树木、岩石、植被替换候选 |
| Kenney Pirate Kit 2.1 | [官方页面](https://kenney.nl/assets/pirate-kit)及压缩包内 License.txt | CC0-1.0，允许商业用途 | 已下载核验，暂存 LicensedArtSources/Kenney/pirate-kit；用于船、码头、棕榈树和道具替换候选；角色风格偏卡通 |
| Quaternius Pirate Kit | [作者页面](https://quaternius.com/packs/piratekit.html) | 页面明确 CC0、个人及商业用途 | 71 个模型，含动画角色和环境；已核查页面，尚未下载，不计入已接入素材 |
| 原包音效 / 音乐 | 片尾出现 Patrik Carlsson、Alexander Fuentes、zapsplat.com 等 | 尚未逐文件核清 | 不因游戏包含它们就推定可以转用于另一项目 |

## 已保存的许可证据

- 字体原始下载与 OFL：`LicensedArtSources/GoogleFonts`。
- 字体接入路径、时间与 SHA-256：`Evidence/licensed-fonts.json`。
- 随工程保存的字体许可：`RecoveredProject/ExportedProject/Assets/ThirdPartyNotices/Fonts`。
- 旧字体仅作参考备份：`ReferenceOnly/OriginalFonts`。
- 鱼模型作者来源、许可与 SHA-256：`Evidence/licensed-fish-models.json`。
- 自然及海盗素材包的作者来源、包内许可原文与 SHA-256：`Evidence/licensed-environment-packs.json`。
- PerfectDOS 原始作者说明：`LicensedArtSources/PerfectDOS/upstream/dos437.txt`；工程副本在 `Assets/ThirdPartyNotices/Fonts/PerfectDOS`。

## 替代范围与视觉核对

已查看两套 Kenney 官方预览：两者均为纯色、低多边形风格。Nature Kit 适合树木、石块和棕榈树；Pirate Kit 适合木船、木板、码头、桶、箱子和热带岛屿道具。后者人物与船体比例偏卡通，需要在游戏镜头中对照调整，不能据此认定一比一匹配。

环境素材当前仅完成下载、许可检查和风格初筛，尚未绑定现有玩法预制体。原版海岛地形、角色轮廓和专属道具若无精确替代，将需要自行建模或重新组合这些已授权资源。原版资源的免费商业复用许可仍未找到；原版署名只能支持来源调查，不能代替授权。

开发商官网公开许可明确提到的是直播、录屏与视频变现。这里没有将这段许可扩大解释为模型、贴图或游戏代码可以在另一款商业游戏中再分发。收费或授权不明的素材不会自动购买，也不会被标注为免费商用。

本报告核查美术素材，不代表整个反编译工程或原礼物插件的商业授权已经清理完毕。

PerfectDOS 版本补充：已比较 SHA-256；项目文件与作者发布的 437 版本一致=True。若有差异，已备份旧文件并换入作者原始 TTF，保留 Unity GUID。记录：Evidence/licensed-perfectdos.json。

新增项目自制模型：OriginalArt/Blender 中 6 个 blend，ArtOriginal 中 6 个 FBX 与预制体。生成器不读取原包网格、贴图、骨骼；用于替代方案，尚未完成所有原玩法场景替换。
