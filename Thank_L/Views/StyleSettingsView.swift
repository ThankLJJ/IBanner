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

struct StyleSettingsView: View {
    @Binding var bannerStyle: BannerStyle
    @Environment(\.dismiss) private var dismiss

    @StateObject private var subscriptionManager = SubscriptionManager.shared

    @State private var showingColorPicker = false
    @State private var colorPickerType: ColorPickerType = .text
    @State private var tempColor: Color = .white
    @State private var showingImagePicker = false
    @State private var selectedImage: Image? = nil
    
    #if os(macOS)
    @State private var showingTextColorPopover = false
    @State private var showingBgColorPopover = false
    #endif

    @State private var showingPremiumUpgrade = false
    @State private var premiumFeatureName = ""
    @State private var premiumFeatureDescription: String? = nil

    @State private var previewScrollOffset: CGFloat = 0
    @State private var previewIsBlinking: Bool = false
    @State private var previewBreathingOpacity: Double = 1.0
    @State private var previewWavePhase: CGFloat = 0
    @State private var previewBounceScale: CGFloat = 1.0
    @State private var previewIsAnimating: Bool = false
    @State private var previewGradientOffset: CGFloat = 0

    private let presetColors: [Color] = [
        .white, .black, .red, .orange, .yellow, .green,
        .blue, .purple, .pink, .brown, .gray, .cyan
    ]
    
    typealias ColorPickerType = ColorSettingsSection.ColorPickerType

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    StylePreviewSection(
                        bannerStyle: $bannerStyle,
                        previewScrollOffset: $previewScrollOffset,
                        previewIsBlinking: $previewIsBlinking,
                        previewBreathingOpacity: $previewBreathingOpacity,
                        previewWavePhase: $previewWavePhase,
                        previewBounceScale: $previewBounceScale,
                        previewGradientOffset: $previewGradientOffset
                    )
                    .onAppear { startPreviewAnimation() }
                    .onDisappear { stopPreviewAnimation() }
                    .onChange(of: bannerStyle.animationType) { _, _ in
                        stopPreviewAnimation()
                        startPreviewAnimation()
                    }
                    .onChange(of: bannerStyle.animationSpeed) { _, _ in
                        stopPreviewAnimation()
                        startPreviewAnimation()
                    }

                    TextSettingsSection(
                        bannerStyle: $bannerStyle,
                        onPremiumFeatureTapped: handlePremiumFeature,
                        isSubscribed: subscriptionManager.isSubscribed
                    )

                    if bannerStyle.fontStyle == .artistic {
                        ArtisticStyleSection(
                            bannerStyle: $bannerStyle,
                            onPremiumFeatureTapped: handlePremiumFeature,
                            isSubscribed: subscriptionManager.isSubscribed
                        )
                    } else if bannerStyle.fontStyle == .neon {
                        NeonStyleSection(
                            bannerStyle: $bannerStyle,
                            onPremiumFeatureTapped: handlePremiumFeature,
                            isSubscribed: subscriptionManager.isSubscribed
                        )
                    }

                    ColorSettingsSection(
                        bannerStyle: $bannerStyle,
                        presetColors: presetColors,
                        onCustomColorTapped: { type in
                            colorPickerType = type
                            tempColor = type == .text ? bannerStyle.textColor : bannerStyle.backgroundColor
                            showingColorPicker = true
                        }
                    )

                    BackgroundSettingsSection(
                        bannerStyle: $bannerStyle,
                        selectedImage: $selectedImage,
                        isSubscribed: subscriptionManager.isSubscribed,
                        onPremiumFeatureTapped: handlePremiumFeature,
                        onImagePickerTapped: { showingImagePicker = true },
                        loadBackgroundImage: loadBackgroundImage,
                        onClearImage: clearBackgroundImage
                    )

                    AnimationSettingsSection(
                        bannerStyle: $bannerStyle,
                        onPremiumFeatureTapped: handlePremiumFeature,
                        isSubscribed: subscriptionManager.isSubscribed
                    )

                    if hasAnimationConfig {
                        AnimationConfigSection(bannerStyle: $bannerStyle)
                    }

                    PresetStylesSection(bannerStyle: $bannerStyle)
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
                    Button(L10n.App.cancel) { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.App.done) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerSheet(
                bannerStyle: $bannerStyle,
                isPresented: $showingColorPicker,
                tempColor: $tempColor,
                pickerType: colorPickerType
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerSheet(
                bannerStyle: $bannerStyle,
                isPresented: $showingImagePicker,
                selectedImage: $selectedImage,
                onImagePicked: { image in
                    selectedImage = image
                },
                onClearImage: clearBackgroundImage
            )
        }
        .sheet(isPresented: $showingPremiumUpgrade) {
            PremiumUpgradeSheet(
                featureName: premiumFeatureName,
                featureDescription: premiumFeatureDescription,
                onDismiss: {}
            )
        }
    }
    
    private var hasAnimationConfig: Bool {
        switch bannerStyle.animationType {
        case .blink, .breathing, .wave, .bounce, .led:
            return true
        default:
            return false
        }
    }
    
    private func handlePremiumFeature(_ name: String, _ description: String?) {
        premiumFeatureName = name
        premiumFeatureDescription = description
        showingPremiumUpgrade = true
    }

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

    private func loadBackgroundImage(from relativePath: String) -> Image? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsPath.appendingPathComponent(relativePath)

        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            return nil
        }

        #if os(iOS)
        if let uiImage = UIImage(contentsOfFile: imageURL.path) {
            return Image(uiImage: uiImage)
        }
        #elseif os(macOS)
        if let nsImage = NSImage(contentsOf: imageURL) {
            return Image(nsImage: nsImage)
        }
        #endif

        return nil
    }

    private func clearBackgroundImage() {
        if let imagePath = bannerStyle.backgroundImagePath {
            BannerDataManager.shared.deleteBackgroundImage(at: imagePath)
        }
        bannerStyle.backgroundImagePath = nil
        bannerStyle.backgroundType = .color
        selectedImage = nil
    }
}

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
