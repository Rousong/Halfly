# 家庭记账本

## 项目概要

这是一个 SwiftUI iOS 家庭记账应用，用于记录日常支出并管理 AA 结清。

当前已实现的功能包括：

- 记录支出，区分 AA 支出和个人支出
- 查看支出列表，并支持删除记录
- 查看未结清 AA 支出的汇总情况
- 生成结清记录，并查看历史结清结果
- 使用本地 JSON 文件存储数据

## 启动方式

使用 Xcode 打开工程：

```bash
open HouseholdLedger.xcodeproj
```

也可以直接使用命令行构建：

```bash
xcodebuild -project HouseholdLedger.xcodeproj -scheme HouseholdLedger -configuration Debug -destination generic/platform=iOS -derivedDataPath /private/tmp/HouseholdLedgerDerivedData CODE_SIGNING_ALLOWED=NO build
```

## Codex 运行命令

在 Codex 里配置运行命令时，使用：

```bash
./scripts/run-ios-simulator.sh
```

这个脚本会自动打开 iOS Simulator，选择一个可用的 iPhone 模拟器，构建、安装并启动 App。需要指定固定模拟器时，可以先设置 `SIMULATOR_UDID` 环境变量。
