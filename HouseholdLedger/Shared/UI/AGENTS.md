# Shared/UI 目录

- 如果修改此目录里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-SUBDIRECTORY-RULES:START -->
<!-- 用户自定义的子目录规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-SUBDIRECTORY-RULES:END -->

## 代码简介

此目录存放支出行、汇总区块、指标行和结清提示等跨页面复用的 SwiftUI 组件，支持动态参与人名称展示。

## 目录结构

```text
UI/ # 跨功能复用 SwiftUI 组件目录。
├── AGENTS.md # UI 目录说明文档，记录目录规则、代码简介和结构。
├── ExpenseRow.swift # 支出记录行组件，展示类别、金额、日期、支付者、状态和备注。
├── MetricRow.swift # 指标行组件，用于展示标题、图标和金额文本。
├── SettlementMessage.swift # 结清提示组件，根据动态参与人和净转账金额展示转账关系。
└── SummarySection.swift # AA 汇总区块组件，展示总额和当前双人账本双方垫付金额。
```
