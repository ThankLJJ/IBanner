//
//  ArtisticStyleModifier.swift
//  Thank_L
//
//  艺术字样式 - 包含14种风格实现
//

import SwiftUI

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

    // MARK: - 金属质感
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

    // MARK: - 玻璃质感
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

    // MARK: - 木纹质感
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

    // MARK: - 石头质感
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

    // MARK: - 火焰效果
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

    // MARK: - 冰霜效果
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

    // MARK: - 电流效果
    @ViewBuilder
    private func electricStyle(_ content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .shadow(color: .cyan, radius: 2, x: 0, y: 0)
            .shadow(color: .blue.opacity(0.8), radius: 5, x: 0, y: 0)
            .shadow(color: .purple.opacity(0.6), radius: 10, x: 0, y: 0)
            .shadow(color: .cyan, radius: 15, x: 0, y: 0)
    }

    // MARK: - 烟雾效果
    @ViewBuilder
    private func smokeStyle(_ content: Content) -> some View {
        content
            .foregroundColor(textColor.opacity(0.8))
            .blur(radius: 0.5)
            .shadow(color: textColor.opacity(0.3), radius: 8, x: 0, y: 0)
            .shadow(color: .gray.opacity(0.2), radius: 15, x: 0, y: 0)
    }

    // MARK: - 复古风格
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

    // MARK: - 赛博朋克
    @ViewBuilder
    private func cyberpunkStyle(_ content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .shadow(color: .cyan, radius: 1, x: -2, y: 0)
            .shadow(color: Color(red: 1, green: 0, blue: 1), radius: 1, x: 2, y: 0)
            .shadow(color: .cyan.opacity(0.8), radius: 5, x: 0, y: 0)
            .shadow(color: Color(red: 1, green: 0, blue: 1).opacity(0.6), radius: 10, x: 0, y: 0)
    }

    // MARK: - 卡通描边
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

    // MARK: - 手写风格
    @ViewBuilder
    private func handwrittenStyle(_ content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .italic()
            .shadow(color: textColor.opacity(0.2), radius: 1, x: 1, y: 1)
    }

    // MARK: - 书法风格
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

    // MARK: - 自定义样式
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

    // MARK: - 辅助方法
    private func unitPointFromAngle(_ degrees: Double) -> UnitPoint {
        let radians = degrees * .pi / 180
        return UnitPoint(x: 0.5 + 0.5 * cos(radians), y: 0.5 + 0.5 * sin(radians))
    }
}
