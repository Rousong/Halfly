# iOS 工程目录

- 如果修改此目录里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-SUBDIRECTORY-RULES:START -->
<!-- 用户自定义的子目录规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-SUBDIRECTORY-RULES:END -->

## 代码简介

此目录存放家庭记账本的 iOS 应用工程，使用 SwiftUI 实现支出录入、列表查看、AA 概览和结清管理。

## 目录结构

```text
ios/ # iOS 应用工程根目录。
├── AGENTS.md # iOS 目录说明文档，记录目录规则、代码简介和结构。
├── HouseholdLedger.xcodeproj/ # Xcode 工程包，定义 iOS App target 和构建配置。
└── HouseholdLedger/ # SwiftUI 应用源码目录，包含模型、数据存储和页面视图。
```
