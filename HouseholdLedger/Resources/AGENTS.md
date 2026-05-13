# Resources 目录

- 如果修改此目录里面的代码文件，那么请同步更新此 MD 文档。

<!-- USER-SUBDIRECTORY-RULES:START -->
<!-- 用户自定义的子目录规则写在这里；如果这里除了本注释外没有任何内容，则忽略本区块。 -->
<!-- USER-SUBDIRECTORY-RULES:END -->

## 代码简介

此目录存放应用静态资源，目前包含 App 图标资源集。

## 目录结构

```text
Resources/ # 应用静态资源目录。
├── AGENTS.md # Resources 目录说明文档，记录目录规则、代码简介和结构。
└── Assets.xcassets/ # 应用资源目录，包含 AppIcon 图标资源集。
    ├── AppIcon.appiconset/ # iOS App 图标资源集，提供各设备所需尺寸。
    │   ├── AppIcon-1024.png # App Store 与图标源图尺寸。
    │   ├── AppIcon-20.png # iPad 20pt 图标的 1x 位图资源。
    │   ├── AppIcon-20@2x.png # 20pt 图标的 2x 位图资源。
    │   ├── AppIcon-20@3x.png # 20pt 图标的 3x 位图资源。
    │   ├── AppIcon-29.png # iPad 29pt 图标的 1x 位图资源。
    │   ├── AppIcon-29@2x.png # 29pt 图标的 2x 位图资源。
    │   ├── AppIcon-29@3x.png # 29pt 图标的 3x 位图资源。
    │   ├── AppIcon-40.png # iPad 40pt 图标的 1x 位图资源。
    │   ├── AppIcon-40@2x.png # 40pt 图标的 2x 位图资源。
    │   ├── AppIcon-40@3x.png # 40pt 图标的 3x 位图资源。
    │   ├── AppIcon-60@2x.png # 60pt 图标的 2x 位图资源。
    │   ├── AppIcon-60@3x.png # 60pt 图标的 3x 位图资源。
    │   ├── AppIcon-76.png # iPad 76pt 图标的 1x 位图资源。
    │   ├── AppIcon-76@2x.png # iPad 76pt 图标的 2x 位图资源。
    │   ├── AppIcon-83.5@2x.png # iPad Pro 83.5pt 图标的 2x 位图资源。
    │   └── Contents.json # AppIcon 资源集清单，声明各图标尺寸。
    └── Contents.json # Asset catalog 根清单。
```
