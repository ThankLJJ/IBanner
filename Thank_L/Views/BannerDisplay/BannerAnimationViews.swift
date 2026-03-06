//
//  BannerAnimationViews.swift
//  Thank_L
//
//  Created by L on 2024/7/13.
//

import SwiftUI

struct StaticTextView: View {
    let displayText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig
    let padding: CGFloat

    var body: some View {
        Text(displayText)
            .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, padding)
            .modifier(FontStyleModifier(
                fontStyle: fontStyle,
                artisticStyle: artisticStyle,
                artisticConfig: artisticConfig,
                neonStyle: neonStyle,
                neonConfig: neonConfig,
                textColor: textColor
            ))
    }
}

struct ScrollingTextView: View {
    let displayText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let scrollDirection: ScrollDirection
    let scrollOffset: CGFloat
    let animationSpeed: Double
    let screenSize: CGSize
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig

    var body: some View {
        Group {
            switch scrollDirection {
            case .leftToRight, .rightToLeft:
                horizontalScrollingView
            case .topToBottom, .bottomToTop:
                verticalScrollingView
            }
        }
    }

    private var horizontalScrollingView: some View {
        HStack(spacing: 0) {
            styledText
                .fixedSize()

            Spacer()
                .frame(width: screenSize.width * 0.5)

            styledText
                .fixedSize()
        }
        .offset(x: scrollOffset)
        .animation(
            .linear(duration: 8.0 / animationSpeed)
            .repeatForever(autoreverses: false),
            value: scrollOffset
        )
    }

    private var verticalScrollingView: some View {
        VStack(spacing: 0) {
            styledText
                .fixedSize()

            Spacer()
                .frame(height: screenSize.height * 0.5)

            styledText
                .fixedSize()
        }
        .offset(y: scrollOffset)
        .animation(
            .linear(duration: 8.0 / animationSpeed)
            .repeatForever(autoreverses: false),
            value: scrollOffset
        )
    }

    private var styledText: some View {
        Text(displayText)
            .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
            .foregroundColor(textColor)
            .modifier(FontStyleModifier(
                fontStyle: fontStyle,
                artisticStyle: artisticStyle,
                artisticConfig: artisticConfig,
                neonStyle: neonStyle,
                neonConfig: neonConfig,
                textColor: textColor
            ))
    }
}

struct BlinkingTextView: View {
    let displayText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let isBlinking: Bool
    let minOpacity: Double
    let maxOpacity: Double
    let frequency: Double
    let animationSpeed: Double
    let padding: CGFloat
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig

    var body: some View {
        Text(displayText)
            .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
            .foregroundColor(textColor)
            .modifier(FontStyleModifier(
                fontStyle: fontStyle,
                artisticStyle: artisticStyle,
                artisticConfig: artisticConfig,
                neonStyle: neonStyle,
                neonConfig: neonConfig,
                textColor: textColor
            ))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, padding)
            .opacity(isBlinking ? minOpacity : maxOpacity)
            .animation(
                .easeInOut(duration: 1.0 / (frequency * animationSpeed))
                .repeatForever(autoreverses: true),
                value: isBlinking
            )
    }
}

struct BreathingTextView: View {
    let displayText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let isBreathingMin: Bool
    let minOpacity: Double
    let minScale: Double
    let maxScale: Double
    let animationSpeed: Double
    let padding: CGFloat
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig

    var body: some View {
        Text(displayText)
            .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
            .foregroundColor(textColor)
            .modifier(FontStyleModifier(
                fontStyle: fontStyle,
                artisticStyle: artisticStyle,
                artisticConfig: artisticConfig,
                neonStyle: neonStyle,
                neonConfig: neonConfig,
                textColor: textColor
            ))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, padding)
            .opacity(isBreathingMin ? minOpacity : 1.0)
            .scaleEffect(isBreathingMin ? minScale : maxScale)
            .animation(
                .easeInOut(duration: 2.0 / animationSpeed)
                .repeatForever(autoreverses: true),
                value: isBreathingMin
            )
    }
}

struct TypewriterTextView: View {
    let typewriterText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let padding: CGFloat
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig

    var body: some View {
        Text(typewriterText)
            .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
            .foregroundColor(textColor)
            .modifier(FontStyleModifier(
                fontStyle: fontStyle,
                artisticStyle: artisticStyle,
                artisticConfig: artisticConfig,
                neonStyle: neonStyle,
                neonConfig: neonConfig,
                textColor: textColor
            ))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, padding)
    }
}

