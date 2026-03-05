//
//  BannerDisplayView.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// 横幅全屏展示页面
/// 支持多种动画效果：滚动、闪烁、渐变、呼吸灯、波浪、弹跳、粒子、LED等
/// 已优化iPad和iPhone的全屏显示体验
struct BannerDisplayView: View {
    // MARK: - 属性
    let bannerStyle: BannerStyle
    var isSubscribed: Bool = false
    var onTimeLimitReached: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    // MARK: - 动画状态
    @State private var scrollOffset: CGFloat = 0
    @State private var isBlinking: Bool = false
    @State private var gradientOffset: CGFloat = 0
    @State private var breathingOpacity: Double = 1.0
    @State private var isBreathingMin: Bool = false
    @State private var isAnimating: Bool = false

    // MARK: - 时间限制状态
    @State private var displayTimer: Timer?
    @State private var remainingTime: TimeInterval = SubscriptionManager.freeDisplayLimit
    @State private var showingTimeLimitAlert = false

    // 新动效状态变量
    @State private var typewriterText: String = ""
    @State private var typewriterIndex: Int = 0
    @State private var typewriterTimer: Timer?
    @State private var randomFlashPositions: [CGPoint] = []
    @State private var randomFlashOpacities: [Double] = []
    @State private var randomFlashTimer: Timer?

    // 波浪动画状态
    @State private var wavePhase: CGFloat = 0

    // 弹跳动画状态
    @State private var bounceScale: CGFloat = 1.0
    @State private var bounceOffset: CGFloat = 0

    // 粒子动画状态
    @State private var particles: [Particle] = []
    @State private var particleTimer: Timer?

    // LED动画状态
    @State private var ledPhase: CGFloat = 0

    // 屏幕尺寸和设备信息
    @State private var screenSize: CGSize = .zero

