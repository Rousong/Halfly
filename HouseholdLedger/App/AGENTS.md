# App 目录

- 如果修改此目录里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-SUBDIRECTORY-RULES:START -->
<!-- 用户自定义的子目录规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-SUBDIRECTORY-RULES:END -->

## 代码简介

此目录存放应用入口和根视图组合代码，负责创建共享账本数据存储并组装底部 Tab 导航。

## 目录结构

```text
App/ # 应用入口、生命周期和根导航目录。
├── AGENTS.md # App 目录说明文档，记录目录规则、代码简介和结构。
├── HouseholdLedgerApp.swift # iOS App 入口，创建 LedgerStore 并注入根视图环境。
└── RootView.swift # 应用根视图，组装记录、列表、概览和结清四个 Tab。
```
