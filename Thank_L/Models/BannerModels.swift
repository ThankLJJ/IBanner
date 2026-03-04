//
//  BannerModels.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI
import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

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

// MARK: - 动效类型枚举
/// 横幅支持的动画效果类型
enum AnimationType: String, CaseIterable, Codable {
    case none = "无动效"
    case scroll = "滚动"
    case blink = "闪烁"
    case gradient = "渐变"
    case breathing = "呼吸灯"
    case typewriter = "逐字显示"
    case randomFlash = "随机闪现"
    case wave = "波浪"           // 新增：波浪效果
    case bounce = "弹跳"         // 新增：弹跳效果
    case particles = "粒子"       // 新增：粒子特效
    case led = "LED像素"         // 新增：LED像素化效果

    var displayName: String {
        switch self {
        case .none:
            return L10n.Animation.none
        case .scroll:
            return L10n.Animation.scroll
        case .blink:
            return L10n.Animation.blink
        case .gradient:
            return L10n.Animation.gradient
        case .breathing:
            return L10n.Animation.breathing
        case .typewriter:
            return L10n.Animation.typewriter
        case .randomFlash:
            return L10n.Animation.randomFlash
        case .wave:
            return L10n.Animation.wave
        case .bounce:
            return L10n.Animation.bounce
        case .particles:
            return L10n.Animation.particles
        case .led:
            return L10n.Animation.led
        }
    }

    /// 动效描述
    var description: String {
        switch self {
        case .none:
            return L10n.Animation.noneDesc
        case .scroll:
            return L10n.Animation.scrollDesc
        case .blink:
            return L10n.Animation.blinkDesc
        case .gradient:
            return L10n.Animation.gradientDesc
        case .breathing:
            return L10n.Animation.breathingDesc
        case .typewriter:
            return L10n.Animation.typewriterDesc
        case .randomFlash:
            return L10n.Animation.randomFlashDesc
        case .wave:
            return L10n.Animation.waveDesc
        case .bounce:
            return L10n.Animation.bounceDesc
        case .particles:
            return L10n.Animation.particlesDesc
        case .led:
            return L10n.Animation.ledDesc
        }
    }

    /// 是否为高级动效（需要订阅）
    var isPremium: Bool {
        switch self {
        case .none, .scroll, .blink, .breathing:
            return false
        case .gradient, .typewriter, .randomFlash, .wave, .bounce, .particles, .led:
            return true
        }
    }
}

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
    var strokeWidth: CGFloat = 0
    var strokeColor: Color = .black
    var letterSpacing: CGFloat = 0

    // === 阴影 ===
    var shadowOffsetX: CGFloat = 0
    var shadowOffsetY: CGFloat = 0
    var shadowBlur: CGFloat = 0
    var shadowColor: Color = .black

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

// MARK: - 滚动动效配置
struct ScrollAnimationConfig: Codable {
    var direction: ScrollDirection = .leftToRight
    var startPosition: Double = 0
    var pauseAtCenter: Bool = false

    static let `default` = ScrollAnimationConfig()
}

// MARK: - 闪烁动效配置
struct BlinkAnimationConfig: Codable {
    var frequency: Double = 1.0
    var minOpacity: Double = 0.3
    var maxOpacity: Double = 1.0

    static let `default` = BlinkAnimationConfig()
}

// MARK: - 呼吸灯动效配置
struct BreathingAnimationConfig: Codable {
    var minScale: Double = 0.8
    var maxScale: Double = 1.2
    var minOpacity: Double = 0.5

    static let `default` = BreathingAnimationConfig()
}

// MARK: - 波浪动效配置
enum WaveDirection: String, Codable {
    case horizontal = "水平"
    case vertical = "垂直"
}

struct WaveAnimationConfig: Codable {
    var amplitude: Double = 15
    var frequency: Double = 0.5
    var waveDirection: WaveDirection = .horizontal

    static let `default` = WaveAnimationConfig()
}

// MARK: - 粒子动效配置
enum ParticleMovement: String, Codable {
    case rise = "上升"
    case fall = "下降"
    case explode = "爆炸"
    case spiral = "螺旋"
}

struct ParticlesAnimationConfig: Codable {
    var particleCount: Int = 30
    var particleSizeMin: CGFloat = 2
    var particleSizeMax: CGFloat = 6
    var particleColors: [Color] = [.white, .yellow]
    var movementPattern: ParticleMovement = .rise

