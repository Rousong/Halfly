# 家庭记账本

- 如果修改此项目里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-RULES:START -->
<!-- 用户自定义规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-RULES:END -->

## 代码简介

这是一个基于 SwiftUI 的 iOS 家庭记账应用。当前核心功能包括多账本创建与切换、按账本人数和性质初始化成员、支出录入、支出列表查看、双人账本 AA 支出结清计算、结清记录查询、基于 SwiftData 的本地持久化，以及应用图标资源配置。源码已按 App、Features、Core、Shared、Resources 分层组织。

## 目录结构

```text
家庭记账本/
├── .claude/ # 本地 AI 工具相关配置目录，不属于应用运行逻辑。
├── .playwright-mcp/ # 本地浏览器自动化工具目录，用于开发时辅助调试。
├── .gitignore # Git 忽略规则，避免提交本地环境文件和运行时产物。
├── AGENTS.md # 项目级说明文档，记录仓库规则、代码简介和目录结构。
├── HouseholdLedger.xcodeproj/ # Xcode 工程包，定义 iOS App target 和构建配置。
│   ├── AGENTS.md # 工程包说明文档，记录目录规则、代码简介和结构。
│   └── project.pbxproj # Xcode 工程配置，声明 App target、分组后的源码文件、资源文件和构建设置。
├── HouseholdLedger/ # SwiftUI 应用源码目录，按 App、Features、Core、Shared、Resources 分层组织。
│   ├── AGENTS.md # 源码目录说明文档，记录目录规则、代码简介和结构。
│   ├── App/ # 应用入口和根导航目录，负责 App 生命周期和 Tab 组合。
│   │   ├── AGENTS.md # App 目录说明文档，记录目录规则、代码简介和结构。
│   │   ├── HouseholdLedgerApp.swift # iOS App 入口，创建共享账本数据存储。
│   │   └── RootView.swift # 应用根视图，提供账本管理、新建账本入口，并组合账本、记录、列表、概览和结清五个 Tab。
│   ├── Core/ # 多账本业务模型和 SwiftData 持久化目录。
│   │   ├── AGENTS.md # Core 目录说明文档，记录目录规则、代码简介和结构。
│   │   ├── Models/ # 账本领域模型目录。
│   │   └── Persistence/ # SwiftData 持久化和账本状态管理目录。
│   ├── Features/ # 用户可见功能目录，按支出、概览和结清组织页面。
│   │   ├── AGENTS.md # Features 目录说明文档，记录目录规则、代码简介和结构。
│   │   ├── Expenses/ # 基于当前账本的支出录入和支出列表功能目录。
│   │   ├── Overview/ # 双人账本概览功能目录。
│   │   └── Settlements/ # 双人账本 AA 结清管理和结清记录功能目录。
│   ├── Resources/ # 应用静态资源目录，包含 App 图标资源集。
│   │   ├── AGENTS.md # Resources 目录说明文档，记录目录规则、代码简介和结构。
│   │   └── Assets.xcassets/ # 应用资源目录，包含 AppIcon 图标资源集。
│   └── Shared/ # 跨功能复用的 SwiftUI 组件和工具函数目录。
│       ├── AGENTS.md # Shared 目录说明文档，记录目录规则、代码简介和结构。
│       ├── UI/ # 支出行、汇总区块、指标行和结清提示等复用组件。
│       └── Utilities/ # 金额、日期和结清文案格式化函数。
├── README.md # 项目说明文档，提供 iOS 应用的启动和构建方式。
└── scripts/ # 本地开发脚本目录，用于一键运行项目。
    ├── AGENTS.md # 脚本目录说明文档，记录目录规则、代码简介和结构。
    └── run-ios-simulator.sh # 启动 iOS 模拟器、构建、安装并运行家庭记账本 App。
```
