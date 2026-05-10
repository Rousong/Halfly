# 家庭记账本

## 项目概要

这是一个基于 Streamlit 的家庭记账小应用，用于记录日常支出并管理 AA 结清。

当前已实现的功能包括：

- 记录支出，区分 AA 支出和个人支出
- 查看支出列表，并支持删除记录
- 查看未结清 AA 支出的汇总情况
- 生成结清记录，并查看历史结清结果
- 使用本地 SQLite 数据库存储数据

## 启动方式

本项目当前使用仓库内已有的 `.venv` 虚拟环境启动。

1. 进入项目目录

```bash
cd /Users/yzk/MyProjects/家庭记账本
```

2. 启动 Streamlit 应用

```bash
.venv/bin/streamlit run app.py
```

3. 在浏览器中打开本地地址

```text
http://localhost:8501
```

如果你更习惯使用 `uv`，也可以使用：

```bash
uv run streamlit run app.py
```
