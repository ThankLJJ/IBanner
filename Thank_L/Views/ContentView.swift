//
//  ContentView.swift
//  iBanner
//
//  Created by L on 2024/7/12.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// 主界面 - 极简现代设计
struct ContentView: View {
    // MARK: - 状态
    @StateObject private var dataManager = BannerDataManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var bannerStyle = BannerStyle(
        text: "",
        fontSize: 48,
        textColor: .white,
        backgroundColor: .black,
        animationType: .scroll,
        animationSpeed: 1.0,
        isBold: true
    )

    @State private var showingBanner = false
    @State private var showingSettings = false
    @State private var showingTemplates = false
    @State private var showingHistory = false
    @State private var showingSubscription = false
    @State private var showingPremiumUpgrade = false
    @FocusState private var isInputFocused: Bool

    // 预览动画
    @State private var animOffset: CGFloat = 0
    @State private var animPhase: CGFloat = 0
    @State private var animOpacity: Double = 1.0
    @State private var animScale: CGFloat = 1.0
    @State private var typewriterText: String = ""
    @State private var typewriterIndex: Int = 0
    @State private var flashOpacities: [Double] = Array(repeating: 0, count: 3)
    @State private var particles: [ParticleData] = []
    @State private var ledPhase: CGFloat = 0
    @State private var animationTimer: Timer?
    @State private var flashTimer: Timer?
    @State private var typewriterTimer: Timer?

