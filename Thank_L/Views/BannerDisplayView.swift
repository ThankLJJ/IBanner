//
//  BannerDisplayView.swift
//  Thank_L
//
//  Created by L on 2024/7/13.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct BannerDisplayView: View {
    let bannerStyle: BannerStyle
    var isSubscribed: Bool = false
    var onTimeLimitReached: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var scrollOffset: CGFloat = 0
    @State private var isBlinking: Bool = false
    @State private var gradientOffset: CGFloat = 0
    @State private var isBreathingMin: Bool = false
    @State private var isAnimating: Bool = false

    @State private var displayTimer: Timer?
    @State private var remainingTime: TimeInterval = SubscriptionManager.freeDisplayLimit

    @State private var typewriterText: String = ""
    @State private var typewriterIndex: Int = 0
    @State private var typewriterTimer: Timer?
    @State private var randomFlashPositions: [CGPoint] = []
    @State private var randomFlashOpacities: [Double] = []
    @State private var randomFlashTimer: Timer?

    @State private var wavePhase: CGFloat = 0

    @State private var bounceScale: CGFloat = 1.0
    @State private var bounceOffset: CGFloat = 0

    @State private var particles: [Particle] = []
    @State private var particleTimer: Timer?

    @State private var ledPhase: CGFloat = 0

    @State private var screenSize: CGSize = .zero

    private var isIPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }

    private var displayText: String {
        bannerStyle.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? L10n.Content.previewText
            : bannerStyle.text
    }

    private var adaptiveFontSize: CGFloat {
        let baseFontSize = bannerStyle.fontSize
        return isIPad ? baseFontSize * 1.2 : baseFontSize
    }

    private var adaptivePadding: CGFloat {
        return isIPad ? 40 : 20
    }

    private var effectiveBlinkConfig: BlinkAnimationConfig {
        bannerStyle.blinkConfig ?? .default
    }

    private var effectiveBreathingConfig: BreathingAnimationConfig {
        bannerStyle.breathingConfig ?? .default
    }

    private var effectiveWaveConfig: WaveAnimationConfig {
        bannerStyle.waveConfig ?? .default
    }

    private var effectiveParticlesConfig: ParticlesAnimationConfig {
        bannerStyle.particlesConfig ?? .default
    }

    private var effectiveBounceConfig: BounceAnimationConfig {
        bannerStyle.bounceConfig ?? .default
    }

    private var effectiveLedConfig: LedAnimationConfig {
        bannerStyle.ledConfig ?? .default
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView
                    .ignoresSafeArea(.all)

                textContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if !isSubscribed {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(Int(remainingTime))s")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(16)
                                .padding()
                        }
                    }
                }
            }
            .onAppear {
                screenSize = geometry.size
                startAnimation()
                startDisplayTimer()
            }
            .onDisappear {
                stopAnimation()
                stopDisplayTimer()
            }
            .onTapGesture(count: 2) {
                #if os(iOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                #endif
                dismiss()
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.height > 100 {
                            #if os(iOS)
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            #endif
                            dismiss()
                        }
                    }
            )
        }
        #if os(iOS)
        .navigationBarHidden(true)
        .statusBarHidden(true)
        .ignoresSafeArea(.all)
        #elseif os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        #endif
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var backgroundView: some View {
        ZStack {
            if bannerStyle.backgroundType == .image && bannerStyle.backgroundImagePath != nil {
                AsyncImage(url: getImageURL()) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .opacity(bannerStyle.backgroundImageOpacity)
                } placeholder: {
                    bannerStyle.backgroundColor
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                bannerStyle.backgroundColor
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if bannerStyle.animationType == .gradient {
                LinearGradient(
                    colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(0.8)
                .offset(x: gradientOffset)
                .animation(
                    .linear(duration: 3.0 / bannerStyle.animationSpeed)
                    .repeatForever(autoreverses: false),
                    value: gradientOffset
                )
            }
        }
    }

    @ViewBuilder
    private var textContentView: some View {
        switch bannerStyle.animationType {
        case .scroll:
            scrollingTextView
        case .blink:
            blinkingTextView
        case .breathing:
            breathingTextView
        case .typewriter:
            typewriterTextView
        case .randomFlash:
            randomFlashTextView
        case .wave:
            waveTextView
        case .bounce:
            bounceTextView
        case .particles:
            particlesTextView
        case .led:
            ledTextView
        default:
            staticTextView
        }
    }

    private var staticTextView: some View {
        StaticTextView(
            displayText: displayText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            fontStyle: bannerStyle.fontStyle,
            artisticStyle: bannerStyle.artisticStyle,
            artisticConfig: bannerStyle.artisticConfig,
            neonStyle: bannerStyle.neonStyle,
            neonConfig: bannerStyle.neonConfig,
            padding: adaptivePadding
        )
    }

    private var scrollingTextView: some View {
        ScrollingTextView(
            displayText: displayText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            scrollDirection: bannerStyle.scrollDirection,
            scrollOffset: scrollOffset,
            animationSpeed: bannerStyle.animationSpeed,
            screenSize: screenSize,
            fontStyle: bannerStyle.fontStyle,
            artisticStyle: bannerStyle.artisticStyle,
            artisticConfig: bannerStyle.artisticConfig,
            neonStyle: bannerStyle.neonStyle,
            neonConfig: bannerStyle.neonConfig
        )
    }

    private var blinkingTextView: some View {
        BlinkingTextView(
            displayText: displayText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            isBlinking: isBlinking,
            minOpacity: effectiveBlinkConfig.minOpacity,
            maxOpacity: effectiveBlinkConfig.maxOpacity,
            frequency: effectiveBlinkConfig.frequency,
            animationSpeed: bannerStyle.animationSpeed,
            padding: adaptivePadding,
            fontStyle: bannerStyle.fontStyle,
            artisticStyle: bannerStyle.artisticStyle,
            artisticConfig: bannerStyle.artisticConfig,
            neonStyle: bannerStyle.neonStyle,
            neonConfig: bannerStyle.neonConfig
        )
    }

    private var breathingTextView: some View {
        BreathingTextView(
            displayText: displayText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            isBreathingMin: isBreathingMin,
            minOpacity: effectiveBreathingConfig.minOpacity,
            minScale: effectiveBreathingConfig.minScale,
            maxScale: effectiveBreathingConfig.maxScale,
            animationSpeed: bannerStyle.animationSpeed,
            padding: adaptivePadding,
            fontStyle: bannerStyle.fontStyle,
            artisticStyle: bannerStyle.artisticStyle,
            artisticConfig: bannerStyle.artisticConfig,
            neonStyle: bannerStyle.neonStyle,
            neonConfig: bannerStyle.neonConfig
        )
    }

    private var typewriterTextView: some View {
        TypewriterTextView(
            typewriterText: typewriterText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            padding: adaptivePadding,
            fontStyle: bannerStyle.fontStyle,
            artisticStyle: bannerStyle.artisticStyle,
            artisticConfig: bannerStyle.artisticConfig,
            neonStyle: bannerStyle.neonStyle,
            neonConfig: bannerStyle.neonConfig
        )
        .onAppear {
            startTypewriterAnimation()
        }
    }

    private var randomFlashTextView: some View {
        RandomFlashTextView(
            displayText: displayText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            positions: randomFlashPositions,
            opacities: randomFlashOpacities,
            fontStyle: bannerStyle.fontStyle,
            artisticStyle: bannerStyle.artisticStyle,
            artisticConfig: bannerStyle.artisticConfig,
            neonStyle: bannerStyle.neonStyle,
            neonConfig: bannerStyle.neonConfig
        )
        .onAppear {
            startRandomFlashAnimation()
        }
    }

    private var waveTextView: some View {
        WaveTextView(
            displayText: displayText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            wavePhase: wavePhase,
            waveAmplitude: effectiveWaveConfig.amplitude,
            waveFrequency: effectiveWaveConfig.frequency,
            animationSpeed: bannerStyle.animationSpeed,
            padding: adaptivePadding,
            fontStyle: bannerStyle.fontStyle,
            artisticStyle: bannerStyle.artisticStyle,
            artisticConfig: bannerStyle.artisticConfig,
            neonStyle: bannerStyle.neonStyle,
            neonConfig: bannerStyle.neonConfig
        )
    }

    private var bounceTextView: some View {
        BounceTextView(
            displayText: displayText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            bounceScale: bounceScale,
            bounceOffset: bounceOffset,
            padding: adaptivePadding,
            fontStyle: bannerStyle.fontStyle,
            artisticStyle: bannerStyle.artisticStyle,
            artisticConfig: bannerStyle.artisticConfig,
            neonStyle: bannerStyle.neonStyle,
            neonConfig: bannerStyle.neonConfig
        )
    }

    private var particlesTextView: some View {
        ParticlesTextView(
            displayText: displayText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            particles: particles,
            padding: adaptivePadding,
            fontStyle: bannerStyle.fontStyle,
            artisticStyle: bannerStyle.artisticStyle,
            artisticConfig: bannerStyle.artisticConfig,
            neonStyle: bannerStyle.neonStyle,
            neonConfig: bannerStyle.neonConfig
        )
        .onAppear {
            startParticlesAnimation()
        }
    }

    private var ledTextView: some View {
        LedTextView(
            displayText: displayText,
            fontSize: adaptiveFontSize,
            isBold: bannerStyle.isBold,
            textColor: bannerStyle.textColor,
            backgroundColor: bannerStyle.backgroundColor,
            wavePhase: wavePhase,
            ledConfig: effectiveLedConfig,
            animationSpeed: bannerStyle.animationSpeed,
            padding: adaptivePadding
        )
        .onAppear {
            withAnimation(.linear(duration: 3.0 / bannerStyle.animationSpeed).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }

    private func getImageURL() -> URL? {
        guard let imagePath = bannerStyle.backgroundImagePath else { return nil }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsPath.appendingPathComponent(imagePath)

        if FileManager.default.fileExists(atPath: imageURL.path) {
            return imageURL
        }

        if let bundleURL = Bundle.main.url(forResource: imagePath.replacingOccurrences(of: ".jpg", with: "").replacingOccurrences(of: ".png", with: ""), withExtension: nil) {
            return bundleURL
        }

        return nil
    }

    private func startTypewriterAnimation() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil

        typewriterText = ""
        typewriterIndex = 0

        let interval = 0.1 / bannerStyle.animationSpeed

        typewriterTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if typewriterIndex < displayText.count {
                let index = displayText.index(displayText.startIndex, offsetBy: typewriterIndex)
                typewriterText = String(displayText[...index])
                typewriterIndex += 1
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 / bannerStyle.animationSpeed) {
                    startTypewriterAnimation()
                }
                timer.invalidate()
            }
        }
    }

    private func startRandomFlashAnimation() {
        let flashCount = 5
        randomFlashPositions = []
        randomFlashOpacities = Array(repeating: 0.0, count: flashCount)

        for _ in 0..<flashCount {
            let x = CGFloat.random(in: 50...(screenSize.width - 50))
            let y = CGFloat.random(in: 100...(screenSize.height - 100))
            randomFlashPositions.append(CGPoint(x: x, y: y))
        }

        randomFlashTimer = Timer.scheduledTimer(withTimeInterval: 0.3 / bannerStyle.animationSpeed, repeats: true) { _ in
            let randomIndex = Int.random(in: 0..<flashCount)

            guard randomIndex < randomFlashOpacities.count else { return }

            withAnimation(.easeInOut(duration: 0.5 / bannerStyle.animationSpeed)) {
                if randomIndex < randomFlashOpacities.count {
                    randomFlashOpacities[randomIndex] = 1.0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 / bannerStyle.animationSpeed) {
                withAnimation(.easeInOut(duration: 0.3 / bannerStyle.animationSpeed)) {
                    if randomIndex < randomFlashOpacities.count {
                        randomFlashOpacities[randomIndex] = 0.0
                    }
                }
            }

            if Bool.random() && randomIndex < randomFlashPositions.count {
                let x = CGFloat.random(in: 50...(screenSize.width - 50))
                let y = CGFloat.random(in: 100...(screenSize.height - 100))
                randomFlashPositions[randomIndex] = CGPoint(x: x, y: y)
            }
        }
    }

    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true

        switch bannerStyle.animationType {
        case .scroll:
            #if os(iOS)
            let font = UIFont.systemFont(
                ofSize: bannerStyle.fontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            )
            #elseif os(macOS)
            let font = NSFont.systemFont(
                ofSize: bannerStyle.fontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            )
            #endif
            let textWidth = displayText.widthOfString(usingFont: font)
            let textHeight = bannerStyle.fontSize

            switch bannerStyle.scrollDirection {
            case .leftToRight:
                scrollOffset = -(textWidth + screenSize.width * 0.5)
            case .rightToLeft:
                scrollOffset = textWidth + screenSize.width * 0.5
            case .topToBottom:
                scrollOffset = -(textHeight + screenSize.height * 0.5)
            case .bottomToTop:
                scrollOffset = textHeight + screenSize.height * 0.5
            }

        case .blink:
            isBlinking = true

        case .gradient:
            gradientOffset = -screenSize.width

        case .breathing:
            isBreathingMin = false

        case .typewriter:
            startTypewriterAnimation()

        case .randomFlash:
            startRandomFlashAnimation()

        case .wave:
            wavePhase = 0

        case .bounce:
            startBounceAnimation()

        case .particles:
            startParticlesAnimation()

        case .led:
            wavePhase = 0

        case .none:
            break
        }
    }

    private func stopAnimation() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil

        randomFlashTimer?.invalidate()
        randomFlashTimer = nil

        particleTimer?.invalidate()
        particleTimer = nil

        typewriterText = ""
        typewriterIndex = 0
        randomFlashPositions = []
        randomFlashOpacities = []
        particles = []

        isAnimating = false
    }

    private func startBounceAnimation() {
        let config = effectiveBounceConfig
        bounceScale = 1.0 - config.squashAmount
        bounceOffset = config.bounceHeight

        withAnimation(.spring(response: 0.5, dampingFraction: config.elasticity, blendDuration: 0.5).repeatForever(autoreverses: true)) {
            bounceScale = 1.0 + config.squashAmount
            bounceOffset = -config.bounceHeight
        }
    }

    private func startParticlesAnimation() {
        particles = []
        let config = effectiveParticlesConfig

        for _ in 0..<config.particleCount {
            particles.append(createParticle())
        }

        particleTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateParticles()
        }
    }

    private func createParticle() -> Particle {
        let config = effectiveParticlesConfig
        return Particle(
            x: CGFloat.random(in: -screenSize.width/2...screenSize.width/2),
            y: screenSize.height / 2,
            size: CGFloat.random(in: config.particleSizeMin...config.particleSizeMax),
            color: config.particleColors.randomElement() ?? .white,
            speed: CGFloat.random(in: 1...3),
            opacity: 1.0
        )
    }

    private func updateParticles() {
        for i in particles.indices {
            particles[i].y -= particles[i].speed
            particles[i].opacity -= 0.01
            particles[i].x += CGFloat.random(in: -0.5...0.5)

            if particles[i].opacity <= 0 || particles[i].y < -screenSize.height / 2 {
                particles[i] = createParticle()
            }
        }
    }

    private func startDisplayTimer() {
        guard !isSubscribed else { return }

        remainingTime = SubscriptionManager.freeDisplayLimit

        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            remainingTime -= 1

            if remainingTime <= 0 {
                stopDisplayTimer()
                dismiss()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onTimeLimitReached?()
                }
            }
        }
    }

    private func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }
}

struct BannerDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "欢迎使用 Thank_L",
                    fontSize: 48,
                    textColor: .white,
                    backgroundColor: .blue,
                    animationType: .none
                )
            )
            .previewDisplayName("静态显示")

            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "滚动横幅效果展示",
                    fontSize: 52,
                    textColor: .yellow,
                    backgroundColor: .black,
                    animationType: .scroll,
                    animationSpeed: 1.0
                )
            )
            .previewDisplayName("滚动效果")

            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "闪烁灯牌效果",
                    fontSize: 56,
                    textColor: .white,
                    backgroundColor: .red,
                    animationType: .blink,
                    animationSpeed: 1.5,
                    isBold: true
                )
            )
            .previewDisplayName("闪烁效果")

            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "呼吸灯效果",
                    fontSize: 50,
                    textColor: .white,
                    backgroundColor: .purple,
                    animationType: .breathing,
                    animationSpeed: 0.8
                )
            )
            .previewDisplayName("呼吸灯效果")
        }
    }
}
