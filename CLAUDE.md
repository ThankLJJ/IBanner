# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Thank_L（iBanner）是一款iOS/iPadOS平台的LED横幅显示应用，支持多种动画效果和自定义样式。使用SwiftUI构建，支持iOS 14.0+。

## 常用命令

### 构建和运行
```bash
# 使用Xcode打开项目
open Thank_L.xcodeproj

# 使用xcodebuild命令行构建
xcodebuild -project Thank_L.xcodeproj -scheme Thank_L -destination 'platform=iOS Simulator,name=iPhone 15' build

# 运行测试
xcodebuild test -project Thank_L.xcodeproj -scheme Thank_L -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 项目架构

### 目录结构
```
Thank_L/
├── Thank_LApp.swift          # 应用入口
├── Models/
│   └── BannerModels.swift    # 核心数据模型
├── Views/
│   ├── ContentView.swift     # 主界面
│   ├── StyleSettingsView.swift    # 样式设置
│   ├── BannerDisplayView.swift    # 全屏展示页
│   ├── HistoryView.swift     # 历史记录页
│   ├── TemplateView.swift    # 模板选择页
│   ├── SubscriptionView.swift     # 订阅页
│   └── PremiumUpgradeSheet.swift  # 升级弹窗
├── Managers/
│   ├── BannerDataManager.swift    # 数据管理
│   └── SubscriptionManager.swift  # 订阅管理
├── Utils/
│   └── Localizable.swift     # 本地化封装(L10n枚举)
└── Resources/
    ├── Assets.xcassets       # 图片资源
    ├── Configuration.storekit # StoreKit配置
    ├── Thank_L.entitlements  # 应用权限
    └── *.lproj/              # 多语言文件
```

### 核心数据模型（BannerModels.swift）

- **BannerStyle**: 横幅样式配置（文字、颜色、动画、字体）
- **AnimationType**: 11种动画（none, scroll, blink, gradient, breathing, typewriter, randomFlash, wave, bounce, particles, led）
- **FontStyle**: 3种字体样式（normal, artistic, neon）
- **ArtisticStyle**: 14种艺术字风格
- **NeonStyle**: 12种霓虹字风格
- **BannerTemplate**: 预设模板（应援、聚会、接送、庆祝、沟通）
- **BannerHistory**: 历史记录

### 数据管理（BannerDataManager）

单例模式，使用UserDefaults持久化：
- 历史记录（最多10条）
- 自定义模板
- 收藏模板ID
- 背景图片（Documents/BackgroundImages/）

### 订阅系统（SubscriptionManager）

StoreKit 2实现：
- 终身解锁产品ID: `com.thankl.premium.lifetime`
- 高级功能权限检查方法

## 本地化

使用L10n枚举进行类型安全访问：
```swift
L10n.Animation.scroll
L10n.StyleSettings.fontSize
```

## 平台条件编译

```swift
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
```

## 开发注意事项

1. **新增动画**: 在AnimationType枚举添加，在BannerDisplayView实现逻辑
2. **新增字体样式**: 在FontStyle枚举添加，在BannerDisplayView.textView添加渲染
3. **新增模板**: 在BannerTemplate.getBuiltInTemplates()添加
4. **修改订阅**: 需同步更新Configuration.storekit
5. **本地化**: 在L10n枚举和.lproj/Localizable.strings中添加
