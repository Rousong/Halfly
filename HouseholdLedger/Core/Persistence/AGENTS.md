# Core/Persistence 目录

- 如果修改此目录里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-SUBDIRECTORY-RULES:START -->
<!-- 用户自定义的子目录规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-SUBDIRECTORY-RULES:END -->

## 代码简介

此目录存放多账本状态管理、当前账本切换和 SwiftData 持久化逻辑。

## 目录结构

```text
Persistence/ # SwiftData 持久化和状态管理目录。
├── AGENTS.md # Persistence 目录说明文档，记录目录规则、代码简介和结构。
└── LedgerStore.swift # LedgerStore 状态对象，负责创建与切换账本、增删支出、双人结清和保存 SwiftData 数据。
```
