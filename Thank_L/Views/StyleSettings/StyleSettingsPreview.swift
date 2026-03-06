//
//  StyleSettingsPreview.swift
//  Thank_L
//
//  StyleSettingsView 的预览组件
//

import SwiftUI

struct StylePreviewSection: View {
    @Binding var bannerStyle: BannerStyle
    @Binding var previewScrollOffset: CGFloat
    @Binding var previewIsBlinking: Bool
    @Binding var previewBreathingOpacity: Double
    @Binding var previewWavePhase: CGFloat
    @Binding var previewBounceScale: CGFloat
    @Binding var previewGradientOffset: CGFloat
    
    var body: some View {
        VStack(spacing: 12) {
            Text(L10n.Content.preview)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bannerStyle.backgroundColor)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                if bannerStyle.animationType == .gradient {
                    LinearGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .opacity(0.8)
                    .offset(x: previewGradientOffset)
                    .animation(
                        .linear(duration: 3.0 / bannerStyle.animationSpeed)
                        .repeatForever(autoreverses: false),
                        value: previewGradientOffset
                    )
                }

                if bannerStyle.backgroundType == .image,
                   let imagePath = bannerStyle.backgroundImagePath,
                   let url = URL(string: "file://" + imagePath) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                                .opacity(bannerStyle.backgroundImageOpacity)
                        default:
                            Color.clear
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                previewAnimatedText
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private var previewAnimatedText: some View {
        let previewText = bannerStyle.text.isEmpty ? L10n.Content.previewText : bannerStyle.text

        switch bannerStyle.animationType {
        case .scroll:
            HStack(spacing: 0) {
                Text(previewText)
                    .font(.system(
                        size: min(bannerStyle.fontSize * 0.4, 24),
                        weight: bannerStyle.isBold ? .bold : .regular
                    ))
                    .foregroundColor(bannerStyle.textColor)
                    .modifier(FontStyleModifier(
                        fontStyle: bannerStyle.fontStyle,
                        artisticStyle: bannerStyle.artisticStyle,
                        artisticConfig: bannerStyle.artisticConfig,
                        neonStyle: bannerStyle.neonStyle,
                        neonConfig: bannerStyle.neonConfig,
                        textColor: bannerStyle.textColor
                    ))
                    .fixedSize()

                Spacer().frame(width: 60)

                Text(previewText)
                    .font(.system(
                        size: min(bannerStyle.fontSize * 0.4, 24),
                        weight: bannerStyle.isBold ? .bold : .regular
                    ))
                    .foregroundColor(bannerStyle.textColor)
                    .modifier(FontStyleModifier(
                        fontStyle: bannerStyle.fontStyle,
                        artisticStyle: bannerStyle.artisticStyle,
                        artisticConfig: bannerStyle.artisticConfig,
                        neonStyle: bannerStyle.neonStyle,
                        neonConfig: bannerStyle.neonConfig,
                        textColor: bannerStyle.textColor
                    ))
                    .fixedSize()
            }
            .offset(x: previewScrollOffset)
            .animation(
                .linear(duration: 4.0 / bannerStyle.animationSpeed)
                .repeatForever(autoreverses: false),
                value: previewScrollOffset
            )

        case .blink:
            let minOpacity = bannerStyle.blinkConfig?.minOpacity ?? 0.3
            let frequency = bannerStyle.blinkConfig?.frequency ?? 1.0
            previewTextWithStyle(previewText)
                .opacity(previewIsBlinking ? minOpacity : 1.0)
                .animation(
                    .easeInOut(duration: 0.5 / (frequency * bannerStyle.animationSpeed))
                    .repeatForever(autoreverses: true),
                    value: previewIsBlinking
                )

        case .breathing:
            let minScale = bannerStyle.breathingConfig?.minScale ?? 0.8
            let maxScale = bannerStyle.breathingConfig?.maxScale ?? 1.2
            let minOpacity = bannerStyle.breathingConfig?.minOpacity ?? 0.5
            previewTextWithStyle(previewText)
                .opacity(previewBreathingOpacity)
                .scaleEffect(minScale + (previewBreathingOpacity - minOpacity) * (maxScale - minScale) / (1.0 - minOpacity))
                .animation(
                    .easeInOut(duration: 2.0 / bannerStyle.animationSpeed)
                    .repeatForever(autoreverses: true),
                    value: previewBreathingOpacity
                )

        case .wave:
            let amplitude = bannerStyle.waveConfig?.amplitude ?? 15
            let waveFrequency = bannerStyle.waveConfig?.frequency ?? 0.5
            HStack(spacing: 0) {
                ForEach(Array(previewText.enumerated()), id: \.offset) { index, char in
                    previewCharWithStyle(String(char))
                        .offset(y: sin(previewWavePhase + CGFloat(index) * CGFloat(waveFrequency)) * CGFloat(amplitude) * 0.5)
                }
            }
            .padding(.horizontal, 16)

        case .bounce:
            let bounceHeight = bannerStyle.bounceConfig?.bounceHeight ?? 20
            let elasticity = bannerStyle.bounceConfig?.elasticity ?? 0.3
            previewTextWithStyle(previewText)
                .scaleEffect(previewBounceScale)
                .offset(y: (previewBounceScale - 1.0) * CGFloat(-bounceHeight) * CGFloat(elasticity))
                .animation(
                    .spring(response: 0.5, dampingFraction: CGFloat(elasticity), blendDuration: 0.5)
                    .repeatForever(autoreverses: true),
                    value: previewBounceScale
                )

        default:
            previewTextWithStyle(previewText)
        }
    }

    @ViewBuilder
    private func previewTextWithStyle(_ text: String) -> some View {
        Text(text)
            .font(.system(
                size: min(bannerStyle.fontSize * 0.4, 24),
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .modifier(FontStyleModifier(
                fontStyle: bannerStyle.fontStyle,
                artisticStyle: bannerStyle.artisticStyle,
                artisticConfig: bannerStyle.artisticConfig,
                neonStyle: bannerStyle.neonStyle,
                neonConfig: bannerStyle.neonConfig,
                textColor: bannerStyle.textColor
            ))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func previewCharWithStyle(_ char: String) -> some View {
        Text(char)
            .font(.system(
                size: min(bannerStyle.fontSize * 0.4, 24),
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .modifier(FontStyleModifier(
                fontStyle: bannerStyle.fontStyle,
                artisticStyle: bannerStyle.artisticStyle,
                artisticConfig: bannerStyle.artisticConfig,
                neonStyle: bannerStyle.neonStyle,
                neonConfig: bannerStyle.neonConfig,
                textColor: bannerStyle.textColor
            ))
    }
}
