# tdBag2

[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/DengSir/tdBag2/publish.yml?label=Publish)](https://github.com/DengSir/tdBag2/actions/workflows/publish.yml)
[![GitHub Release](https://img.shields.io/github/v/release/DengSir/tdBag2?label=Release)](https://github.com/DengSir/tdBag2/releases)
[![CurseForge Downloads](https://img.shields.io/curseforge/dt/349175?label=Curse%20downloads)](https://www.curseforge.com/wow/addons/tdbag2)

`tdBag2` 是一款简洁高效的魔兽世界 (World of Warcraft) 整合背包插件。它将所有零散的背包合而为一，并提供强大的离线查看与搜索功能。

## 主要特性

- **单窗体整合**：将所有背包、银行、装备、邮箱等内容整合在一个简洁的窗口中。
- **离线查看**：支持随时随地查看同一账号下其他角色的背包、银行、邮件及装备信息。
- **跨版本支持**：兼容正式服 (Retail)、经典服 (Vanilla)、怀旧服 (TBC/Wrath/Mists) 等多个版本。
- **自定义风格**：内置 Blizzard 风格，并支持第三方皮肤扩展（如 Glass 系列）。
- **全局搜索**：内置强大的搜索功能，支持跨角色搜索物品。
- **物品高亮**：支持新物品、任务物品、品质等特殊高亮。
- **组件化设计**：包含金钱、代币、所有者切换、搜索框等模块。
- **插件扩展**：支持模块化插件（如 `ItemInfo` 用于显示装等和过期时间）。

## 项目结构分析

本项目采用模块化设计，结构清晰，便于维护和扩展：

- **[Core/](Core/)**：核心逻辑模块，处理事件监听、缓存管理、物品计数及配置选项。
- **[UI/](UI/)**：用户界面组件，采用 MVC 风格（Abstract/Component/Frame），支持高度自定义的样式设计。
- **[Cache/](Cache/)**：离线数据存储管理，支持跨角色和跨服务器的数据同步。
- **[Base/](Base/)**：底层工具类，包含协程管理 (`Thread.lua`) 和缓存优化 (`Cacher.lua`)。
- **[Libs/](Libs/)**：高度依赖 Ace3 框架及其他工具库（如 `ItemSearch`, `Unfit`）。
- **[Plugins/](Plugins/)**：可选的功能扩展包，如 `ItemInfo` 插件可增强物品槽显示效果。

## 安装与开发

### 安装
1. 下载最新发布的 [Release](https://github.com/DengSir/tdBag2/releases) 版本。
2. 解压至魔兽世界目录下的 `Interface\AddOns` 文件夹内。

### 开发
本项目使用 `wct` (WoW Custom Tool) 进行开发流程管理。
- **更新库**：`npm run update`
- **本地化处理**：`npm run locale`

## 推荐搭配
- **背包整理**：推荐配合使用 [tdPack2](https://www.curseforge.com/wow/addons/tdpack2) 获得最佳整理体验。
- **风格模板**：可尝试使用 [Glass](https://www.curseforge.com/wow/addons/tdbag2-glass) 皮肤包。

## 预览
![预览图](https://dengsir.github.io/images/tdBag2_1.jpg)

## 许可
[MIT License](LICENSE.md)