    static let `default` = ParticlesAnimationConfig()
}

// MARK: - 弹跳动效配置
struct BounceAnimationConfig: Codable {
    var bounceHeight: Double = 20
    var elasticity: Double = 0.3
    var squashAmount: Double = 0.2

    static let `default` = BounceAnimationConfig()
}

// MARK: - 渐变动效配置
enum GradientBlendMode: String, Codable {
    case normal = "正常"
    case overlay = "叠加"
    case multiply = "正片叠底"
}

struct GradientAnimationConfig: Codable {
    var gradientColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    var cycleDuration: Double = 3.0
    var blendMode: GradientBlendMode = .normal

    static let `default` = GradientAnimationConfig()
}

// MARK: - 逐字显示动效配置
struct TypewriterAnimationConfig: Codable {
    var charDelay: Double = 0.1
    var pauseAfterComplete: Double = 2.0
    var cursorEnabled: Bool = false

    static let `default` = TypewriterAnimationConfig()
}

// MARK: - 随机闪现动效配置
struct RandomFlashAnimationConfig: Codable {
    var flashCount: Int = 5
    var fadeInDuration: Double = 0.5
    var fadeOutDuration: Double = 0.3
    var randomPosition: Bool = true

    static let `default` = RandomFlashAnimationConfig()
}

// MARK: - LED像素动效配置
struct LedAnimationConfig: Codable {
    var dotSpacing: CGFloat = 6
    var dotSize: CGFloat = 3
    var glowIntensity: Double = 0.5
    var flickerEnabled: Bool = true

    static let `default` = LedAnimationConfig()
}

// MARK: - 横幅样式配置
/// 横幅的样式配置信息
struct BannerStyle: Codable {
    /// 文字内容
    var text: String = ""

    /// 字体大小
    var fontSize: CGFloat = 48.0

    /// 文字颜色
    var textColor: Color = .white

    /// 背景颜色
    var backgroundColor: Color = .black

    /// 背景类型
    var backgroundType: BackgroundType = .color

    /// 背景图片路径（相对于Documents目录）
    var backgroundImagePath: String? = nil

    /// 背景图片透明度 (0.0-1.0)
    var backgroundImageOpacity: Double = 1.0

    /// 动画类型
    var animationType: AnimationType = .none

    /// 滚动方向（仅滚动动画有效）
    var scrollDirection: ScrollDirection = .leftToRight

    /// 动画速度 (1.0为正常速度)
    var animationSpeed: Double = 1.0

    /// 是否粗体
    var isBold: Bool = false

    /// 字体样式
    var fontStyle: FontStyle = .normal

    // === 新增：艺术字配置 ===
    /// 艺术字风格
    var artisticStyle: ArtisticStyle = .none

    /// 艺术字自定义参数
    var artisticConfig: ArtisticStyleConfig = .default

    // === 新增：动效专属配置 ===
    var scrollConfig: ScrollAnimationConfig?
    var blinkConfig: BlinkAnimationConfig?
    var breathingConfig: BreathingAnimationConfig?
    var waveConfig: WaveAnimationConfig?
    var particlesConfig: ParticlesAnimationConfig?
    var bounceConfig: BounceAnimationConfig?
    var gradientConfig: GradientAnimationConfig?
    var typewriterConfig: TypewriterAnimationConfig?
    var randomFlashConfig: RandomFlashAnimationConfig?
    var ledConfig: LedAnimationConfig?

    /// 创建时间
    var createdAt: Date = Date()

    /// 自定义初始化
    init(text: String = "", fontSize: CGFloat = 48.0, textColor: Color = .white, backgroundColor: Color = .black, backgroundType: BackgroundType = .color, backgroundImagePath: String? = nil, backgroundImageOpacity: Double = 1.0, animationType: AnimationType = .none, scrollDirection: ScrollDirection = .leftToRight, animationSpeed: Double = 1.0, isBold: Bool = false, fontStyle: FontStyle = .normal, artisticStyle: ArtisticStyle = .none, artisticConfig: ArtisticStyleConfig = .default) {
        self.text = text
        self.fontSize = fontSize
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.backgroundType = backgroundType
        self.backgroundImagePath = backgroundImagePath
        self.backgroundImageOpacity = backgroundImageOpacity
        self.animationType = animationType
        self.scrollDirection = scrollDirection
        self.animationSpeed = animationSpeed
        self.isBold = isBold
        self.fontStyle = fontStyle
        self.artisticStyle = artisticStyle
        self.artisticConfig = artisticConfig
        self.createdAt = Date()
    }
}

