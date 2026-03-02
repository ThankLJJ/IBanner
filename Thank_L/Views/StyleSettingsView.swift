//
//  StyleSettingsView.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if os(iOS)
// MARK: - ImagePickerCoordinator
class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let onImagePicked: (UIImage) -> Void
    
    init(onImagePicked: @escaping (UIImage) -> Void) {
        self.onImagePicked = onImagePicked
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            onImagePicked(image)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
#endif

/// 样式设置页面
/// 提供字体、颜色、动效等完整的样式配置功能
struct StyleSettingsView: View {
    // MARK: - 绑定属性
    @Binding var bannerStyle: BannerStyle
    @Environment(\.dismiss) private var dismiss

    // MARK: - 订阅管理
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    // MARK: - 状态属性
    @State private var showingColorPicker = false
    @State private var colorPickerType: ColorPickerType = .text
    @State private var tempColor: Color = .white
    @State private var showingImagePicker = false
    @State private var selectedImage: Image? = nil
    #if os(macOS)
    @State private var showingTextColorPopover = false
    @State private var showingBgColorPopover = false
    #endif

    // MARK: - 升级提示状态
    @State private var showingPremiumUpgrade = false
    @State private var premiumFeatureName = ""
    @State private var premiumFeatureDescription: String? = nil

    // MARK: - 动画预览状态
    @State private var previewScrollOffset: CGFloat = 0
    @State private var previewIsBlinking: Bool = false
    @State private var previewBreathingOpacity: Double = 1.0
    @State private var previewWavePhase: CGFloat = 0
    @State private var previewBounceScale: CGFloat = 1.0
    @State private var previewIsAnimating: Bool = false
    @State private var previewGradientOffset: CGFloat = 0

    #if os(iOS)
    @State private var selectedUIImage: UIImage?
    @State private var imagePickerCoordinator: ImagePickerCoordinator?
    #elseif os(macOS)
    @State private var selectedNSImage: NSImage?
    #endif
    
    // MARK: - 预设颜色
    private let presetColors: [Color] = [
        .white, .black, .red, .orange, .yellow, .green,
        .blue, .purple, .pink, .brown, .gray, .cyan
    ]
    
    // MARK: - 颜色选择器类型
    enum ColorPickerType {
        case text, background
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 预览区域
                    previewSection
                    
                    // 文字设置区域
                    textSettingsSection
                    
                    // 颜色设置区域
                    colorSettingsSection
                    
                    // 背景设置区域
                    backgroundSettingsSection
                    
                    // 动画设置区域
                    animationSettingsSection
                    
                    // 预设样式区域
                    presetStylesSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .navigationTitle(L10n.Navigation.styleSettings)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.App.cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.App.done) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingColorPicker) {
            colorPickerSheet
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
    }
    
    // MARK: - 预览区域
    private var previewSection: some View {
        VStack(spacing: 12) {
            Text(L10n.Content.preview)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 预览容器
            ZStack {
                // 背景颜色层
                RoundedRectangle(cornerRadius: 12)
                    .fill(bannerStyle.backgroundColor)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                // 渐变动画背景
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

                // 背景图片（如果设置了）
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

                // 动画文字层
                previewAnimatedText
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onAppear {
                startPreviewAnimation()
            }
            .onDisappear {
                stopPreviewAnimation()
            }
            .onChange(of: bannerStyle.animationType) { _, _ in
                stopPreviewAnimation()
                startPreviewAnimation()
            }
            .onChange(of: bannerStyle.animationSpeed) { _, _ in
                stopPreviewAnimation()
                startPreviewAnimation()
            }
        }
    }

    // MARK: - 预览动画文字
    @ViewBuilder
    private var previewAnimatedText: some View {
        let previewText = bannerStyle.text.isEmpty ? L10n.Content.previewText : bannerStyle.text

        switch bannerStyle.animationType {
        case .scroll:
            // 滚动效果预览
            HStack(spacing: 0) {
                Text(previewText)
                    .font(.system(
                        size: min(bannerStyle.fontSize * 0.4, 24),
                        weight: bannerStyle.isBold ? .bold : .regular
                    ))
                    .foregroundColor(bannerStyle.textColor)
                    .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                    .fixedSize()

                Spacer().frame(width: 60)

                Text(previewText)
                    .font(.system(
                        size: min(bannerStyle.fontSize * 0.4, 24),
                        weight: bannerStyle.isBold ? .bold : .regular
                    ))
                    .foregroundColor(bannerStyle.textColor)
                    .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                    .fixedSize()
            }
            .offset(x: previewScrollOffset)
            .animation(
                .linear(duration: 4.0 / bannerStyle.animationSpeed)
                .repeatForever(autoreverses: false),
                value: previewScrollOffset
            )

        case .blink:
            // 闪烁效果预览
            Text(previewText)
                .font(.system(
                    size: min(bannerStyle.fontSize * 0.4, 24),
                    weight: bannerStyle.isBold ? .bold : .regular
                ))
                .foregroundColor(bannerStyle.textColor)
                .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 16)
                .opacity(previewIsBlinking ? 0.3 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8 / bannerStyle.animationSpeed)
                    .repeatForever(autoreverses: true),
                    value: previewIsBlinking
                )

        case .breathing:
            // 呼吸灯效果预览
            Text(previewText)
                .font(.system(
                    size: min(bannerStyle.fontSize * 0.4, 24),
                    weight: bannerStyle.isBold ? .bold : .regular
                ))
                .foregroundColor(bannerStyle.textColor)
                .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 16)
                .opacity(previewBreathingOpacity)
                .scaleEffect(0.8 + previewBreathingOpacity * 0.2)
                .animation(
                    .easeInOut(duration: 2.0 / bannerStyle.animationSpeed)
                    .repeatForever(autoreverses: true),
                    value: previewBreathingOpacity
                )

        case .wave:
            // 波浪效果预览
            HStack(spacing: 0) {
                ForEach(Array(previewText.enumerated()), id: \.offset) { index, char in
                    Text(String(char))
                        .font(.system(
                            size: min(bannerStyle.fontSize * 0.4, 24),
                            weight: bannerStyle.isBold ? .bold : .regular
                        ))
                        .foregroundColor(bannerStyle.textColor)
                        .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                        .offset(y: sin(previewWavePhase + CGFloat(index) * 0.5) * 8)
                }
            }
            .padding(.horizontal, 16)

        case .bounce:
            // 弹跳效果预览
            Text(previewText)
                .font(.system(
                    size: min(bannerStyle.fontSize * 0.4, 24),
                    weight: bannerStyle.isBold ? .bold : .regular
                ))
                .foregroundColor(bannerStyle.textColor)
                .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 16)
                .scaleEffect(previewBounceScale)
                .offset(y: (previewBounceScale - 1.0) * -20)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.3, blendDuration: 0.5)
                    .repeatForever(autoreverses: true),
                    value: previewBounceScale
                )

        default:
            // 静态显示（包括 none, typewriter, randomFlash, particles, led）
            Text(previewText)
                .font(.system(
                    size: min(bannerStyle.fontSize * 0.4, 24),
                    weight: bannerStyle.isBold ? .bold : .regular
                ))
                .foregroundColor(bannerStyle.textColor)
                .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 16)
        }
    }

    // MARK: - 预览动画控制
    private func startPreviewAnimation() {
        guard !previewIsAnimating else { return }
        previewIsAnimating = true

        switch bannerStyle.animationType {
        case .scroll:
            previewScrollOffset = -100
        case .blink:
            previewIsBlinking = true
        case .breathing:
            previewBreathingOpacity = 0.5
        case .gradient:
            previewGradientOffset = -200
        case .wave:
            withAnimation(.linear(duration: 2.0 / bannerStyle.animationSpeed).repeatForever(autoreverses: false)) {
                previewWavePhase = .pi * 2
            }
        case .bounce:
            previewBounceScale = 1.1
        default:
            break
        }
    }

    private func stopPreviewAnimation() {
        previewIsAnimating = false
        previewScrollOffset = 0
        previewIsBlinking = false
        previewBreathingOpacity = 1.0
        previewWavePhase = 0
        previewBounceScale = 1.0
        previewGradientOffset = 0
    }
    
    // MARK: - 文字设置区域
    private var textSettingsSection: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.textSettings)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 字体大小设置
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.fontSize)
                    Spacer()
                    Text("\(Int(bannerStyle.fontSize))")
                        .foregroundColor(.secondary)
                }

                Slider(
                    value: $bannerStyle.fontSize,
                    in: 20...100,
                    step: 2
                ) {
                    Text(L10n.StyleSettings.fontSize)
                } minimumValueLabel: {
                    Text("20")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("100")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 粗体开关
            HStack {
                Text(L10n.StyleSettings.bold)
                Spacer()
                Toggle("", isOn: $bannerStyle.isBold)
            }

            Divider()

            // 字体样式选择
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.fontStyle)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(FontStyle.allCases, id: \.self) { fontStyle in
                        fontStyleButton(fontStyle)
                    }
                }
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
    
    // MARK: - 颜色设置区域
    private var colorSettingsSection: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.colorSettings)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 文字颜色
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.textColor)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        colorButton(color: color, isSelected: bannerStyle.textColor == color) {
                            bannerStyle.textColor = color
                        }
                    }

                    // 自定义颜色按钮
                    #if os(iOS)
                    customColorButton {
                        colorPickerType = .text
                        tempColor = bannerStyle.textColor
                        showingColorPicker = true
                    }
                    #else
                    customColorButtonMacOS(isForTextColor: true)
                    #endif
                }
            }

            Divider()

            // 背景颜色
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.backgroundColor)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        colorButton(color: color, isSelected: bannerStyle.backgroundColor == color) {
                            bannerStyle.backgroundColor = color
                        }
                    }

                    // 自定义颜色按钮
                    #if os(iOS)
                    customColorButton {
                        colorPickerType = .background
                        tempColor = bannerStyle.backgroundColor
                        showingColorPicker = true
                    }
                    #else
                    customColorButtonMacOS(isForTextColor: false)
                    #endif
                }
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
    
    // MARK: - 背景设置区域
    private var backgroundSettingsSection: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.backgroundSettings)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 背景图片上传区域
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.backgroundImage)
                    .font(.subheadline)
                    .fontWeight(.medium)

                // 图片预览区域 - 可直接点击选择
                Button(action: {
                    // 检查是否为高级功能
                    if !subscriptionManager.isSubscribed {
                        // 显示升级提示，不允许选择图片
                        premiumFeatureName = L10n.StyleSettings.imageBackground
                        premiumFeatureDescription = L10n.PremiumFeature.backgroundImagesDesc
                        showingPremiumUpgrade = true
                        return
                    }
                    // 只有订阅用户才能选择图片
                    showingImagePicker = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.blue.opacity(0.5), lineWidth: 2, antialiased: true)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                                            .foregroundColor(Color.blue.opacity(0.3))
                                    )
                            )

                        // 高级标识
                        if !subscriptionManager.isSubscribed {
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.orange)
                                        .padding(8)
                                }
                                Spacer()
                            }
                        }

                        if let imagePath = bannerStyle.backgroundImagePath,
                           let url = URL(string: "file://" + imagePath) {
                            // 显示已选择的图片
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipped()
                                    .cornerRadius(12)
                            } placeholder: {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                    Text(L10n.App.loading)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            // 未选择图片时的占位符
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 32))
                                    .foregroundColor(.blue)
                                Text(L10n.StyleSettings.selectImage)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                Text(L10n.StyleSettings.supportedFormats)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)

                // 显示当前选中的图片
                if let imagePath = bannerStyle.backgroundImagePath,
                   !imagePath.isEmpty {
                    HStack {
                        Text(String(format: L10n.StyleSettings.selectedImage, URL(fileURLWithPath: imagePath).lastPathComponent))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(L10n.App.remove) {
                             // 删除图片文件
                             BannerDataManager.shared.deleteBackgroundImage(at: imagePath)
                             // 清除路径并切换回纯色背景
                             bannerStyle.backgroundImagePath = nil
                             bannerStyle.backgroundType = .color
                         }
                         .buttonStyle(.plain)
                         .foregroundColor(.red)
                         .font(.caption)
                    }
                }

                // 图片透明度设置
                if bannerStyle.backgroundImagePath != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(L10n.StyleSettings.imageOpacity)
                            Spacer()
                            Text("\(Int(bannerStyle.backgroundImageOpacity * 100))%")
                                .foregroundColor(.secondary)
                        }

                        Slider(
                            value: $bannerStyle.backgroundImageOpacity,
                            in: 0.1...1.0,
                            step: 0.1
                        ) {
                            Text(L10n.StyleSettings.imageOpacity)
                        } minimumValueLabel: {
                            Text("10%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } maximumValueLabel: {
                            Text("100%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
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
    
    // MARK: - 动画设置区域
    private var animationSettingsSection: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.animationSettings)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 动画类型选择
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.animationType)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(AnimationType.allCases, id: \.self) { animationType in
                        animationTypeButton(animationType)
                    }
                }
            }

            // 动画速度设置（仅在有动画时显示）
            if bannerStyle.animationType != .none {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(L10n.StyleSettings.animationSpeed)
                        Spacer()
                        Text(String(format: "%.1fx", bannerStyle.animationSpeed))
                            .foregroundColor(.secondary)
                    }

                    Slider(
                        value: $bannerStyle.animationSpeed,
                        in: 0.5...3.0,
                        step: 0.1
                    ) {
                        Text(L10n.StyleSettings.animationSpeed)
                    } minimumValueLabel: {
                        Text(L10n.StyleSettings.speedSlow)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text(L10n.StyleSettings.speedFast)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
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
    
    // MARK: - 预设样式区域
    private var presetStylesSection: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.presetStyles)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                presetStyleButton(L10n.PresetStyle.concert, .red, .white, .blink)
                presetStyleButton(L10n.PresetStyle.birthday, .pink, .white, .gradient)
                presetStyleButton(L10n.PresetStyle.pickup, .white, .black, .none)
                presetStyleButton(L10n.PresetStyle.driver, .blue, .white, .breathing)
                presetStyleButton(L10n.PresetStyle.thanks, .green, .white, .none)
                presetStyleButton(L10n.PresetStyle.wait, .yellow, .black, .blink)
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

    // MARK: - 颜色选择器弹窗
    private var colorPickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 当前颜色预览
                VStack(spacing: 12) {
                    Text(L10n.StyleSettings.selectColor)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // 颜色预览块
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tempColor)
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    // 颜色选择器
                    ColorPicker("", selection: $tempColor, supportsOpacity: false)
                        .labelsHidden()
                        #if os(macOS)
                        .frame(width: 200, height: 40)
                        #endif
                }
                .padding(.top, 20)

                Spacer()
            }
            .frame(minWidth: 300, minHeight: 300)
            .padding()
            .navigationTitle(colorPickerType == .text ? L10n.StyleSettings.textSettingsTitle : L10n.StyleSettings.bgColorTitle)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.App.cancel) {
                        showingColorPicker = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.App.confirm) {
                        if colorPickerType == .text {
                            bannerStyle.textColor = tempColor
                        } else {
                            bannerStyle.backgroundColor = tempColor
                        }
                        showingColorPicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 350)
        #endif
    }
    
    // MARK: - 辅助方法
    private func fontStyleButton(_ fontStyle: FontStyle) -> some View {
        Button(action: {
            // 检查是否为高级字体
            if fontStyle.isPremium && !subscriptionManager.isSubscribed {
                // 显示升级提示，不设置样式
                premiumFeatureName = fontStyle.displayName
                premiumFeatureDescription = fontStyle.description
                showingPremiumUpgrade = true
                return
            }
            // 只有免费功能或已订阅才设置样式
            bannerStyle.fontStyle = fontStyle
        }) {
            VStack(spacing: 4) {
                // 标题行（含高级标识）
                HStack(spacing: 4) {
                    Text(fontStyle.displayName)
                        .font(.caption)
                        .fontWeight(.medium)

                    if fontStyle.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                }

                Text(fontStyle.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(bannerStyle.fontStyle == fontStyle ? Color.blue : Color.gray.opacity(0.1))
            )
            .foregroundColor(bannerStyle.fontStyle == fontStyle ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
    
    private func backgroundTypeButton(_ type: BackgroundType) -> some View {
        Button(action: {
            bannerStyle.backgroundType = type
            // 如果切换到纯色背景，清除图片路径
            if type == .color {
                bannerStyle.backgroundImagePath = nil
            }
        }) {
            Text(type.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(bannerStyle.backgroundType == type ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(bannerStyle.backgroundType == type ? Color.blue : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                )
        }
    }
    
    private func colorButton(color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                )
                .overlay(
                    // 白色需要特殊处理边框
                    color == .white ?
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    : nil
                )
        }
        .buttonStyle(.plain)
    }

    /// 自定义颜色按钮
    private func customColorButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .buttonStyle(.plain)
    }

    #if os(macOS)
    /// macOS 专用的自定义颜色按钮 - 使用 ColorPicker
    @ViewBuilder
    private func customColorButtonMacOS(isForTextColor: Bool) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )

            // 隐藏的 ColorPicker 覆盖在按钮上
            ColorPicker("", selection: isForTextColor ? $bannerStyle.textColor : $bannerStyle.backgroundColor, supportsOpacity: false)
                .labelsHidden()
                .opacity(0.02) // 几乎透明但仍然可以点击
                .frame(width: 40, height: 40)
        }
    }
    #endif

    /// 动画类型按钮
    private func animationTypeButton(_ animationType: AnimationType) -> some View {
        Button {
            // 检查是否为高级动效
            if animationType.isPremium && !subscriptionManager.isSubscribed {
                // 显示升级提示，不设置样式
                premiumFeatureName = animationType.displayName
                premiumFeatureDescription = animationType.description
                showingPremiumUpgrade = true
                return
            }
            // 只有免费功能或已订阅才设置样式
            bannerStyle.animationType = animationType
        } label: {
            VStack(spacing: 8) {
                // 标题行（含高级标识）
                HStack(spacing: 4) {
                    Text(animationType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if animationType.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }

                Text(animationType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(bannerStyle.animationType == animationType ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                bannerStyle.animationType == animationType ? Color.blue : Color.gray.opacity(0.3),
                                lineWidth: bannerStyle.animationType == animationType ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /// 预设样式按钮
    private func presetStyleButton(_ name: String, _ bgColor: Color, _ textColor: Color, _ animation: AnimationType) -> some View {
        Button {
            bannerStyle.backgroundColor = bgColor
            bannerStyle.textColor = textColor
            bannerStyle.animationType = animation
            bannerStyle.fontSize = 48
            bannerStyle.isBold = true
            bannerStyle.animationSpeed = 1.0
        } label: {
            VStack(spacing: 8) {
                // 预览小图
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(bgColor)
                        .frame(height: 40)
                    
                    Text(name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(textColor)
                }
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    #if os(iOS)
                    .fill(Color(.systemGray5))
                    #else
                    .fill(Color.gray.opacity(0.2))
                    #endif
            )
        }
        .buttonStyle(PlainButtonStyle())
     }
     
     // MARK: - 图片选择器
    private var imagePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(L10n.StyleSettings.selectBackgroundImage)
                    .font(.headline)

                #if os(iOS)
                 Button(L10n.StyleSettings.selectFromAlbum) {
                     // 延迟执行以避免模态视图冲突
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                         // 创建协调器
                         imagePickerCoordinator = ImagePickerCoordinator { image in
                             selectedUIImage = image
                             selectedImage = Image(uiImage: image)

                             // 保存图片并获取路径，自动切换到图片背景
                             if let savedPath = BannerDataManager.shared.saveBackgroundImage(image) {
                                 bannerStyle.backgroundImagePath = savedPath
                                 bannerStyle.backgroundType = .image
                             }

                             showingImagePicker = false
                         }

                         let imagePicker = UIImagePickerController()
                         imagePicker.sourceType = .photoLibrary
                         imagePicker.delegate = imagePickerCoordinator

                         // 获取当前最顶层的视图控制器
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

                        // 保存图片并获取路径，自动切换到图片背景
                        if let savedPath = BannerDataManager.shared.saveBackgroundImage(image) {
                            bannerStyle.backgroundImagePath = savedPath
                            bannerStyle.backgroundType = .image
                        }

                        showingImagePicker = false
                    }
                }
                .padding()
                .background(Color.blue)
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

                        // 删除已保存的图片
                        if let imagePath = bannerStyle.backgroundImagePath {
                            BannerDataManager.shared.deleteBackgroundImage(at: imagePath)
                        }
                        bannerStyle.backgroundImagePath = nil
                        showingImagePicker = false
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
            .navigationTitle(L10n.StyleSettings.backgroundImage)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.App.cancel) {
                        showingImagePicker = false
                    }
                }
            }
        }
    }
}

// MARK: - 预览
struct StyleSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        StyleSettingsView(
            bannerStyle: .constant(
                BannerStyle(
                    text: "预览文字",
                    fontSize: 48,
                    textColor: .white,
                    backgroundColor: .blue,
                    animationType: .scroll,
                    animationSpeed: 1.0,
                    isBold: true,
                    fontStyle: .normal
                )
            )
        )
    }
}