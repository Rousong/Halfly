# 家庭记账本

- 如果修改此项目里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-RULES:START -->
<!-- 用户自定义规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-RULES:END -->

## 代码简介

这是一个基于 SwiftUI 的 iOS 家庭记账应用。当前核心功能包括支出录入、支出列表查看、AA 支出结清计算、结清记录查询，以及本地 JSON 持久化。

## 目录结构

```text
家庭记账本/
├── .claude/ # 本地 AI 工具相关配置目录，不属于应用运行逻辑。
├── .playwright-mcp/ # 本地浏览器自动化工具目录，用于开发时辅助调试。
├── .gitignore # Git 忽略规则，避免提交本地环境文件和运行时产物。
├── AGENTS.md # 项目级说明文档，记录仓库规则、代码简介和目录结构。
├── HouseholdLedger.xcodeproj/ # Xcode 工程包，定义 iOS App target 和构建配置。
│   ├── AGENTS.md # 工程包说明文档，记录目录规则、代码简介和结构。
│   └── project.pbxproj # Xcode 工程配置，声明 App target、源码文件和构建设置。
├── HouseholdLedger/ # SwiftUI 应用源码目录，包含模型、数据存储和页面视图。
│   ├── AGENTS.md # 源码目录说明文档，记录目录规则、代码简介和结构。
│   ├── ContentView.swift # 应用主界面，包含四个 Tab 页面和各业务视图。
│   ├── HouseholdLedgerApp.swift # iOS App 入口，创建共享账本数据存储。
│   ├── LedgerStore.swift # 本地账本状态管理、JSON 持久化和结清计算逻辑。
│   └── Models.swift # 支出、结清、支付者和筛选条件等核心数据模型。
├── README.md # 项目说明文档，提供 iOS 应用的启动和构建方式。
```
