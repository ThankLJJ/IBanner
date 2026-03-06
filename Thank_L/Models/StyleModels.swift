//
//  StyleModels.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI

// MARK: - 字体样式枚举
/// 横幅支持的字体样式类型
enum FontStyle: String, CaseIterable, Codable {
    case normal = "普通字体"
    case artistic = "艺术字"
    case neon = "霓虹字"

    var displayName: String {
        switch self {
        case .normal:
            return L10n.FontStyle.normal
        case .artistic:
            return L10n.FontStyle.artistic
        case .neon:
            return L10n.FontStyle.neon
        }
    }

    /// 字体样式描述
    var description: String {
        switch self {
        case .normal:
            return L10n.FontStyle.normalDesc
        case .artistic:
            return L10n.FontStyle.artisticDesc
        case .neon:
            return L10n.FontStyle.neonDesc
        }
    }

    /// 是否为高级字体（需要订阅）
    var isPremium: Bool {
        return self != .normal
    }
}

// MARK: - 艺术字风格枚举
/// 预设的艺术字风格
enum ArtisticStyle: String, CaseIterable, Codable {
    case none = "普通"

    // 材质类
    case metallic = "金属"
    case glass = "玻璃"
    case wood = "木纹"
    case stone = "石头"

    // 氛围类
    case fire = "火焰"
    case ice = "冰霜"
    case electric = "电流"
    case smoke = "烟雾"

    // 风格类
    case retro = "复古海报"
    case cyberpunk = "赛博朋克"
    case cartoon = "卡通"
    case handwritten = "手写"
    case calligraphy = "书法"

    // 自定义
    case custom = "自定义"

    var displayName: String {
        return self.rawValue
    }

    /// 风格描述
    var description: String {
        return displayName
    }

    /// 风格分类
    enum Category: String, CaseIterable {
        case material = "材质"
        case atmosphere = "氛围"
        case style = "风格"

        var displayName: String { self.rawValue }
    }

    /// 获取风格所属分类
    var category: Category? {
        switch self {
        case .none, .custom:
            return nil
        case .metallic, .glass, .wood, .stone:
            return .material
        case .fire, .ice, .electric, .smoke:
            return .atmosphere
        case .retro, .cyberpunk, .cartoon, .handwritten, .calligraphy:
            return .style
        }
    }

    /// 是否为高级风格（需要订阅）
    var isPremium: Bool {
        return self != .none
    }
}

// MARK: - 艺术字自定义参数配置
/// 艺术字的自定义参数配置
struct ArtisticStyleConfig: Codable {
    // === 基础层 ===
    var showStroke: Bool = false
    var strokeWidth: CGFloat = 0
    var strokeColor: Color = .black
    var letterSpacing: CGFloat = 0

    // === 阴影 ===
    var showShadow: Bool = false
    var shadowRadius: CGFloat = 0
    var shadowOpacity: Double = 0.5
    var shadowOffsetX: CGFloat = 0
    var shadowOffsetY: CGFloat = 0
    var shadowBlur: CGFloat = 0
    var shadowColor: Color = .black

    // === 材质 ===
    var showMaterial: Bool = false
    var materialIntensity: Double = 0.5

    // === 氛围 ===
    var showAtmosphere: Bool = false
    var atmosphereIntensity: Double = 0.5

    // === 进阶层 - 渐变与光泽 ===
    var gradientStartColor: Color = .white
    var gradientEndColor: Color = .white
    var gradientAngle: Double = 0
    var glossAngle: Double = 45

    // === 高阶层 - 特效 ===
    var embossDepth: CGFloat = 0
    var innerGlowRadius: CGFloat = 0
    var outerGlowRadius: CGFloat = 0
    var outerGlowColor: Color = .white

    // === 高阶层 - 纹理与高级 ===
    var noiseIntensity: CGFloat = 0
    var reflectionOpacity: CGFloat = 0
    var perspectiveAngle: Double = 0

    /// 默认配置
    static let `default` = ArtisticStyleConfig()
}

// MARK: - 霓虹字风格枚举
/// 预设的霓虹字风格（按效果类型分类）
enum NeonStyle: String, CaseIterable, Codable {
    // 基础类
    case basic = "基础发光"
    case soft = "柔和光晕"
    case sharp = "锐利光芒"

    // 动态类
    case pulse = "脉冲"
    case flicker = "闪烁"
    case breathing = "呼吸"

    // 特效类
    case glitch = "故障"
    case gradient = "渐变"
    case rainbow = "彩虹"

    // 高级类
    case cyberpunk = "赛博朋克"
    case retro = "复古霓虹"
    case custom = "自定义"

    var displayName: String {
        return self.rawValue
    }

    /// 风格描述
    var description: String {
        return displayName
    }

    /// 风格分类
    enum Category: String, CaseIterable {
        case basic = "基础"
        case dynamic = "动态"
        case effect = "特效"
        case advanced = "高级"

        var displayName: String { self.rawValue }
    }

    /// 获取风格所属分类
    var category: Category? {
        switch self {
        case .basic, .soft, .sharp:
            return .basic
        case .pulse, .flicker, .breathing:
            return .dynamic
        case .glitch, .gradient, .rainbow:
            return .effect
        case .cyberpunk, .retro, .custom:
            return .advanced
        }
    }

    /// 是否为高级风格（需要订阅）
    var isPremium: Bool {
        return self != .basic
    }
}

// MARK: - 霓虹字自定义参数配置
/// 霓虹字的完整配置参数
struct NeonStyleConfig: Codable {
    // === 基础层 ===
    var glowColor: Color = .cyan           // 主发光颜色
    var glowRadius: CGFloat = 10           // 发光半径 (0-50)
    var glowIntensity: Double = 1.0        // 发光强度 (0-2)

    // === 进阶层 - 多层发光 ===
    var secondaryGlowColor: Color? = nil   // 次级发光颜色
    var secondaryGlowRadius: CGFloat = 20  // 次级发光半径 (0-80)
    var enableMultipleLayers: Bool = false // 是否启用多层发光

    // === 动态效果 ===
    var pulseSpeed: Double = 1.0           // 脉冲速度 (0.5-3)
    var flickerFrequency: Double = 2.0     // 闪烁频率 (0.5-5)
    var breathingRange: Double = 0.3       // 呼吸范围 (0.1-0.5)

    // === 特效 ===
    var glitchIntensity: Double = 0        // 故障强度 (0-1)
    var gradientEndColor: Color? = nil     // 渐变结束色
    var rainbowSpeed: Double = 1.0         // 彩虹速度 (0.5-3)

    /// 默认配置
    static let `default` = NeonStyleConfig()
}
