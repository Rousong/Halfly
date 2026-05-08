# database

SQLite 数据库层，管理家庭记账数据。

- 如果修改该目录下的代码文件，请同步更新本文档。
- **功能**：数据库初始化、支出 CRUD、结清计算与记录。
- **数据文件**：`expenses.db`（SQLite 单文件，运行时自动创建）。

## 结构

```
database/
├── __init__.py    # 表结构定义 + 所有 CRUD / 结清逻辑
└── CLAUDE.md      # 目录级别的CLAUDE文档
```