struct RandomFlashTextView: View {
    let displayText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let positions: [CGPoint]
    let opacities: [Double]
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig

    var body: some View {
        ZStack {
            ForEach(0..<positions.count, id: \.self) { index in
                if index < opacities.count {
                    Text(displayText)
                        .font(.system(size: fontSize * 0.8, weight: isBold ? .bold : .regular))
                        .foregroundColor(textColor)
                        .modifier(FontStyleModifier(
                            fontStyle: fontStyle,
                            artisticStyle: artisticStyle,
                            artisticConfig: artisticConfig,
                            neonStyle: neonStyle,
                            neonConfig: neonConfig,
                            textColor: textColor
                        ))
                        .opacity(opacities[index])
                        .position(positions[index])
                        .scaleEffect(opacities[index])
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WaveTextView: View {
    let displayText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let wavePhase: CGFloat
    let waveAmplitude: CGFloat
    let waveFrequency: CGFloat
    let animationSpeed: Double
    let padding: CGFloat
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(displayText.enumerated()), id: \.offset) { index, char in
                Text(String(char))
                    .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
                    .foregroundColor(textColor)
                    .modifier(FontStyleModifier(
                        fontStyle: fontStyle,
                        artisticStyle: artisticStyle,
                        artisticConfig: artisticConfig,
                        neonStyle: neonStyle,
                        neonConfig: neonConfig,
                        textColor: textColor
                    ))
                    .offset(y: sin(wavePhase + CGFloat(index) * waveFrequency) * waveAmplitude)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, padding)
        .animation(
            .linear(duration: 2.0 / animationSpeed)
            .repeatForever(autoreverses: false),
            value: wavePhase
        )
    }
}

struct BounceTextView: View {
    let displayText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let bounceScale: CGFloat
    let bounceOffset: CGFloat
    let padding: CGFloat
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig

    var body: some View {
        Text(displayText)
            .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
            .foregroundColor(textColor)
            .modifier(FontStyleModifier(
                fontStyle: fontStyle,
                artisticStyle: artisticStyle,
                artisticConfig: artisticConfig,
                neonStyle: neonStyle,
                neonConfig: neonConfig,
                textColor: textColor
            ))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, padding)
            .scaleEffect(bounceScale)
            .offset(y: bounceOffset)
    }
}

struct ParticlesTextView: View {
    let displayText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let particles: [Particle]
    let padding: CGFloat
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .opacity(particle.opacity)
                    .offset(x: particle.x, y: particle.y)
            }

            Text(displayText)
                .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
                .foregroundColor(textColor)
                .modifier(FontStyleModifier(
                    fontStyle: fontStyle,
                    artisticStyle: artisticStyle,
                    artisticConfig: artisticConfig,
                    neonStyle: neonStyle,
                    neonConfig: neonConfig,
                    textColor: textColor
                ))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LedTextView: View {
    let displayText: String
    let fontSize: CGFloat
    let isBold: Bool
    let textColor: Color
    let backgroundColor: Color
    let wavePhase: CGFloat
    let ledConfig: LedAnimationConfig
    let animationSpeed: Double
    let padding: CGFloat

    var body: some View {
        ZStack {
            Canvas { context, size in
                let dotSpacing = ledConfig.dotSpacing
                let dotSize = ledConfig.dotSize
                let cols = Int(size.width / dotSpacing)
                let rows = Int(size.height / dotSpacing)

                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * dotSpacing
                        let y = CGFloat(row) * dotSpacing
                        let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)

                        let flicker = ledConfig.flickerEnabled ? sin(wavePhase + CGFloat(row + col) * 0.1) : 0
                        let brightness = 0.1 + ledConfig.glowIntensity * 0.2 * flicker
                        context.fill(
                            Ellipse().path(in: rect),
                            with: .color(textColor.opacity(brightness))
                        )
                    }
                }
            }

            Text(displayText)
                .font(.system(size: fontSize, weight: isBold ? .heavy : .bold, design: .monospaced))
                .foregroundColor(textColor)
                .shadow(color: textColor, radius: 5, x: 0, y: 0)
                .shadow(color: textColor.opacity(0.7), radius: 10, x: 0, y: 0)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .onAppear {
            withAnimation(.linear(duration: 3.0 / animationSpeed).repeatForever(autoreverses: false)) {
            }
        }
    }
}
