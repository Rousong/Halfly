# HouseholdLedger 源码目录

- 如果修改此目录里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-SUBDIRECTORY-RULES:START -->
<!-- 用户自定义的子目录规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-SUBDIRECTORY-RULES:END -->

## 代码简介

此目录存放 iOS App 的 SwiftUI 源码，负责本地记账数据模型、JSON 持久化、支出录入、列表、概览和结清界面。

## 目录结构

```text
HouseholdLedger/ # SwiftUI 应用源码目录。
├── AGENTS.md # 源码目录说明文档，记录目录规则、代码简介和结构。
├── ContentView.swift # 应用主界面，包含四个 Tab 页面和各业务视图。
├── HouseholdLedgerApp.swift # iOS App 入口，创建共享账本数据存储。
├── LedgerStore.swift # 本地账本状态管理、JSON 持久化和结清计算逻辑。
└── Models.swift # 支出、结清、支付者和筛选条件等核心数据模型。
```
