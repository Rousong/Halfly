# prototype-design

- 如果修改此目录里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-SUBDIRECTORY-RULES:START -->
<!-- 用户自定义的子目录规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-SUBDIRECTORY-RULES:END -->

## 代码简介

此目录存放家庭记账本的本地高保真 iOS UI 原型包。当前包含一个单文件 HTML/CSS/JavaScript 原型，用模拟数据展示首页、记录列表、支出详情、新建支出、创建账本和设置页面；创建账本流程支持选择账本人数，并为每位成员随机生成或手动设置形象。功能规格文档记录未来真实业务实现要求。

## 目录结构

```text
prototype-design/
├── AGENTS.md # 原型设计目录说明文档，记录目录规则、代码简介和结构。
├── FUNCTIONAL_SPEC.md # 原型对应的真实业务功能规格，描述页面、模块、交互、数据和状态要求。
└── ios-ui-prototype.html # 单文件高保真 iOS UI 原型，内联 HTML、CSS 和 JavaScript，使用模拟数据和本地交互。
```