// MARK: - Color扩展支持Codable
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        #if os(iOS)
        let uiColor = UIColor(self)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif os(macOS)
        let nsColor = NSColor(self)
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        
        try container.encode(Double(red), forKey: .red)
        try container.encode(Double(green), forKey: .green)
        try container.encode(Double(blue), forKey: .blue)
        try container.encode(Double(alpha), forKey: .alpha)
    }
}

// MARK: - 跨平台系统颜色
extension Color {
    /// 跨平台系统背景颜色
    static var platformBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }

    /// 跨平台二级系统背景颜色
    static var platformSecondaryBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }

    /// 跨平台三级系统背景颜色
    static var platformTertiaryBackground: Color {
        #if os(iOS)
        return Color(UIColor.tertiarySystemBackground)
        #else
        return Color(NSColor.controlBackgroundColor).opacity(0.5)
        #endif
    }

    /// 跨平台系统灰色6
    static var platformSystemGray6: Color {
        #if os(iOS)
        return Color(UIColor.systemGray6)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
}

// MARK: - 横幅模板
/// 预设的横幅模板
struct BannerTemplate: Codable, Identifiable {
    let id = UUID()
    var name: String
    var text: String
    var style: BannerStyle
    var category: TemplateCategory
    var isBuiltIn: Bool = true
    
    init(name: String, text: String, style: BannerStyle, category: TemplateCategory, isBuiltIn: Bool = true) {
        self.name = name
        self.text = text
        self.style = style
        self.category = category
        self.isBuiltIn = isBuiltIn
    }
}

// MARK: - 模板分类
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

// MARK: - 横幅历史记录
/// 用户使用横幅的历史记录
struct BannerHistory: Codable, Identifiable {
    let id = UUID()
    var text: String
    var style: BannerStyle
    var timestamp: Date
    
    init(text: String, style: BannerStyle, timestamp: Date = Date()) {
        self.text = text
        self.style = style
        self.timestamp = timestamp
    }
}

// MARK: - 预设模板数据
extension BannerTemplate {
    /// 内置模板列表
    static var builtInTemplates: [BannerTemplate] {
        return getBuiltInTemplates()
    }
    
    /// 获取内置模板列表
    static func getBuiltInTemplates() -> [BannerTemplate] {
        return [
            // 应援类模板
            BannerTemplate(
                name: "演唱会应援",
                text: "❤️ 我爱你 ❤️",
                style: BannerStyle(
                    text: "❤️ 我爱你 ❤️",
                    fontSize: 56,
                    textColor: .white,
                    backgroundColor: .red,
                    animationType: .blink,
                    animationSpeed: 1.5,
                    isBold: true
                ),
                category: .support
            ),
            BannerTemplate(
                name: "粉丝应援",
                text: "🌟 加油加油 🌟",
                style: BannerStyle(
                    text: "🌟 加油加油 🌟",
                    fontSize: 48,
                    textColor: .yellow,
                    backgroundColor: .purple,
                    animationType: .breathing,
                    animationSpeed: 1.0,
                    isBold: true
                ),
                category: .support
            ),
            
            // 聚会类模板
            BannerTemplate(
                name: "生日快乐",
                text: "🎂 生日快乐 🎂",
                style: BannerStyle(
                    text: "🎂 生日快乐 🎂",
                    fontSize: 52,
                    textColor: .white,
                    backgroundColor: .pink,
                    animationType: .gradient,
                    animationSpeed: 1.2,
                    isBold: true
                ),
                category: .celebration
            ),
            BannerTemplate(
                name: "派对时间",
                text: "🎉 Party Time 🎉",
                style: BannerStyle(
                    text: "🎉 Party Time 🎉",
                    fontSize: 50,
                    textColor: .white,
                    backgroundColor: .orange,
                    animationType: .scroll,
                    animationSpeed: 1.0,
                    isBold: true
                ),
                category: .party
            ),
            
            // 接送类模板
            BannerTemplate(
                name: "接机牌",
                text: "✈️ 接机 ✈️",
                style: BannerStyle(
                    text: "✈️ 接机 ✈️",
                    fontSize: 60,
                    textColor: .black,
                    backgroundColor: .white,
                    animationType: .none,
                    animationSpeed: 1.0,
                    isBold: true
                ),
                category: .transport
            ),
            BannerTemplate(
                name: "代驾服务",
                text: "🚗 代驾 🚗",
                style: BannerStyle(
                    text: "🚗 代驾 🚗",
                    fontSize: 54,
                    textColor: .white,
                    backgroundColor: .blue,
                    animationType: .breathing,
                    animationSpeed: 0.8,
                    isBold: true
                ),
                category: .transport
            ),
            
            // 沟通类模板
            BannerTemplate(
                name: "谢谢",
                text: "🙏 谢谢 🙏",
                style: BannerStyle(
                    text: "🙏 谢谢 🙏",
                    fontSize: 58,
                    textColor: .white,
                    backgroundColor: .green,
                    animationType: .none,
                    animationSpeed: 1.0,
                    isBold: true
                ),
                category: .communication
            ),
            BannerTemplate(
                name: "请稍等",
                text: "⏰ 请稍等 ⏰",
                style: BannerStyle(
                    text: "⏰ 请稍等 ⏰",
                    fontSize: 50,
                    textColor: .black,
                    backgroundColor: .yellow,
                    animationType: .blink,
                    animationSpeed: 1.0,
                    isBold: true
                ),
                category: .communication
            )
        ]
    }
}

