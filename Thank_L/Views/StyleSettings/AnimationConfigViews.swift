//
//  AnimationConfigViews.swift
//  Thank_L
//
//  动画配置视图组件 - 包含5种动画的配置UI
//

import SwiftUI

// MARK: - 动画配置区域路由
struct AnimationConfigSection: View {
    @Binding var bannerStyle: BannerStyle

    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.animationConfig)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            switch bannerStyle.animationType {
            case .blink:
                BlinkConfigView(config: $bannerStyle.blinkConfig)
            case .breathing:
                BreathingConfigView(config: $bannerStyle.breathingConfig)
            case .wave:
                WaveConfigView(config: $bannerStyle.waveConfig)
            case .bounce:
                BounceConfigView(config: $bannerStyle.bounceConfig)
            case .led:
                LEDConfigView(config: $bannerStyle.ledConfig)
            default:
                EmptyView()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .fill(Color.platformSystemGray6)
                #else
                .fill(Color.gray.opacity(0.1))
                #endif
        )
    }
}

// MARK: - 闪烁动画配置
struct BlinkConfigView: View {
    @Binding var config: BlinkConfig?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.blinkConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.minOpacity)
                    Spacer()
                    Text(String(format: "%.1f", config?.minOpacity ?? 0.3))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.minOpacity ?? 0.3 },
                    set: {
                        if config == nil { config = BlinkConfig() }
                        config?.minOpacity = $0
                    }
                ), in: 0...0.8, step: 0.1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.frequency)
                    Spacer()
                    Text(String(format: "%.1f", config?.frequency ?? 1.0))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.frequency ?? 1.0 },
                    set: {
                        if config == nil { config = BlinkConfig() }
                        config?.frequency = $0
                    }
                ), in: 0.5...3.0, step: 0.1)
            }
        }
    }
}

// MARK: - 呼吸动画配置
struct BreathingConfigView: View {
    @Binding var config: BreathingConfig?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.breathingConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.minScale)
                    Spacer()
                    Text(String(format: "%.1f", config?.minScale ?? 0.8))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.minScale ?? 0.8 },
                    set: {
                        if config == nil { config = BreathingConfig() }
                        config?.minScale = $0
                    }
                ), in: 0.5...1.0, step: 0.05)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.maxScale)
                    Spacer()
                    Text(String(format: "%.1f", config?.maxScale ?? 1.2))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.maxScale ?? 1.2 },
                    set: {
                        if config == nil { config = BreathingConfig() }
                        config?.maxScale = $0
                    }
                ), in: 1.0...1.5, step: 0.05)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.minOpacity)
                    Spacer()
                    Text(String(format: "%.1f", config?.minOpacity ?? 0.5))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.minOpacity ?? 0.5 },
                    set: {
                        if config == nil { config = BreathingConfig() }
                        config?.minOpacity = $0
                    }
                ), in: 0.2...0.9, step: 0.1)
            }
        }
    }
}

// MARK: - 波浪动画配置
struct WaveConfigView: View {
    @Binding var config: WaveConfig?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.waveConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.amplitude)
                    Spacer()
                    Text("\(Int(config?.amplitude ?? 15))")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { Double(config?.amplitude ?? 15) },
                    set: {
                        if config == nil { config = WaveConfig() }
                        config?.amplitude = $0
                    }
                ), in: 5...30, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.frequency)
                    Spacer()
                    Text(String(format: "%.1f", config?.frequency ?? 0.5))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.frequency ?? 0.5 },
                    set: {
                        if config == nil { config = WaveConfig() }
                        config?.frequency = $0
                    }
                ), in: 0.2...1.0, step: 0.1)
            }
        }
    }
}

// MARK: - 弹跳动画配置
struct BounceConfigView: View {
    @Binding var config: BounceConfig?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.bounceConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.bounceHeight)
                    Spacer()
                    Text("\(Int(config?.bounceHeight ?? 20))")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { Double(config?.bounceHeight ?? 20) },
                    set: {
                        if config == nil { config = BounceConfig() }
                        config?.bounceHeight = $0
                    }
                ), in: 5...50, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.elasticity)
                    Spacer()
                    Text(String(format: "%.2f", config?.elasticity ?? 0.3))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.elasticity ?? 0.3 },
                    set: {
                        if config == nil { config = BounceConfig() }
                        config?.elasticity = $0
                    }
                ), in: 0.1...0.8, step: 0.05)
            }
        }
    }
}

// MARK: - LED动画配置
struct LEDConfigView: View {
    @Binding var config: LEDConfig?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.ledConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.ledSize)
                    Spacer()
                    Text("\(Int(config?.dotSize ?? 3))")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { Double(config?.dotSize ?? 3) },
                    set: {
                        if config == nil { config = LEDConfig() }
                        config?.dotSize = CGFloat($0)
                    }
                ), in: 2...10, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.ledSpacing)
                    Spacer()
                    Text("\(Int(config?.dotSpacing ?? 6))")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { Double(config?.dotSpacing ?? 6) },
                    set: {
                        if config == nil { config = LEDConfig() }
                        config?.dotSpacing = CGFloat($0)
                    }
                ), in: 2...15, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.ledGlowIntensity)
                    Spacer()
                    Text(String(format: "%.1f", config?.glowIntensity ?? 0.5))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.glowIntensity ?? 0.5 },
                    set: {
                        if config == nil { config = LEDConfig() }
                        config?.glowIntensity = $0
                    }
                ), in: 0...1.0, step: 0.1)
            }
        }
    }
}
