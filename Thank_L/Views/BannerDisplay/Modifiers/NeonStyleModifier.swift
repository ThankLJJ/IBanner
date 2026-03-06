//
//  NeonStyleModifier.swift
//  Thank_L
//
//  霓虹字样式 - 包含12种风格实现
//

import SwiftUI

struct NeonStyleModifier: ViewModifier {
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig
    let textColor: Color

    func body(content: Content) -> some View {
        switch neonStyle {
        case .basic:
            basicNeon(content)

        case .soft:
            softNeon(content)

        case .sharp:
            sharpNeon(content)

        case .pulse:
            pulseNeon(content)

        case .flicker:
            flickerNeon(content)

        case .breathing:
            breathingNeon(content)

        case .glitch:
            glitchNeon(content)

        case .gradient:
            gradientNeon(content)

        case .rainbow:
            rainbowNeon(content)

        case .cyberpunk:
            cyberpunkNeon(content)

        case .retro:
            retroNeon(content)

        case .custom:
            customNeon(content)
        }
    }

    // MARK: - 基础霓虹
    @ViewBuilder
    private func basicNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.5), radius: CGFloat(neonConfig.glowRadius * 0.2), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.6 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.4), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.8 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.7), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

    // MARK: - 柔和霓虹
    @ViewBuilder
    private func softNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.3 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.4 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.3 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 1.5), x: 0, y: 0)
    }

    // MARK: - 锐利霓虹
    @ViewBuilder
    private func sharpNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.8 * neonConfig.glowIntensity), radius: 1, x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: 2, x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.6 * neonConfig.glowIntensity), radius: 4, x: 0, y: 0)
    }

    // MARK: - 脉冲霓虹
    @ViewBuilder
    private func pulseNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.3), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.6), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

    // MARK: - 闪烁霓虹
    @ViewBuilder
    private func flickerNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.6 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.9 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

    // MARK: - 呼吸霓虹
    @ViewBuilder
    private func breathingNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.4 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.4), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.8), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

    // MARK: - 故障效果
    @ViewBuilder
    private func glitchNeon(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.red.opacity(0.7))
                .offset(x: CGFloat(neonConfig.glitchIntensity * 3), y: 0)

            content
                .foregroundColor(.cyan.opacity(0.7))
                .offset(x: CGFloat(-neonConfig.glitchIntensity * 3), y: 0)

            basicNeon(content)
        }
    }

    // MARK: - 渐变霓虹
    @ViewBuilder
    private func gradientNeon(_ content: Content) -> some View {
        let endColor = neonConfig.gradientEndColor ?? neonConfig.glowColor.opacity(0.5)
        content
            .foregroundStyle(
                LinearGradient(
                    colors: [neonConfig.glowColor, endColor, neonConfig.glowColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: neonConfig.glowColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.8 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

    // MARK: - 彩虹霓虹
    @ViewBuilder
    private func rainbowNeon(_ content: Content) -> some View {
        content
            .foregroundStyle(
                LinearGradient(
                    colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: .white.opacity(0.3 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.3), x: 0, y: 0)
            .shadow(color: .purple.opacity(0.4 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.6), x: 0, y: 0)
            .shadow(color: .blue.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

    // MARK: - 赛博朋克霓虹
    @ViewBuilder
    private func cyberpunkNeon(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.purple.opacity(0.3))
                .shadow(color: .purple.opacity(0.8 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 1.5), x: 0, y: 0)

            content
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.6 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)

            content
                .foregroundColor(.pink)
                .shadow(color: .pink.opacity(0.4 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)
        }
    }

    // MARK: - 复古霓虹
    @ViewBuilder
    private func retroNeon(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.red.opacity(0.3))
                .offset(x: 2, y: 2)

            content
                .foregroundColor(.orange.opacity(0.6))
                .shadow(color: .orange.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)

            content
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.8 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
        }
    }

    // MARK: - 自定义霓虹
    @ViewBuilder
    private func customNeon(_ content: Content) -> some View {
        if let gradientEnd = neonConfig.gradientEndColor {
            content
                .foregroundStyle(
                    LinearGradient(
                        colors: [neonConfig.glowColor, gradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: neonConfig.glowColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.3), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.6), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.secondaryGlowRadius), x: 0, y: 0)
        } else if neonConfig.enableMultipleLayers, let secondaryColor = neonConfig.secondaryGlowColor {
            content
                .foregroundColor(neonConfig.glowColor)
                .shadow(color: neonConfig.glowColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.3), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.6), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
                .shadow(color: secondaryColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.secondaryGlowRadius * 0.5), x: 0, y: 0)
                .shadow(color: secondaryColor.opacity(0.3 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.secondaryGlowRadius), x: 0, y: 0)
        } else {
            content
                .foregroundColor(neonConfig.glowColor)
                .shadow(color: neonConfig.glowColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.3), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.6), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
        }
    }
}