// MARK: - 订阅相关模型
/// 订阅产品信息
struct SubscriptionProduct: Codable, Identifiable {
    var id: String { productID } // 使用productID作为唯一标识符
    var productID: String
    var displayName: String
    var description: String
    var price: String
    var duration: SubscriptionDuration
    var features: [String]
    
    init(productID: String, displayName: String, description: String, price: String, duration: SubscriptionDuration, features: [String]) {
        self.productID = productID
        self.displayName = displayName
        self.description = description
        self.price = price
        self.duration = duration
        self.features = features
    }
}

/// 订阅时长枚举
enum SubscriptionDuration: String, CaseIterable, Codable {
    case lifetime = "终身解锁"

    var displayName: String {
        return L10n.Subscription.lifetime
    }

    var description: String {
        switch self {
        case .lifetime:
            return L10n.Subscription.lifetimeDesc
        }
    }
}

/// 高级功能枚举
enum PremiumFeature: String, CaseIterable, Codable {
    case unlimitedPreview = "无限预览"
    case advancedAnimations = "高级动效"
    case customFonts = "自定义字体"
    case backgroundImages = "背景图片"
    case exportFeatures = "导出功能"

    var displayName: String {
        switch self {
        case .unlimitedPreview:
            return L10n.PremiumFeature.unlimitedPreview
        case .advancedAnimations:
            return L10n.PremiumFeature.advancedAnimations
        case .customFonts:
            return L10n.PremiumFeature.customFonts
        case .backgroundImages:
            return L10n.PremiumFeature.backgroundImages
        case .exportFeatures:
            return L10n.PremiumFeature.exportFeatures
        }
    }

    var description: String {
        switch self {
        case .unlimitedPreview:
            return L10n.PremiumFeature.unlimitedPreview
        case .advancedAnimations:
            return L10n.PremiumFeature.advancedAnimations
        case .customFonts:
            return L10n.PremiumFeature.customFonts
        case .backgroundImages:
            return L10n.PremiumFeature.backgroundImages
        case .exportFeatures:
            return L10n.PremiumFeature.exportFeatures
        }
    }

    var icon: String {
        switch self {
        case .unlimitedPreview:
            return "eye.fill"
        case .advancedAnimations:
            return "sparkles"
        case .customFonts:
            return "textformat"
        case .backgroundImages:
            return "photo.fill"
        case .exportFeatures:
            return "square.and.arrow.up.fill"
        }
    }
}

/// 订阅配置
struct SubscriptionConfig {
    static let lifetimeProductID = "com.thankl.premium.lifetime"
    
    static let lifetimePrice = "¥1.00"

    static let premiumFeatures: [PremiumFeature] = [
        .unlimitedPreview,
        .advancedAnimations,
        .customFonts,
        .backgroundImages,
        .exportFeatures
    ]
    
    static func getSubscriptionProducts() -> [SubscriptionProduct] {
        return [
            SubscriptionProduct(
                productID: lifetimeProductID,
                displayName: "高级版 - 终身解锁",
                description: "一次购买，解锁所有高级功能，终身使用",
                price: lifetimePrice,
                duration: .lifetime,
                features: premiumFeatures.map { $0.displayName }
            )
        ]
    }
}