    var body: some View {
        NavigationStack {
            ZStack {
                // 纯净背景
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // 预览区
                        previewArea

                        // 输入区
                        inputArea

                        // 快捷操作
                        quickActions

                        // 开始按钮
                        startButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    isInputFocused = false
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(L10n.App.name)
                        .font(.system(size: 18, weight: .semibold))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        if !subscriptionManager.isSubscribed {
                            Button { showingSubscription = true } label: {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.yellow)
                            }
                        }

                        Button { showingHistory = true } label: {
                            Image(systemName: "clock")
                                .font(.system(size: 17))
                                .foregroundStyle(.primary)
                        }

                        Button { showingSettings = true } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 17))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingBanner) {
            BannerDisplayView(
                bannerStyle: bannerStyle,
                isSubscribed: subscriptionManager.isSubscribed,
                onTimeLimitReached: {
                    // 免费用户30秒后显示升级提示
                    showingPremiumUpgrade = true
                }
            )
        }
        .sheet(isPresented: $showingSettings) {
            StyleSettingsView(bannerStyle: $bannerStyle)
        }
        .sheet(isPresented: $showingTemplates) {
            TemplateView(bannerStyle: $bannerStyle)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(bannerStyle: $bannerStyle)
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        .sheet(isPresented: $showingPremiumUpgrade) {
            PremiumUpgradeSheet.forUnlimitedDisplay {}
        }
        .onAppear {
            loadStyle()
            Task { await subscriptionManager.checkSubscriptionStatus() }
        }
    }

    // MARK: - 预览区
    private var previewArea: some View {
        ZStack {
            // 背景
            bannerStyle.backgroundColor

            // 渐变动画
            if bannerStyle.animationType == .gradient {
                gradientOverlay
            }

            // 背景图
            if bannerStyle.backgroundType == .image,
               let path = bannerStyle.backgroundImagePath,
               let url = URL(string: "file://" + path) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase {
                        img.resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(bannerStyle.backgroundImageOpacity)
                    }
                }
            }

            // 文字
            animatedText
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        .onAppear { startAnimation() }
        .onChange(of: bannerStyle.animationType) { _, _ in restartAnimation() }
        .onChange(of: bannerStyle.animationSpeed) { _, _ in restartAnimation() }
        .onTapGesture { showingSettings = true }
    }

    // MARK: - 渐变叠加
    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.red, .orange, .yellow, .green, .blue, .purple],
            startPoint: .leading,
            endPoint: .trailing
        )
        .offset(x: animOffset)
        .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: animOffset)
    }

    // MARK: - 动画文字
    @ViewBuilder
    private var animatedText: some View {
        let text = bannerStyle.text.isEmpty ? "输入文字开始" : bannerStyle.text

        switch bannerStyle.animationType {
        case .scroll:
            HStack(spacing: 80) {
                textView(text)
                textView(text)
            }
            .offset(x: animOffset)
            .animation(.linear(duration: 5).repeatForever(autoreverses: false), value: animOffset)

        case .blink:
            textView(text)
                .opacity(animOpacity)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animOpacity)

        case .breathing:
            textView(text)
                .opacity(animOpacity)
                .scaleEffect(animScale)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animOpacity)

        case .wave:
            HStack(spacing: 0) {
                ForEach(Array(text.enumerated()), id: \.offset) { i, c in
                    Text(String(c))
                        .font(font())
                        .foregroundStyle(bannerStyle.textColor)
                        .offset(y: sin(animPhase + CGFloat(i) * 0.5) * 10)
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 2 / bannerStyle.animationSpeed).repeatForever(autoreverses: false)) {
                    animPhase = .pi * 2
                }
            }

        case .bounce:
            textView(text)
                .scaleEffect(animScale)
                .animation(.spring(response: 0.4, dampingFraction: 0.4).repeatForever(autoreverses: true), value: animScale)

        case .typewriter:
            Text(typewriterText.isEmpty ? String(text.prefix(1)) : typewriterText)
                .font(font())
                .foregroundStyle(bannerStyle.textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 24)
                .onAppear { startTypewriterAnimation() }

        case .randomFlash:
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    textView(text)
                        .opacity(flashOpacities[i])
                        .scaleEffect(0.8 + flashOpacities[i] * 0.2)
                }
            }
            .onAppear { startRandomFlashAnimation() }

        case .particles:
            ZStack {
                // 粒子层
                ForEach(particles) { p in
                    Circle()
                        .fill(bannerStyle.textColor.opacity(p.opacity))
                        .frame(width: p.size, height: p.size)
                        .offset(x: p.x, y: p.y)
                }
                // 文字
                textView(text)
            }
            .onAppear { startParticlesAnimation() }

        case .led:
            ZStack {
                // LED 背景点阵
                Canvas { context, size in
                    let dotSpacing: CGFloat = 8
                    let dotSize: CGFloat = 3
                    let cols = Int(size.width / dotSpacing)
                    let rows = Int(size.height / dotSpacing)

                    for row in 0..<rows {
                        for col in 0..<cols {
                            let x = CGFloat(col) * dotSpacing
                            let y = CGFloat(row) * dotSpacing
                            let brightness = 0.1 + 0.15 * sin(ledPhase + CGFloat(row + col) * 0.15)
                            var path = Path()
                            path.addEllipse(in: CGRect(x: x, y: y, width: dotSize, height: dotSize))
                            context.fill(path, with: .color(bannerStyle.textColor.opacity(brightness)))
                        }
                    }
                }

                // LED 风格文字
                textView(text)
                    .font(.system(size: min(bannerStyle.fontSize * 0.3, 22), weight: .heavy, design: .monospaced))
                    .shadow(color: bannerStyle.textColor, radius: 3, x: 0, y: 0)
            }
            .onAppear {
                withAnimation(.linear(duration: 3 / bannerStyle.animationSpeed).repeatForever(autoreverses: false)) {
                    ledPhase = .pi * 2
                }
            }

        default:
            textView(text)
        }
    }

    private func textView(_ text: String) -> some View {
        Text(text)
            .font(font())
            .foregroundStyle(bannerStyle.textColor)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.horizontal, 24)
    }

    private func font() -> Font {
        .system(
            size: min(bannerStyle.fontSize * 0.3, 22),
            weight: bannerStyle.isBold ? .bold : .regular
        )
    }

    // MARK: - 输入区
    private var inputArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Content.content)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            TextEditor(text: $bannerStyle.text)
                .font(.system(size: 17))
                .frame(height: 100)
                .padding(2)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .focused($isInputFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isInputFocused ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 2)
                )
                .overlay(alignment: .topLeading) {
                    if bannerStyle.text.isEmpty {
                        Text(L10n.Content.inputPlaceholder)
                            .font(.system(size: 17))
                            .foregroundStyle(.tertiary)
                            .padding(16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - 快捷操作
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 颜色选择
            Text(L10n.QuickSettings.color)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    colorChip(L10n.ColorTheme.classic, .white, .black)
                    colorChip(L10n.ColorTheme.support, .white, .red)
                    colorChip(L10n.ColorTheme.birthday, .white, .pink)
                    colorChip(L10n.ColorTheme.pickup, .black, .white)
                    colorChip(L10n.ColorTheme.driver, .white, .green)
                    colorChip(L10n.ColorTheme.thanks, .white, .orange)
                }
            }

            // 动画选择
            Text(L10n.QuickSettings.animation)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AnimationType.allCases, id: \.self) { anim in
                        animChip(anim)
                    }
                }
            }
        }
    }

    private func colorChip(_ name: String, _ fg: Color, _ bg: Color) -> some View {
        Button {
            bannerStyle.textColor = fg
            bannerStyle.backgroundColor = bg
        } label: {
            VStack(spacing: 6) {
                Circle()
                    .fill(bg)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(.gray.opacity(0.2), lineWidth: 1))
                    .overlay(Text("A").font(.caption.weight(.semibold)).foregroundStyle(fg))
                Text(name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private func animChip(_ anim: AnimationType) -> some View {
        Button {
            // 检查是否为高级动效
            if anim.isPremium && !subscriptionManager.isSubscribed {
                // 显示升级提示，不设置样式
                showingPremiumUpgrade = true
                return
            }
            // 只有免费功能或已订阅才设置样式
            bannerStyle.animationType = anim
        } label: {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(bannerStyle.animationType == anim ? Color.accentColor : Color(.secondarySystemBackground))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: animIcon(anim))
                                .font(.system(size: 14))
                                .foregroundStyle(bannerStyle.animationType == anim ? .white : .secondary)
                        )

                    // 高级标识
                    if anim.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                            .offset(x: 2, y: -2)
                    }
                }

                Text(anim.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    private func animIcon(_ anim: AnimationType) -> String {
        switch anim {
        case .none: return "circle"
        case .scroll: return "arrow.left.arrow.right"
        case .blink: return "lightbulb"
        case .gradient: return "paintpalette"
        case .breathing: return "heart"
        case .typewriter: return "keyboard"
        case .randomFlash: return "sparkles"
        case .wave: return "water.waves"
        case .bounce: return "arrow.up"
        case .particles: return "snowflake"
        case .led: return "grid"
        }
    }

    // MARK: - 开始按钮
    private var startButton: some View {
        Button {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            dataManager.addHistory(bannerStyle)
            saveStyle()
            showingBanner = true
        } label: {
            Text(L10n.Content.showBanner)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    bannerStyle.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.gray
                        : Color.accentColor
                )
                .cornerRadius(16)
        }
        .disabled(bannerStyle.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // MARK: - 动画控制
    private func startAnimation() {
        stopAllTimers()

        switch bannerStyle.animationType {
        case .scroll:
            withAnimation(.linear(duration: 5 / bannerStyle.animationSpeed).repeatForever(autoreverses: false)) {
                animOffset = -200
            }
        case .blink:
            withAnimation(.easeInOut(duration: 0.6 / bannerStyle.animationSpeed).repeatForever(autoreverses: true)) {
                animOpacity = 0.3
            }
        case .breathing:
            withAnimation(.easeInOut(duration: 1.5 / bannerStyle.animationSpeed).repeatForever(autoreverses: true)) {
                animOpacity = 0.5
                animScale = 0.9
            }
        case .gradient:
            withAnimation(.linear(duration: 3 / bannerStyle.animationSpeed).repeatForever(autoreverses: false)) {
                animOffset = -300
            }
        case .bounce:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.4).repeatForever(autoreverses: true)) {
                animScale = 1.1
            }
        case .typewriter:
            startTypewriterAnimation()
        case .randomFlash:
            startRandomFlashAnimation()
        case .particles:
            startParticlesAnimation()
        default:
            break
        }
    }

    private func stopAllTimers() {
        animationTimer?.invalidate()
        animationTimer = nil
        flashTimer?.invalidate()
        flashTimer = nil
        typewriterTimer?.invalidate()
        typewriterTimer = nil
    }

    // MARK: - 逐字显示动画
    private func startTypewriterAnimation() {
        let text = bannerStyle.text.isEmpty ? "输入文字开始" : bannerStyle.text
        typewriterText = ""
        typewriterIndex = 0

        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.1 / bannerStyle.animationSpeed, repeats: true) { _ in
            if typewriterIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: typewriterIndex)
                typewriterText = String(text[...index])
                typewriterIndex += 1
            } else {
                typewriterTimer?.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / bannerStyle.animationSpeed) {
                    startTypewriterAnimation()
                }
            }
        }
    }

    // MARK: - 随机闪现动画
    private func startRandomFlashAnimation() {
        flashOpacities = [1.0, 0.0, 0.0]

        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.4 / bannerStyle.animationSpeed, repeats: true) { _ in
            let idx = Int.random(in: 0..<3)
            for i in 0..<3 {
                flashOpacities[i] = i == idx ? 1.0 : 0.0
            }
        }
    }

    // MARK: - 粒子动画
    private func startParticlesAnimation() {
        particles = (0..<15).map { _ in
            ParticleData(
                x: CGFloat.random(in: -80...80),
                y: CGFloat.random(in: -40...40),
                opacity: Double.random(in: 0.3...1.0),
                size: CGFloat.random(in: 2...5)
            )
        }

        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            for i in particles.indices {
                particles[i].y -= CGFloat.random(in: 0.5...1.5)
                particles[i].opacity -= 0.02

                if particles[i].opacity <= 0 {
                    particles[i] = ParticleData(
                        x: CGFloat.random(in: -80...80),
                        y: 40,
                        opacity: 1.0,
                        size: CGFloat.random(in: 2...5)
                    )
                }
            }
        }
    }

    private func restartAnimation() {
        animOffset = 0
        animPhase = 0
        animOpacity = 1.0
        animScale = 1.0
        typewriterText = ""
        typewriterIndex = 0
        flashOpacities = [0, 0, 0]
        particles = []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { startAnimation() }
    }

    // MARK: - 数据
    private func loadStyle() {
        if let data = UserDefaults.standard.data(forKey: "LastUsedStyle"),
           let style = try? JSONDecoder().decode(BannerStyle.self, from: data) {
            bannerStyle = style
            bannerStyle.text = ""
        }
    }

    private func saveStyle() {
        if let data = try? JSONEncoder().encode(bannerStyle) {
            UserDefaults.standard.set(data, forKey: "LastUsedStyle")
        }
    }
}

// MARK: - 粒子数据
struct ParticleData: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    var size: CGFloat
}

#Preview {
    ContentView()
}
