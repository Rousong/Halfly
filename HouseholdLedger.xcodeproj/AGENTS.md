# Xcode 工程包

- 如果修改此目录里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-SUBDIRECTORY-RULES:START -->
<!-- 用户自定义的子目录规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-SUBDIRECTORY-RULES:END -->

## 代码简介

此目录存放 Xcode 工程配置，用于构建家庭记账本 iOS App，并声明分层后的源码文件引用和构建设置。当前工程为绕开本机 `actool`/模拟器运行时问题，暂时未把 `Assets.xcassets` 加入 target 的资源编译阶段。

## 目录结构

```text
HouseholdLedger.xcodeproj/ # Xcode 工程包目录。
├── AGENTS.md # 工程包说明文档，记录目录规则、代码简介和结构。
└── project.pbxproj # Xcode 工程配置，声明 App target、App/Features/Core/Shared/Resources 分组、源码文件和当前构建设置。
```
