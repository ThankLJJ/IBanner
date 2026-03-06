//
//  BannerModels.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI
import Foundation

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

    // === 新增：霓虹字配置 ===
    /// 霓虹字风格
    var neonStyle: NeonStyle = .basic

    /// 霓虹字自定义参数
    var neonConfig: NeonStyleConfig = .default

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
