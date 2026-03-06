//
//  BannerStyleModifiers.swift
//  Thank_L
//
//  Created by L on 2024/7/13.
//

import SwiftUI

struct FontStyleModifier: ViewModifier {
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig
    let textColor: Color

    func body(content: Content) -> some View {
        switch fontStyle {
        case .normal:
            content

        case .artistic:
            content
                .modifier(ArtisticStyleModifier(
                    artisticStyle: artisticStyle,
                    artisticConfig: artisticConfig,
                    textColor: textColor
                ))

        case .neon:
            content
                .modifier(NeonStyleModifier(
                    neonStyle: neonStyle,
                    neonConfig: neonConfig,
                    textColor: textColor
                ))
        }
    }
}

struct ArtisticStyleModifier: ViewModifier {
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let textColor: Color

    func body(content: Content) -> some View {
        switch artisticStyle {
        case .none:
            content

        case .metallic:
            metallicStyle(content)

        case .glass:
            glassStyle(content)

        case .wood:
            woodStyle(content)

        case .stone:
            stoneStyle(content)

        case .fire:
            fireStyle(content)

        case .ice:
            iceStyle(content)

        case .electric:
            electricStyle(content)

        case .smoke:
            smokeStyle(content)

        case .retro:
            retroStyle(content)

        case .cyberpunk:
            cyberpunkStyle(content)

        case .cartoon:
            cartoonStyle(content)

        case .handwritten:
            handwrittenStyle(content)

        case .calligraphy:
            calligraphyStyle(content)

        case .custom:
            customStyle(content)
        }
    }

