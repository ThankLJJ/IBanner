//
//  AnimationModels.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI

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
struct WaveAnimationConfig: Codable {
    var amplitude: Double = 15
    var frequency: Double = 0.5
    var waveDirection: WaveDirection = .horizontal

    static let `default` = WaveAnimationConfig()
}

// MARK: - 粒子动效配置
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

// MARK: - 简短类型别名（用于UI组件）
typealias BlinkConfig = BlinkAnimationConfig
typealias BreathingConfig = BreathingAnimationConfig
typealias WaveConfig = WaveAnimationConfig
typealias BounceConfig = BounceAnimationConfig
typealias LEDConfig = LedAnimationConfig
