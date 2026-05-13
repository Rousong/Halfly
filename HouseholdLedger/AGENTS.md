# HouseholdLedger 源码目录

- 如果修改此目录里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-SUBDIRECTORY-RULES:START -->
<!-- 用户自定义的子目录规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-SUBDIRECTORY-RULES:END -->

## 代码简介

此目录存放 iOS App 的 SwiftUI 源码和应用资源，按 App、Features、Core、Shared、Resources 分层组织。当前负责本地记账数据模型、JSON 持久化、支出录入、列表、概览、结清界面和 App 图标资源。

## 目录结构

```text
HouseholdLedger/ # SwiftUI 应用源码和资源目录。
├── AGENTS.md # 源码目录说明文档，记录目录规则、代码简介和结构。
├── App/ # 应用入口、生命周期和根导航目录。
│   ├── AGENTS.md # App 目录说明文档，记录目录规则、代码简介和结构。
│   ├── HouseholdLedgerApp.swift # iOS App 入口，创建 LedgerStore 并注入根视图环境。
│   └── RootView.swift # 应用根视图，组装记录、列表、概览和结清四个 Tab。
├── Core/ # 核心业务模型和基础设施目录。
│   ├── AGENTS.md # Core 目录说明文档，记录目录规则、代码简介和结构。
│   ├── Models/ # 账本领域模型目录。
│   │   ├── AGENTS.md # Models 目录说明文档，记录目录规则、代码简介和结构。
│   │   └── Models.swift # 支出、结清、支付者、筛选条件和汇总模型定义。
│   └── Persistence/ # 本地持久化和状态管理目录。
│       ├── AGENTS.md # Persistence 目录说明文档，记录目录规则、代码简介和结构。
│       └── LedgerStore.swift # 本地账本状态管理、JSON 持久化和结清计算逻辑。
├── Features/ # 用户可见业务功能目录。
│   ├── AGENTS.md # Features 目录说明文档，记录目录规则、代码简介和结构。
│   ├── Expenses/ # 支出录入和支出历史功能目录。
│   │   ├── AGENTS.md # Expenses 目录说明文档，记录目录规则、代码简介和结构。
│   │   └── Views/ # 支出功能页面目录。
│   │       ├── AGENTS.md # Views 目录说明文档，记录目录规则、代码简介和结构。
│   │       ├── AddExpenseView.swift # 支出录入页面，处理金额、日期、类别、支付者和备注输入。
│   │       └── ExpenseListView.swift # 支出列表页面，按筛选条件展示记录并支持删除。
│   ├── Overview/ # 账本概览功能目录。
│   │   ├── AGENTS.md # Overview 目录说明文档，记录目录规则、代码简介和结构。
│   │   └── Views/ # 概览功能页面目录。
│   │       ├── AGENTS.md # Views 目录说明文档，记录目录规则、代码简介和结构。
│   │       └── OverviewView.swift # 概览页面，展示 AA 汇总、结清状态、未结清支出和最近结清记录。
│   └── Settlements/ # AA 结清功能目录。
│       ├── AGENTS.md # Settlements 目录说明文档，记录目录规则、代码简介和结构。
│       └── Views/ # 结清功能页面和组件目录。
│           ├── AGENTS.md # Views 目录说明文档，记录目录规则、代码简介和结构。
│           ├── RecentSettlementsSection.swift # 结清记录列表组件，可展示最近或全部结清记录。
│           └── SettlementManagementView.swift # 结清管理页面，展示待结清支出并创建结清记录。
├── Resources/ # 应用静态资源目录。
│   ├── AGENTS.md # Resources 目录说明文档，记录目录规则、代码简介和结构。
│   └── Assets.xcassets/ # 应用资源目录，包含 AppIcon 图标资源集。
│       ├── AppIcon.appiconset/ # iOS App 图标资源集，提供各设备所需尺寸。
│       │   ├── AppIcon-1024.png # App Store 与图标源图尺寸。
│       │   ├── AppIcon-20.png # iPad 20pt 图标的 1x 位图资源。
│       │   ├── AppIcon-20@2x.png # 20pt 图标的 2x 位图资源。
│       │   ├── AppIcon-20@3x.png # 20pt 图标的 3x 位图资源。
│       │   ├── AppIcon-29.png # iPad 29pt 图标的 1x 位图资源。
│       │   ├── AppIcon-29@2x.png # 29pt 图标的 2x 位图资源。
│       │   ├── AppIcon-29@3x.png # 29pt 图标的 3x 位图资源。
│       │   ├── AppIcon-40.png # iPad 40pt 图标的 1x 位图资源。
│       │   ├── AppIcon-40@2x.png # 40pt 图标的 2x 位图资源。
│       │   ├── AppIcon-40@3x.png # 40pt 图标的 3x 位图资源。
│       │   ├── AppIcon-60@2x.png # 60pt 图标的 2x 位图资源。
│       │   ├── AppIcon-60@3x.png # 60pt 图标的 3x 位图资源。
│       │   ├── AppIcon-76.png # iPad 76pt 图标的 1x 位图资源。
│       │   ├── AppIcon-76@2x.png # iPad 76pt 图标的 2x 位图资源。
│       │   ├── AppIcon-83.5@2x.png # iPad Pro 83.5pt 图标的 2x 位图资源。
│       │   └── Contents.json # AppIcon 资源集清单，声明各图标尺寸。
│       └── Contents.json # Asset catalog 根清单。
└── Shared/ # 跨功能复用代码目录。
    ├── AGENTS.md # Shared 目录说明文档，记录目录规则、代码简介和结构。
    ├── UI/ # 跨功能复用 SwiftUI 组件目录。
    │   ├── AGENTS.md # UI 目录说明文档，记录目录规则、代码简介和结构。
    │   ├── ExpenseRow.swift # 支出记录行组件，展示类别、金额、日期、支付者、状态和备注。
    │   ├── MetricRow.swift # 指标行组件，用于展示标题、图标和金额文本。
    │   ├── SettlementMessage.swift # 结清提示组件，根据净转账金额展示双方转账关系。
    │   └── SummarySection.swift # AA 汇总区块组件，展示总额和双方垫付金额。
    └── Utilities/ # 通用工具函数目录。
        ├── AGENTS.md # Utilities 目录说明文档，记录目录规则、代码简介和结构。
        └── LedgerFormatters.swift # 金额、日期和结清转账文案格式化函数。
```
