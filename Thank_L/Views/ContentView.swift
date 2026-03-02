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

/// 主界面 - 极简现代设计，集成所有设置功能
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
    @State private var showingTemplates = false
    @State private var showingHistory = false
    @State private var showingSubscription = false
    @State private var showingPremiumUpgrade = false
    @FocusState private var isInputFocused: Bool

    // 图片选择器状态
    @State private var showingImagePicker = false
    @State private var selectedImage: Image? = nil
    #if os(iOS)
    @State private var selectedUIImage: UIImage?
    @State private var imagePickerCoordinator: ImagePickerCoordinator?
    #elseif os(macOS)
    @State private var selectedNSImage: NSImage?
    #endif

    // 高级功能提示状态
    @State private var premiumFeatureName = ""
    @State private var premiumFeatureDescription: String? = nil

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

    // 预设颜色
    private let presetColors: [Color] = [
        .white, .black, .red, .orange, .yellow, .green,
        .blue, .purple, .pink, .brown, .gray, .cyan
    ]

    // MARK: - 颜色选择器类型
    enum ColorPickerType {
        case text, background
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 纯净背景
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 固定预览区
                    previewArea
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    // 可滚动的设置区域
                    ScrollView {
                        VStack(spacing: 16) {
                            // 输入区
                            inputArea

                            // 文字设置
                            textSettingsSection

                            // 颜色设置
                            colorSettingsSection

                            // 动画设置
                            animationSettingsSection

                            // 背景设置
                            backgroundSettingsSection

                            // 预设样式
                            presetStylesSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 32)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onTapGesture {
                        isInputFocused = false
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(L10n.App.name)
                        .font(.system(size: 18, weight: .semibold))
                }

                // 开始展示按钮
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        #if os(iOS)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        #endif
                        // 只有输入了文字才保存到历史记录
                        if !bannerStyle.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            dataManager.addHistory(bannerStyle)
                        }
                        saveStyle()
                        showingBanner = true
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
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

                        Button { showingTemplates = true } label: {
                            Image(systemName: "square.grid.2x2")
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
                    showingPremiumUpgrade = true
                }
            )
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
        .sheet(isPresented: $showingImagePicker) {
            imagePickerSheet
        }
        .sheet(isPresented: $showingPremiumUpgrade) {
            PremiumUpgradeSheet(
                featureName: premiumFeatureName,
                featureDescription: premiumFeatureDescription,
                onDismiss: {}
            )
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
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
        .onAppear { startAnimation() }
        .onChange(of: bannerStyle.animationType) { _, _ in restartAnimation() }
        .onChange(of: bannerStyle.animationSpeed) { _, _ in restartAnimation() }
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
        let text = bannerStyle.text.isEmpty ? L10n.Content.previewText : bannerStyle.text

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
                ForEach(particles) { p in
                    Circle()
                        .fill(bannerStyle.textColor.opacity(p.opacity))
                        .frame(width: p.size, height: p.size)
                        .offset(x: p.x, y: p.y)
                }
                textView(text)
            }
            .onAppear { startParticlesAnimation() }

        case .led:
            ZStack {
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
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Content.content)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            TextEditor(text: $bannerStyle.text)
                .font(.system(size: 16))
                .frame(height: 80)
                .padding(2)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
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

    // MARK: - 文字设置区域
    private var textSettingsSection: some View {
        VStack(spacing: 12) {
            // 字体大小
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(L10n.StyleSettings.fontSize)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(bannerStyle.fontSize))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Slider(value: $bannerStyle.fontSize, in: 20...100, step: 2)
            }

            Divider()

            // 粗体开关
            HStack {
                Text(L10n.StyleSettings.bold)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Toggle("", isOn: $bannerStyle.isBold)
                    .labelsHidden()
            }

            Divider()

            // 字体样式
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.StyleSettings.fontStyle)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    ForEach(FontStyle.allCases, id: \.self) { style in
                        fontStyleButton(style)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func fontStyleButton(_ style: FontStyle) -> some View {
        Button {
            if style.isPremium && !subscriptionManager.isSubscribed {
                premiumFeatureName = style.displayName
                premiumFeatureDescription = style.description
                showingPremiumUpgrade = true
                return
            }
            bannerStyle.fontStyle = style
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    Text(style.displayName)
                        .font(.caption)
                        .fontWeight(.medium)

                    if style.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(bannerStyle.fontStyle == style ? Color.accentColor : Color(.tertiarySystemBackground))
            )
            .foregroundColor(bannerStyle.fontStyle == style ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 颜色设置区域
    private var colorSettingsSection: some View {
        VStack(spacing: 12) {
            // 文字颜色
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.StyleSettings.textColor)
                    .font(.subheadline)
                    .fontWeight(.medium)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presetColors, id: \.self) { color in
                            colorButton(color: color, isSelected: bannerStyle.textColor == color) {
                                bannerStyle.textColor = color
                            }
                        }
                        customColorButton(for: .text)
                    }
                }
            }

            Divider()

            // 背景颜色
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.StyleSettings.backgroundColor)
                    .font(.subheadline)
                    .fontWeight(.medium)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presetColors, id: \.self) { color in
                            colorButton(color: color, isSelected: bannerStyle.backgroundColor == color) {
                                bannerStyle.backgroundColor = color
                            }
                        }
                        customColorButton(for: .background)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func colorButton(color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
                .overlay(
                    color == .white ?
                    Circle().stroke(Color.gray.opacity(0.4), lineWidth: 0.5) : nil
                )
        }
    }

    private func customColorButton(for type: ColorPickerType) -> some View {
        Menu {
            ColorPicker("", selection: type == .text ? $bannerStyle.textColor : $bannerStyle.backgroundColor, supportsOpacity: false)
                .labelsHidden()
        } label: {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 28, height: 28)
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                )
        }
    }

    // MARK: - 动画设置区域
    private var animationSettingsSection: some View {
        VStack(spacing: 12) {
            // 动画类型
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.StyleSettings.animationType)
                    .font(.subheadline)
                    .fontWeight(.medium)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(AnimationType.allCases, id: \.self) { anim in
                            animChip(anim)
                        }
                    }
                }
            }

            // 动画速度
            if bannerStyle.animationType != .none {
                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(L10n.StyleSettings.animationSpeed)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text(String(format: "%.1fx", bannerStyle.animationSpeed))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $bannerStyle.animationSpeed, in: 0.5...3.0, step: 0.1)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func animChip(_ anim: AnimationType) -> some View {
        Button {
            if anim.isPremium && !subscriptionManager.isSubscribed {
                showingPremiumUpgrade = true
                return
            }
            bannerStyle.animationType = anim
        } label: {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(bannerStyle.animationType == anim ? Color.accentColor : Color(.tertiarySystemBackground))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: animIcon(anim))
                                .font(.system(size: 11))
                                .foregroundStyle(bannerStyle.animationType == anim ? .white : .secondary)
                        )

                    if anim.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.orange)
                            .offset(x: 1, y: -1)
                    }
                }

                Text(anim.displayName)
                    .font(.system(size: 9))
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

    // MARK: - 背景设置区域
    private var backgroundSettingsSection: some View {
        VStack(spacing: 12) {
            // 背景类型
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.StyleSettings.backgroundType)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    ForEach(BackgroundType.allCases, id: \.self) { type in
                        backgroundTypeButton(type)
                    }
                }
            }

            // 图片背景设置
            if bannerStyle.backgroundType == .image {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.StyleSettings.backgroundImage)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Button {
                        if !subscriptionManager.isSubscribed {
                            premiumFeatureName = L10n.StyleSettings.imageBackground
                            premiumFeatureDescription = L10n.PremiumFeature.backgroundImagesDesc
                            showingPremiumUpgrade = true
                            return
                        }
                        showingImagePicker = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.tertiarySystemBackground))
                                .frame(height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.accentColor.opacity(0.5), lineWidth: 1, antialiased: true)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 2]))
                                                .foregroundColor(Color.accentColor.opacity(0.3))
                                        )
                                )

                            if !subscriptionManager.isSubscribed {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 8))
                                            .foregroundColor(.orange)
                                            .padding(4)
                                    }
                                    Spacer()
                                }
                            }

                            if let imagePath = bannerStyle.backgroundImagePath,
                               let url = URL(string: "file://" + imagePath) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 60)
                                            .clipped()
                                            .cornerRadius(10)
                                    default:
                                        HStack(spacing: 6) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 16))
                                                .foregroundColor(.accentColor)
                                            Text(L10n.App.loading)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 18))
                                        .foregroundColor(.accentColor)
                                    Text(L10n.StyleSettings.selectImage)
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    // 已选图片
                    if let imagePath = bannerStyle.backgroundImagePath, !imagePath.isEmpty {
                        HStack {
                            Text(URL(fileURLWithPath: imagePath).lastPathComponent)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)

                            Spacer()

                            Button(L10n.App.remove) {
                                BannerDataManager.shared.deleteBackgroundImage(at: imagePath)
                                bannerStyle.backgroundImagePath = nil
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.red)
                            .font(.caption2)
                        }
                    }

                    // 图片透明度
                    if bannerStyle.backgroundImagePath != nil {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(L10n.StyleSettings.imageOpacity)
                                    .font(.caption2)
                                Spacer()
                                Text("\(Int(bannerStyle.backgroundImageOpacity * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Slider(value: $bannerStyle.backgroundImageOpacity, in: 0.1...1.0, step: 0.1)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func backgroundTypeButton(_ type: BackgroundType) -> some View {
        Button {
            bannerStyle.backgroundType = type
            if type == .color {
                bannerStyle.backgroundImagePath = nil
            }
        } label: {
            Text(type.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(bannerStyle.backgroundType == type ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(bannerStyle.backgroundType == type ? Color.accentColor : Color(.tertiarySystemBackground))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 预设样式区域
    private var presetStylesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.StyleSettings.presetStyles)
                .font(.subheadline)
                .fontWeight(.medium)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    presetStyleChip(L10n.PresetStyle.concert, .red, .white, .blink)
                    presetStyleChip(L10n.PresetStyle.birthday, .pink, .white, .gradient)
                    presetStyleChip(L10n.PresetStyle.pickup, .white, .black, .none)
                    presetStyleChip(L10n.PresetStyle.driver, .blue, .white, .breathing)
                    presetStyleChip(L10n.PresetStyle.thanks, .green, .white, .none)
                    presetStyleChip(L10n.PresetStyle.wait, .yellow, .black, .blink)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func presetStyleChip(_ name: String, _ bgColor: Color, _ textColor: Color, _ animation: AnimationType) -> some View {
        Button {
            bannerStyle.backgroundColor = bgColor
            bannerStyle.textColor = textColor
            bannerStyle.animationType = animation
            bannerStyle.fontSize = 48
            bannerStyle.isBold = true
            bannerStyle.animationSpeed = 1.0
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(bgColor)
                        .frame(width: 50, height: 32)

                    Text(String(name.prefix(2)))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(textColor)
                }

                Text(name)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
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

    // MARK: - 图片选择器
    private var imagePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(L10n.StyleSettings.selectBackgroundImage)
                    .font(.headline)

                #if os(iOS)
                Button(L10n.StyleSettings.selectFromAlbum) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        imagePickerCoordinator = ImagePickerCoordinator { image in
                            selectedUIImage = image
                            selectedImage = Image(uiImage: image)

                            if let savedPath = BannerDataManager.shared.saveBackgroundImage(image) {
                                bannerStyle.backgroundImagePath = savedPath
                            }

                            showingImagePicker = false
                        }

                        let imagePicker = UIImagePickerController()
                        imagePicker.sourceType = .photoLibrary
                        imagePicker.delegate = imagePickerCoordinator

                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            var topController = window.rootViewController
                            while let presentedController = topController?.presentedViewController {
                                topController = presentedController
                            }
                            topController?.present(imagePicker, animated: true)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                #elseif os(macOS)
                Button(L10n.StyleSettings.selectFromFile) {
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.image]
                    panel.allowsMultipleSelection = false

                    if panel.runModal() == .OK,
                       let url = panel.url,
                       let image = NSImage(contentsOf: url) {
                        selectedNSImage = image
                        selectedImage = Image(nsImage: image)

                        if let savedPath = BannerDataManager.shared.saveBackgroundImage(image) {
                            bannerStyle.backgroundImagePath = savedPath
                        }

                        showingImagePicker = false
                    }
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                #endif

                if selectedImage != nil {
                    Button(L10n.StyleSettings.removeBackgroundImage) {
                        selectedImage = nil
                        #if os(iOS)
                        selectedUIImage = nil
                        #elseif os(macOS)
                        selectedNSImage = nil
                        #endif

                        if let imagePath = bannerStyle.backgroundImagePath {
                            BannerDataManager.shared.deleteBackgroundImage(at: imagePath)
                        }
                        bannerStyle.backgroundImagePath = nil
                        showingImagePicker = false
                    }
                    .foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.App.done) {
                        showingImagePicker = false
                    }
                }
            }
        }
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

    private func startTypewriterAnimation() {
        let text = bannerStyle.text.isEmpty ? L10n.Content.previewText : bannerStyle.text
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

    private func startRandomFlashAnimation() {
        flashOpacities = [1.0, 0.0, 0.0]

        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.4 / bannerStyle.animationSpeed, repeats: true) { _ in
            let idx = Int.random(in: 0..<3)
            for i in 0..<3 {
                flashOpacities[i] = i == idx ? 1.0 : 0.0
            }
        }
    }

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