    // MARK: - 计算属性：设备适配
    private var isIPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }

    // 实际显示的文字（空时使用预览文字）
    private var displayText: String {
        bannerStyle.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? L10n.Content.previewText
            : bannerStyle.text
    }

    // 自适应字体大小
    private var adaptiveFontSize: CGFloat {
        let baseFontSize = bannerStyle.fontSize
        if isIPad {
            // iPad上字体稍大一些，考虑更大的屏幕
            return baseFontSize * 1.2
        } else {
            return baseFontSize
        }
    }

    // 自适应边距
    private var adaptivePadding: CGFloat {
        return isIPad ? 40 : 20
    }

    // MARK: - 动效配置帮助属性
    /// 获取滚动动效配置（使用自定义配置或默认值）
    private var effectiveScrollConfig: ScrollAnimationConfig {
        bannerStyle.scrollConfig ?? .default
    }

    /// 获取闪烁动效配置
    private var effectiveBlinkConfig: BlinkAnimationConfig {
        bannerStyle.blinkConfig ?? .default
    }

    /// 获取呼吸灯动效配置
    private var effectiveBreathingConfig: BreathingAnimationConfig {
        bannerStyle.breathingConfig ?? .default
    }

    /// 获取波浪动效配置
    private var effectiveWaveConfig: WaveAnimationConfig {
        bannerStyle.waveConfig ?? .default
    }

    /// 获取粒子动效配置
    private var effectiveParticlesConfig: ParticlesAnimationConfig {
        bannerStyle.particlesConfig ?? .default
    }

    /// 获取弹跳动效配置
    private var effectiveBounceConfig: BounceAnimationConfig {
        bannerStyle.bounceConfig ?? .default
    }

    /// 获取渐变动效配置
    private var effectiveGradientConfig: GradientAnimationConfig {
        bannerStyle.gradientConfig ?? .default
    }

    /// 获取逐字显示动效配置
    private var effectiveTypewriterConfig: TypewriterAnimationConfig {
        bannerStyle.typewriterConfig ?? .default
    }

    /// 获取随机闪现动效配置
    private var effectiveRandomFlashConfig: RandomFlashAnimationConfig {
        bannerStyle.randomFlashConfig ?? .default
    }

    /// 获取LED动效配置
    private var effectiveLedConfig: LedAnimationConfig {
        bannerStyle.ledConfig ?? .default
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景层
                backgroundView
                    .ignoresSafeArea(.all)

                // 文字内容层
                textContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 免费用户倒计时提示
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
            // 双击退出手势
            .onTapGesture(count: 2) {
                // 添加触觉反馈（仅iOS）
                #if os(iOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                #endif
                dismiss()
            }
            // 下滑退出手势
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // 下滑超过100点退出
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
        .ignoresSafeArea(.all) // 确保全屏显示
        #elseif os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all) // 确保全屏显示
        #endif
        .preferredColorScheme(.dark) // 确保状态栏为浅色
    }
    
    // MARK: - 背景视图
    @ViewBuilder
    private var backgroundView: some View {
        ZStack {
            // 基础背景
            if bannerStyle.backgroundType == .image && bannerStyle.backgroundImagePath != nil {
                // 图片背景 - 自适应屏幕大小
                AsyncImage(url: getImageURL()) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill) // 填充整个屏幕，保持比例
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 占满整个容器
                        .clipped() // 裁剪超出部分
                        .opacity(bannerStyle.backgroundImageOpacity)
                } placeholder: {
                    // 加载中显示纯色背景
                    bannerStyle.backgroundColor
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // 纯色背景
                bannerStyle.backgroundColor
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // 动画效果层
            if bannerStyle.animationType == .gradient {
                // 彩虹渐变背景
                LinearGradient(
                    colors: [
                        .red, .orange, .yellow, .green, .blue, .purple, .pink
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(0.8) // 半透明以便与背景图片混合
                .offset(x: gradientOffset)
                .animation(
                    .linear(duration: 3.0 / bannerStyle.animationSpeed)
                    .repeatForever(autoreverses: false),
                    value: gradientOffset
                )
            }
        }
    }
    
    // MARK: - 文字内容视图
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
    
    // MARK: - 静态文本视图
    private var staticTextView: some View {
        Text(displayText)
            .font(.system(
                size: adaptiveFontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, adaptivePadding)
            .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
    }
    
    // MARK: - 滚动文本视图
    private var scrollingTextView: some View {
        Group {
            switch bannerStyle.scrollDirection {
            case .leftToRight, .rightToLeft:
                // 水平滚动
                HStack(spacing: 0) {
                    // 第一个文本
                    Text(displayText)
                        .font(.system(
                            size: adaptiveFontSize,
                            weight: bannerStyle.isBold ? .bold : .regular
                        ))
                        .foregroundColor(bannerStyle.textColor)
                        .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                        .fixedSize()

                    // 间距
                    Spacer()
                        .frame(width: screenSize.width * 0.5)

                    // 第二个文本（用于无缝滚动）
                    Text(displayText)
                        .font(.system(
                            size: adaptiveFontSize,
                            weight: bannerStyle.isBold ? .bold : .regular
                        ))
                        .foregroundColor(bannerStyle.textColor)
                        .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                        .fixedSize()
                }
                .offset(x: scrollOffset)
                .animation(
                    .linear(duration: 8.0 / bannerStyle.animationSpeed)
                    .repeatForever(autoreverses: false),
                    value: scrollOffset
                )

            case .topToBottom, .bottomToTop:
                // 垂直滚动
                VStack(spacing: 0) {
                    // 第一个文本
                    Text(displayText)
                        .font(.system(
                            size: adaptiveFontSize,
                            weight: bannerStyle.isBold ? .bold : .regular
                        ))
                        .foregroundColor(bannerStyle.textColor)
                        .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                        .fixedSize()

                    // 间距
                    Spacer()
                        .frame(height: screenSize.height * 0.5)

                    // 第二个文本（用于无缝滚动）
                    Text(displayText)
                        .font(.system(
                            size: adaptiveFontSize,
                            weight: bannerStyle.isBold ? .bold : .regular
                        ))
                        .foregroundColor(bannerStyle.textColor)
                        .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                        .fixedSize()
                }
                .offset(y: scrollOffset)
                .animation(
                    .linear(duration: 8.0 / bannerStyle.animationSpeed)
                    .repeatForever(autoreverses: false),
                    value: scrollOffset
                )
            }
        }
    }
    
    // MARK: - 闪烁文本视图
    private var blinkingTextView: some View {
        Text(displayText)
            .font(.system(
                size: adaptiveFontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, adaptivePadding)
            .opacity(isBlinking ? effectiveBlinkConfig.minOpacity : effectiveBlinkConfig.maxOpacity)
            .animation(
                .easeInOut(duration: 1.0 / (effectiveBlinkConfig.frequency * bannerStyle.animationSpeed))
                .repeatForever(autoreverses: true),
                value: isBlinking
            )
    }
    
    // MARK: - 呼吸灯文本视图
    private var breathingTextView: some View {
        Text(displayText)
            .font(.system(
                size: adaptiveFontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, adaptivePadding)
            .opacity(isBreathingMin ? effectiveBreathingConfig.minOpacity : 1.0)
            .scaleEffect(isBreathingMin ? effectiveBreathingConfig.minScale : effectiveBreathingConfig.maxScale)
            .animation(
                .easeInOut(duration: 2.0 / bannerStyle.animationSpeed)
                .repeatForever(autoreverses: true),
                value: isBreathingMin
            )
    }
    
    // MARK: - 打字机文本视图
    private var typewriterTextView: some View {
        Text(typewriterText)
            .font(.system(
                size: adaptiveFontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, adaptivePadding)
            .onAppear {
                startTypewriterAnimation()
            }
    }
    
    // MARK: - 随机闪烁文本视图
    private var randomFlashTextView: some View {
        ZStack {
            ForEach(0..<randomFlashPositions.count, id: \.self) { index in
                if index < randomFlashOpacities.count {
                    Text(displayText)
                        .font(.system(
                            size: adaptiveFontSize * 0.8, // 稍微小一点避免重叠
                            weight: bannerStyle.isBold ? .bold : .regular
                        ))
                        .foregroundColor(bannerStyle.textColor)
                        .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                        .opacity(randomFlashOpacities[index])
                        .position(randomFlashPositions[index])
                        .scaleEffect(randomFlashOpacities[index])
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startRandomFlashAnimation()
        }
    }

    // MARK: - 波浪文本视图
    private var waveTextView: some View {
        HStack(spacing: 0) {
            ForEach(Array(displayText.enumerated()), id: \.offset) { index, char in
                Text(String(char))
                    .font(.system(
                        size: adaptiveFontSize,
                        weight: bannerStyle.isBold ? .bold : .regular
                    ))
                    .foregroundColor(bannerStyle.textColor)
                    .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                    .offset(y: sin(wavePhase + CGFloat(index) * 0.5) * 15)
            }
        }
        .padding(.horizontal, adaptivePadding)
        .onAppear {
            withAnimation(.linear(duration: 2.0 / bannerStyle.animationSpeed).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }

    // MARK: - 弹跳文本视图
    private var bounceTextView: some View {
        Text(displayText)
            .font(.system(
                size: adaptiveFontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, adaptivePadding)
            .scaleEffect(bounceScale)
            .offset(y: bounceOffset)
            .onAppear {
                startBounceAnimation()
            }
    }

    // MARK: - 粒子文本视图
    private var particlesTextView: some View {
        ZStack {
            // 粒子层
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .opacity(particle.opacity)
                    .offset(x: particle.x, y: particle.y)
            }

            // 主文本
            Text(displayText)
                .font(.system(
                    size: adaptiveFontSize,
                    weight: bannerStyle.isBold ? .bold : .regular
                ))
                .foregroundColor(bannerStyle.textColor)
                .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, adaptivePadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startParticlesAnimation()
        }
    }

    // MARK: - LED像素文本视图
    private var ledTextView: some View {
        ZStack {
            // LED点阵背景
            Canvas { context, size in
                let config = effectiveLedConfig
                let dotSpacing = config.dotSpacing
                let dotSize = config.dotSize
                let cols = Int(size.width / dotSpacing)
                let rows = Int(size.height / dotSpacing)

                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * dotSpacing
                        let y = CGFloat(row) * dotSpacing
                        let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)

                        // 计算LED亮度（基于相位产生闪烁效果）
                        let flicker = config.flickerEnabled ? sin(wavePhase + CGFloat(row + col) * 0.1) : 0
                        let brightness = 0.1 + config.glowIntensity * 0.2 * flicker
                        context.fill(
                            Ellipse().path(in: rect),
                            with: .color(bannerStyle.textColor.opacity(brightness))
                        )
                    }
                }
            }

            // LED风格的文字
            Text(displayText)
                .font(.system(
                    size: adaptiveFontSize,
                    weight: bannerStyle.isBold ? .heavy : .bold,
                    design: .monospaced
                ))
                .foregroundColor(bannerStyle.textColor)
                .shadow(color: bannerStyle.textColor, radius: 5, x: 0, y: 0)
                .shadow(color: bannerStyle.textColor.opacity(0.7), radius: 10, x: 0, y: 0)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, adaptivePadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bannerStyle.backgroundColor)
        .onAppear {
            withAnimation(.linear(duration: 3.0 / bannerStyle.animationSpeed).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
    
    // MARK: - 辅助函数
    /// 获取背景图片URL
    private func getImageURL() -> URL? {
        guard let imagePath = bannerStyle.backgroundImagePath else { return nil }
        
        // 获取Documents目录
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsPath.appendingPathComponent(imagePath)
        
        // 检查文件是否存在
        if FileManager.default.fileExists(atPath: imageURL.path) {
            return imageURL
        }
        
        // 如果是内置资源，尝试从Bundle加载
        if let bundleURL = Bundle.main.url(forResource: imagePath.replacingOccurrences(of: ".jpg", with: "").replacingOccurrences(of: ".png", with: ""), withExtension: nil) {
            return bundleURL
        }
        
        return nil
    }
    
    // MARK: - 新动效控制方法
    /// 开始逐字显示动画
    private func startTypewriterAnimation() {
        // 先清理之前的定时器
        typewriterTimer?.invalidate()
        typewriterTimer = nil

        typewriterText = ""
        typewriterIndex = 0

        let interval = 0.1 / bannerStyle.animationSpeed // 根据动画速度调整间隔

        typewriterTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if typewriterIndex < displayText.count {
                let index = displayText.index(displayText.startIndex, offsetBy: typewriterIndex)
                typewriterText = String(displayText[...index])
                typewriterIndex += 1
            } else {
                // 完成后暂停一段时间，然后重新开始
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 / bannerStyle.animationSpeed) {
                    startTypewriterAnimation()
                }
                timer.invalidate()
            }
        }
    }
    
    /// 开始随机闪现动画
    private func startRandomFlashAnimation() {
        // 初始化多个闪现位置
        let flashCount = 5
        randomFlashPositions = []
        randomFlashOpacities = Array(repeating: 0.0, count: flashCount)
        
        // 生成随机位置
        for _ in 0..<flashCount {
            let x = CGFloat.random(in: 50...(screenSize.width - 50))
            let y = CGFloat.random(in: 100...(screenSize.height - 100))
            randomFlashPositions.append(CGPoint(x: x, y: y))
        }
        
        // 启动定时器，随机闪现
        randomFlashTimer = Timer.scheduledTimer(withTimeInterval: 0.3 / bannerStyle.animationSpeed, repeats: true) { _ in
            let randomIndex = Int.random(in: 0..<flashCount)

            // 边界检查，防止动画停止后数组被清空导致越界
            guard randomIndex < randomFlashOpacities.count else { return }

            // 闪现效果
            withAnimation(.easeInOut(duration: 0.5 / bannerStyle.animationSpeed)) {
                if randomIndex < randomFlashOpacities.count {
                    randomFlashOpacities[randomIndex] = 1.0
                }
            }

            // 淡出效果
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 / bannerStyle.animationSpeed) {
                withAnimation(.easeInOut(duration: 0.3 / bannerStyle.animationSpeed)) {
                    if randomIndex < randomFlashOpacities.count {
                        randomFlashOpacities[randomIndex] = 0.0
                    }
                }
            }

            // 随机更新位置
            if Bool.random() && randomIndex < randomFlashPositions.count {
                let x = CGFloat.random(in: 50...(screenSize.width - 50))
                let y = CGFloat.random(in: 100...(screenSize.height - 100))
                randomFlashPositions[randomIndex] = CGPoint(x: x, y: y)
            }
        }
    }
    
    // MARK: - 动画控制方法
    /// 开始动画
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true

        switch bannerStyle.animationType {
        case .scroll:
            // 计算滚动距离
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

            // 根据滚动方向设置偏移
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

    /// 停止动画
    private func stopAnimation() {
        // 停止打字机定时器
        typewriterTimer?.invalidate()
        typewriterTimer = nil

        // 停止随机闪现定时器
        randomFlashTimer?.invalidate()
        randomFlashTimer = nil

        // 停止粒子定时器
        particleTimer?.invalidate()
        particleTimer = nil

        // 重置动画状态
        typewriterText = ""
        typewriterIndex = 0
        randomFlashPositions = []
        randomFlashOpacities = []
        particles = []

        isAnimating = false
    }

    /// 开始弹跳动画
    private func startBounceAnimation() {
        let config = effectiveBounceConfig
        bounceScale = 1.0 - config.squashAmount
        bounceOffset = config.bounceHeight

        withAnimation(.spring(response: 0.5, dampingFraction: config.elasticity, blendDuration: 0.5).repeatForever(autoreverses: true)) {
            bounceScale = 1.0 + config.squashAmount
            bounceOffset = -config.bounceHeight
        }
    }

    /// 开始粒子动画
    private func startParticlesAnimation() {
        particles = []
        let config = effectiveParticlesConfig

        // 创建初始粒子
        for _ in 0..<config.particleCount {
            particles.append(createParticle())
        }

        // 定时更新粒子
        particleTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateParticles()
        }
    }

    /// 创建新粒子
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

    /// 更新粒子状态
    private func updateParticles() {
        for i in particles.indices {
            particles[i].y -= particles[i].speed
            particles[i].opacity -= 0.01
            particles[i].x += CGFloat.random(in: -0.5...0.5)

            // 重置消失的粒子
            if particles[i].opacity <= 0 || particles[i].y < -screenSize.height / 2 {
                particles[i] = createParticle()
            }
        }
    }

    // MARK: - 展示时间限制控制

    /// 开始展示计时器（仅免费用户）
    private func startDisplayTimer() {
        // 订阅用户无时间限制
        guard !isSubscribed else { return }

        remainingTime = SubscriptionManager.freeDisplayLimit

        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            remainingTime -= 1

            // 时间到了
            if remainingTime <= 0 {
                stopDisplayTimer()
                dismiss()

                // 通知父视图显示升级提示
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onTimeLimitReached?()
                }
            }
        }
    }

    /// 停止展示计时器
    private func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }
}

// MARK: - String扩展
extension String {
    /// 计算字符串在指定字体下的宽度
    #if os(iOS)
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    #elseif os(macOS)
    func widthOfString(usingFont font: NSFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    #endif
}

// MARK: - 粒子模型
/// 粒子动画中的单个粒子
struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var speed: CGFloat
    var opacity: Double
}

// MARK: - 字体样式修饰符
struct FontStyleModifier: ViewModifier {
    let fontStyle: FontStyle
    let textColor: Color

    func body(content: Content) -> some View {
        switch fontStyle {
        case .normal:
            content

        case .artistic:
            // 艺术字：渐变文字效果 + 立体阴影
            ZStack {
                // 底层阴影
                content
                    .foregroundColor(textColor.opacity(0.3))
                    .offset(x: 2, y: 2)
                // 渐变文字
                content
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, textColor, textColor.opacity(0.8), .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

        case .neon:
            // 霓虹灯效果：多层发光
            content
                .foregroundColor(textColor)
                .shadow(color: textColor.opacity(0.5), radius: 1, x: 0, y: 0)
                .shadow(color: textColor.opacity(0.6), radius: 3, x: 0, y: 0)
                .shadow(color: textColor.opacity(0.7), radius: 6, x: 0, y: 0)
                .shadow(color: textColor.opacity(0.8), radius: 12, x: 0, y: 0)
                .shadow(color: textColor, radius: 20, x: 0, y: 0)
        }
    }
}

// MARK: - 艺术字风格修饰符
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

    // MARK: - 材质类风格

    @ViewBuilder
    private func metallicStyle(_ content: Content) -> some View {
        ZStack {
            // 底层阴影
            content
                .foregroundColor(.black.opacity(0.3))
                .offset(x: 2, y: 2)
            // 金属渐变
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

    // MARK: - 氛围类风格

    @ViewBuilder
    private func fireStyle(_ content: Content) -> some View {
        ZStack {
            // 火焰光晕
            content
                .foregroundColor(.orange.opacity(0.5))
                .blur(radius: 4)
            // 主体渐变
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
            // 冰霜光晕
            content
                .foregroundColor(.cyan.opacity(0.3))
                .blur(radius: 3)
            // 主体渐变
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

    // MARK: - 风格类

    @ViewBuilder
    private func retroStyle(_ content: Content) -> some View {
        ZStack {
            // 复古阴影
            content
                .foregroundColor(.brown.opacity(0.4))
                .offset(x: 3, y: 3)
            // 主体
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
            // 粗描边
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
            // 主体
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
            // 墨迹阴影
            content
                .foregroundColor(.black.opacity(0.2))
                .offset(x: 1, y: 1)
                .blur(radius: 1)
            // 主体
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

    // MARK: - 自定义风格

    /// 将角度转换为 UnitPoint
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
            // 描边层
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

            // 主内容
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

// MARK: - 霓虹字风格修饰符
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

    // MARK: - 基础类风格

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

    // MARK: - 动态类风格

    @ViewBuilder
    private func pulseNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.3), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.6), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
            // 注意：脉冲动画需要在 View 外部使用 animation modifier
    }

    @ViewBuilder
    private func flickerNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.6 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.9 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
            // 注意：闪烁动画需要在 View 外部使用 animation modifier
    }

    @ViewBuilder
    private func breathingNeon(_ content: Content) -> some View {
        content
            .foregroundColor(neonConfig.glowColor)
            .shadow(color: neonConfig.glowColor.opacity(0.4 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.4), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.8), x: 0, y: 0)
            .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
            // 注意：呼吸动画需要在 View 外部使用 animation modifier
    }

    // MARK: - 特效类风格

    @ViewBuilder
    private func glitchNeon(_ content: Content) -> some View {
        ZStack {
            // 红色偏移层
            content
                .foregroundColor(.red.opacity(0.7))
                .offset(x: CGFloat(neonConfig.glitchIntensity * 3), y: 0)

            // 青色偏移层
            content
                .foregroundColor(.cyan.opacity(0.7))
                .offset(x: CGFloat(-neonConfig.glitchIntensity * 3), y: 0)

            // 主发光层
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

    // MARK: - 高级类风格

    @ViewBuilder
    private func cyberpunkNeon(_ content: Content) -> some View {
        ZStack {
            // 外层紫色发光
            content
                .foregroundColor(.purple.opacity(0.3))
                .shadow(color: .purple.opacity(0.8 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 1.5), x: 0, y: 0)

            // 中层青色发光
            content
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.6 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)

            // 内层粉色发光
            content
                .foregroundColor(.pink)
                .shadow(color: .pink.opacity(0.4 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)
        }
    }

    @ViewBuilder
    private func retroNeon(_ content: Content) -> some View {
        ZStack {
            // 暗红色底层
            content
                .foregroundColor(.red.opacity(0.3))
                .offset(x: 2, y: 2)

            // 橙色中间层
            content
                .foregroundColor(.orange.opacity(0.6))
                .shadow(color: .orange.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.5), x: 0, y: 0)

            // 黄色主层
            content
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.8 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
        }
    }

    // MARK: - 自定义风格

    @ViewBuilder
    private func customNeon(_ content: Content) -> some View {
        if let gradientEnd = neonConfig.gradientEndColor {
            // 渐变效果
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
            // 多层发光
            content
                .foregroundColor(neonConfig.glowColor)
                .shadow(color: neonConfig.glowColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.3), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.6), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
                .shadow(color: secondaryColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.secondaryGlowRadius * 0.5), x: 0, y: 0)
                .shadow(color: secondaryColor.opacity(0.3 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.secondaryGlowRadius), x: 0, y: 0)
        } else {
            // 基础发光
            content
                .foregroundColor(neonConfig.glowColor)
                .shadow(color: neonConfig.glowColor.opacity(0.5 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.3), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(0.7 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius * 0.6), x: 0, y: 0)
                .shadow(color: neonConfig.glowColor.opacity(1.0 * neonConfig.glowIntensity), radius: CGFloat(neonConfig.glowRadius), x: 0, y: 0)
        }
    }
}

// MARK: - 预览
struct BannerDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 静态预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "🎉 欢迎使用 iBanner 🎉",
                    fontSize: 48,
                    textColor: .white,
                    backgroundColor: .blue,
                    animationType: .none
                )
            )
            .previewDisplayName("静态显示")
            
            // 滚动预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "📱 滚动横幅效果展示",
                    fontSize: 52,
                    textColor: .yellow,
                    backgroundColor: .black,
                    animationType: .scroll,
                    animationSpeed: 1.0
                )
            )
            .previewDisplayName("滚动效果")
            
            // 闪烁预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "✨ 闪烁灯牌效果 ✨",
                    fontSize: 56,
                    textColor: .white,
                    backgroundColor: .red,
                    animationType: .blink,
                    animationSpeed: 1.5,
                    isBold: true
                )
            )
            .previewDisplayName("闪烁效果")
            
            // 呼吸灯预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "💫 呼吸灯效果",
                    fontSize: 50,
                    textColor: .white,
                    backgroundColor: .purple,
                    animationType: .breathing,
                    animationSpeed: 0.8
                )
            )
            .previewDisplayName("呼吸灯效果")
            
            // 渐变背景预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "🌈 彩虹渐变背景",
                    fontSize: 48,
                    textColor: .white,
                    backgroundColor: .clear,
                    animationType: .gradient,
                    animationSpeed: 1.2,
                    isBold: true
                )
            )
            .previewDisplayName("渐变背景")
        }
    }
}