    @ViewBuilder
    private func metallicStyle(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.black.opacity(0.3))
                .offset(x: 2, y: 2)
            content
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .gray.opacity(0.3),
                            .white,
                            textColor,
                            .white,
                            .gray.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .white.opacity(0.5), radius: 1, x: -1, y: -1)
        }
    }

    @ViewBuilder
    private func glassStyle(_ content: Content) -> some View {
        content
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        .white.opacity(0.9),
                        textColor.opacity(0.6),
                        .white.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: -1)
            .shadow(color: textColor.opacity(0.3), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private func woodStyle(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.brown.opacity(0.5))
                .offset(x: 1, y: 1)
            content
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.2),
                            Color(red: 0.8, green: 0.5, blue: 0.2),
                            Color(red: 0.5, green: 0.3, blue: 0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }

    @ViewBuilder
    private func stoneStyle(_ content: Content) -> some View {
        content
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        .gray,
                        textColor,
                        .gray.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
    }

    @ViewBuilder
    private func fireStyle(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.orange.opacity(0.5))
                .blur(radius: 4)
            content
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .yellow,
                            .orange,
                            .red,
                            .orange
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .shadow(color: .orange.opacity(0.8), radius: 8, x: 0, y: 0)
                .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 0)
        }
    }

    @ViewBuilder
    private func iceStyle(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.cyan.opacity(0.3))
                .blur(radius: 3)
            content
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white,
                            .cyan,
                            Color(red: 0.5, green: 0.8, blue: 1.0),
                            .white
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.6), radius: 5, x: 0, y: 0)
        }
    }

    @ViewBuilder
    private func electricStyle(_ content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .shadow(color: .cyan, radius: 2, x: 0, y: 0)
            .shadow(color: .blue.opacity(0.8), radius: 5, x: 0, y: 0)
            .shadow(color: .purple.opacity(0.6), radius: 10, x: 0, y: 0)
            .shadow(color: .cyan, radius: 15, x: 0, y: 0)
    }

    @ViewBuilder
    private func smokeStyle(_ content: Content) -> some View {
        content
            .foregroundColor(textColor.opacity(0.8))
            .blur(radius: 0.5)
            .shadow(color: textColor.opacity(0.3), radius: 8, x: 0, y: 0)
            .shadow(color: .gray.opacity(0.2), radius: 15, x: 0, y: 0)
    }

    @ViewBuilder
    private func retroStyle(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.brown.opacity(0.4))
                .offset(x: 3, y: 3)
            content
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.9, green: 0.7, blue: 0.3),
                            Color(red: 0.8, green: 0.5, blue: 0.2),
                            Color(red: 0.6, green: 0.3, blue: 0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    @ViewBuilder
    private func cyberpunkStyle(_ content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .shadow(color: .cyan, radius: 1, x: -2, y: 0)
            .shadow(color: Color(red: 1, green: 0, blue: 1), radius: 1, x: 2, y: 0)
            .shadow(color: .cyan.opacity(0.8), radius: 5, x: 0, y: 0)
            .shadow(color: Color(red: 1, green: 0, blue: 1).opacity(0.6), radius: 10, x: 0, y: 0)
    }

    @ViewBuilder
    private func cartoonStyle(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.black)
                .offset(x: -2, y: 0)
            content
                .foregroundColor(.black)
                .offset(x: 2, y: 0)
            content
                .foregroundColor(.black)
                .offset(x: 0, y: -2)
            content
                .foregroundColor(.black)
                .offset(x: 0, y: 2)
            content
                .foregroundColor(textColor)
        }
    }

    @ViewBuilder
    private func handwrittenStyle(_ content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .italic()
            .shadow(color: textColor.opacity(0.2), radius: 1, x: 1, y: 1)
    }

    @ViewBuilder
    private func calligraphyStyle(_ content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.black.opacity(0.2))
                .offset(x: 1, y: 1)
                .blur(radius: 1)
            content
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .black,
                            Color(white: 0.2),
                            .black
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    private func unitPointFromAngle(_ degrees: Double) -> UnitPoint {
        let radians = degrees * .pi / 180
        return UnitPoint(x: 0.5 + 0.5 * cos(radians), y: 0.5 + 0.5 * sin(radians))
    }

    @ViewBuilder
    private func customStyle(_ content: Content) -> some View {
        if artisticConfig.strokeWidth > 0 || artisticConfig.shadowBlur > 0 || artisticConfig.outerGlowRadius > 0 {
            customStyleWithEffects(content)
        } else if artisticConfig.gradientStartColor != artisticConfig.gradientEndColor {
            content
                .foregroundStyle(
                    LinearGradient(
                        colors: [artisticConfig.gradientStartColor, artisticConfig.gradientEndColor],
                        startPoint: unitPointFromAngle(artisticConfig.gradientAngle),
                        endPoint: unitPointFromAngle(artisticConfig.gradientAngle + 180)
                    )
                )
        } else {
            content
        }
    }

    @ViewBuilder
    private func customStyleWithEffects(_ content: Content) -> some View {
        ZStack {
            if artisticConfig.strokeWidth > 0 {
                content
                    .foregroundColor(artisticConfig.strokeColor)
                    .offset(x: -artisticConfig.strokeWidth, y: 0)
                content
                    .foregroundColor(artisticConfig.strokeColor)
                    .offset(x: artisticConfig.strokeWidth, y: 0)
                content
                    .foregroundColor(artisticConfig.strokeColor)
                    .offset(x: 0, y: -artisticConfig.strokeWidth)
                content
                    .foregroundColor(artisticConfig.strokeColor)
                    .offset(x: 0, y: artisticConfig.strokeWidth)
            }

            if artisticConfig.gradientStartColor != artisticConfig.gradientEndColor {
                content
                    .foregroundStyle(
                        LinearGradient(
                            colors: [artisticConfig.gradientStartColor, artisticConfig.gradientEndColor],
                            startPoint: unitPointFromAngle(artisticConfig.gradientAngle),
                            endPoint: unitPointFromAngle(artisticConfig.gradientAngle + 180)
                        )
                    )
                    .shadow(
                        color: artisticConfig.shadowColor,
                        radius: artisticConfig.shadowBlur,
                        x: artisticConfig.shadowOffsetX,
                        y: artisticConfig.shadowOffsetY
                    )
                    .shadow(
                        color: artisticConfig.outerGlowColor.opacity(0.6),
                        radius: artisticConfig.outerGlowRadius,
                        x: 0, y: 0
                    )
            } else {
                content
                    .shadow(
                        color: artisticConfig.shadowColor,
                        radius: artisticConfig.shadowBlur,
                        x: artisticConfig.shadowOffsetX,
                        y: artisticConfig.shadowOffsetY
                    )
                    .shadow(
                        color: artisticConfig.outerGlowColor.opacity(0.6),
                        radius: artisticConfig.outerGlowRadius,
                        x: 0, y: 0
                    )
            }
        }
    }
}

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

    @ViewBuilder
    private func basicNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.5), radius: CGFloat(neonConfig.glowRadius * 0.2), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.6 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.4), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.8 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.7), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

    @ViewBuilder
    private func softNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.3 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.4 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.3 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 1.5), x: 0, y: 0)
    }

    @ViewBuilder
    private func sharpNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.8 * neonConfig.glowIntensity), radius: 1, x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: 2, x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.6 * neonConfig.glowIntensity), radius: 4, x: 0, y: 0)
    }

    @ViewBuilder
    private func pulseNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.3), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.6), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

    @ViewBuilder
    private func flickerNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.6 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.9 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

    @ViewBuilder
    private func breathingNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.4 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.4), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.8), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
    }

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
