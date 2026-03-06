//
//  Enums.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI

// MARK: - 背景类型枚举
/// 横幅背景类型
enum BackgroundType: String, CaseIterable, Codable {
    case color = "纯色背景"
    case image = "图片背景"

    var displayName: String {
        switch self {
        case .color:
            return L10n.StyleSettings.colorBackground
        case .image:
            return L10n.StyleSettings.imageBackground
        }
    }
}

// MARK: - 滚动方向枚举
/// 滚动动画的方向
enum ScrollDirection: String, CaseIterable, Codable {
    case leftToRight = "从右向左"  // 文字从右向左移动（默认）
    case rightToLeft = "从左向右"  // 文字从左向右移动
    case topToBottom = "从下向上"  // 文字从下向上移动
    case bottomToTop = "从上向下"  // 文字从上向下移动

    var displayName: String {
        switch self {
        case .leftToRight:
            return L10n.ScrollDirection.leftToRight
        case .rightToLeft:
            return L10n.ScrollDirection.rightToLeft
        case .topToBottom:
            return L10n.ScrollDirection.topToBottom
        case .bottomToTop:
            return L10n.ScrollDirection.bottomToTop
        }
    }
}

// MARK: - 波浪方向枚举
enum WaveDirection: String, Codable {
    case horizontal = "水平"
    case vertical = "垂直"
}

// MARK: - 粒子运动模式枚举
enum ParticleMovement: String, Codable {
    case rise = "上升"
    case fall = "下降"
    case explode = "爆炸"
    case spiral = "螺旋"
}

// MARK: - 渐变混合模式枚举
enum GradientBlendMode: String, Codable {
    case normal = "正常"
    case overlay = "叠加"
    case multiply = "正片叠底"
}

// MARK: - 模板分类枚举
/// 模板分类枚举
enum TemplateCategory: String, CaseIterable, Codable {
    case all = "全部"
    case support = "应援"
    case party = "聚会"
    case transport = "接送"
    case celebration = "庆祝"
    case communication = "沟通"
    case custom = "自定义"

    var displayName: String {
        switch self {
        case .all:
            return L10n.TemplateCategory.all
        case .support:
            return L10n.TemplateCategory.support
        case .party:
            return L10n.TemplateCategory.party
        case .transport:
            return L10n.TemplateCategory.transport
        case .celebration:
            return L10n.TemplateCategory.celebration
        case .communication:
            return L10n.TemplateCategory.communication
        case .custom:
            return L10n.TemplateCategory.custom
        }
    }

    var icon: String {
        switch self {
        case .all:
            return "square.grid.2x2"
        case .support:
            return "heart.fill"
        case .party:
            return "party.popper.fill"
        case .transport:
            return "car.fill"
        case .celebration:
            return "gift.fill"
        case .communication:
            return "message.fill"
        case .custom:
            return "star.fill"
        }
    }
}

// MARK: - 颜色选择器类型
enum ColorPickerType {
    case text
    case background
}
