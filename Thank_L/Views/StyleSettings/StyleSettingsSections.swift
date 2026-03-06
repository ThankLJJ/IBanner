//
//  StyleSettingsSections.swift
//  Thank_L
//
//  StyleSettingsView 的配置区域组件
//

import SwiftUI
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct TextSettingsSection: View {
    @Binding var bannerStyle: BannerStyle
    let onPremiumFeatureTapped: (String, String?) -> Void
    let isSubscribed: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.textSettings)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

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

            HStack {
                Text(L10n.StyleSettings.bold)
                Spacer()
                Toggle("", isOn: $bannerStyle.isBold)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.fontStyle)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(FontStyle.allCases, id: \.self) { fontStyle in
                        FontStyleButton(
                            fontStyle: fontStyle,
                            isSelected: bannerStyle.fontStyle == fontStyle,
                            isSubscribed: isSubscribed
                        ) {
                            if fontStyle.isPremium && !isSubscribed {
                                onPremiumFeatureTapped(fontStyle.displayName, fontStyle.description)
                            } else {
                                bannerStyle.fontStyle = fontStyle
                            }
                        }
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
}

struct ArtisticStyleSection: View {
    @Binding var bannerStyle: BannerStyle
    let onPremiumFeatureTapped: (String, String?) -> Void
    let isSubscribed: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.artisticStyle)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.selectStyle)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(ArtisticStyle.allCases, id: \.self) { style in
                        ArtisticStyleButton(
                            style: style,
                            isSelected: bannerStyle.artisticStyle == style,
                            isSubscribed: isSubscribed
                        ) {
                            if style.isPremium && !isSubscribed {
                                onPremiumFeatureTapped(style.displayName, style.description)
                            } else {
                                bannerStyle.artisticStyle = style
                            }
                        }
                    }
                }
            }

            Divider()
            artisticCustomConfigView
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
    
    @ViewBuilder
    private var artisticCustomConfigView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.customConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            if bannerStyle.artisticConfig.showStroke {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(L10n.StyleSettings.strokeWidth)
                        Spacer()
                        Text("\(Int(bannerStyle.artisticConfig.strokeWidth))")
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $bannerStyle.artisticConfig.strokeWidth, in: 0...5, step: 0.5)
                }

                ColorPicker(L10n.StyleSettings.strokeColor, selection: $bannerStyle.artisticConfig.strokeColor, supportsOpacity: false)
            }

            if bannerStyle.artisticConfig.showShadow {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(L10n.StyleSettings.shadowRadius)
                        Spacer()
                        Text("\(Int(bannerStyle.artisticConfig.shadowRadius))")
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $bannerStyle.artisticConfig.shadowRadius, in: 0...20, step: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(L10n.StyleSettings.shadowOpacity)
                        Spacer()
                        Text(String(format: "%.1f", bannerStyle.artisticConfig.shadowOpacity))
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $bannerStyle.artisticConfig.shadowOpacity, in: 0...1, step: 0.1)
                }
            }

            if bannerStyle.artisticConfig.showMaterial {
                HStack {
                    Text(L10n.StyleSettings.materialIntensity)
                    Spacer()
                    Text(String(format: "%.1f", bannerStyle.artisticConfig.materialIntensity))
                        .foregroundColor(.secondary)
                }

                Slider(value: $bannerStyle.artisticConfig.materialIntensity, in: 0...1, step: 0.1)
            }

            if bannerStyle.artisticConfig.showAtmosphere {
                HStack {
                    Text(L10n.StyleSettings.atmosphereIntensity)
                    Spacer()
                    Text(String(format: "%.1f", bannerStyle.artisticConfig.atmosphereIntensity))
                        .foregroundColor(.secondary)
                }

                Slider(value: $bannerStyle.artisticConfig.atmosphereIntensity, in: 0...1, step: 0.1)
            }
        }
    }
}

struct NeonStyleSection: View {
    @Binding var bannerStyle: BannerStyle
    let onPremiumFeatureTapped: (String, String?) -> Void
    let isSubscribed: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.neonStyle)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.selectStyle)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(NeonStyle.allCases, id: \.self) { style in
                        NeonStyleButton(
                            style: style,
                            isSelected: bannerStyle.neonStyle == style,
                            isSubscribed: isSubscribed
                        ) {
                            if style.isPremium && !isSubscribed {
                                onPremiumFeatureTapped(style.displayName, style.description)
                            } else {
                                bannerStyle.neonStyle = style
                            }
                        }
                    }
                }
            }

            Divider()
            neonCustomConfigView
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
    
    @ViewBuilder
    private var neonCustomConfigView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.customConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            ColorPicker(L10n.StyleSettings.glowColor, selection: $bannerStyle.neonConfig.glowColor, supportsOpacity: false)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.glowIntensity)
                    Spacer()
                    Text(String(format: "%.1f", bannerStyle.neonConfig.glowIntensity))
                        .foregroundColor(.secondary)
                }

                Slider(value: $bannerStyle.neonConfig.glowIntensity, in: 0.1...2.0, step: 0.1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.glowRadius)
                    Spacer()
                    Text("\(Int(bannerStyle.neonConfig.glowRadius))")
                        .foregroundColor(.secondary)
                }

                Slider(value: $bannerStyle.neonConfig.glowRadius, in: 5...50, step: 1)
            }

            if bannerStyle.neonStyle == .glitch {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(L10n.StyleSettings.glitchIntensity)
                        Spacer()
                        Text(String(format: "%.1f", bannerStyle.neonConfig.glitchIntensity))
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $bannerStyle.neonConfig.glitchIntensity, in: 1...10, step: 0.5)
                }
            }

            if bannerStyle.neonStyle == .gradient || bannerStyle.neonStyle == .custom {
                ColorPicker(L10n.StyleSettings.gradientEndColor, selection: Binding(
                    get: { bannerStyle.neonConfig.gradientEndColor ?? bannerStyle.neonConfig.glowColor },
                    set: { bannerStyle.neonConfig.gradientEndColor = $0 }
                ), supportsOpacity: false)
            }

            if bannerStyle.neonStyle == .custom {
                Toggle(L10n.StyleSettings.enableMultipleLayers, isOn: $bannerStyle.neonConfig.enableMultipleLayers)

                if bannerStyle.neonConfig.enableMultipleLayers {
                    ColorPicker(L10n.StyleSettings.secondaryGlowColor, selection: Binding(
                        get: { bannerStyle.neonConfig.secondaryGlowColor ?? bannerStyle.neonConfig.glowColor },
                        set: { bannerStyle.neonConfig.secondaryGlowColor = $0 }
                    ), supportsOpacity: false)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(L10n.StyleSettings.secondaryGlowRadius)
                            Spacer()
                            Text("\(Int(bannerStyle.neonConfig.secondaryGlowRadius))")
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $bannerStyle.neonConfig.secondaryGlowRadius, in: 10...100, step: 5)
                    }
                }
            }
        }
    }
}

struct ColorSettingsSection: View {
    @Binding var bannerStyle: BannerStyle
    let presetColors: [Color]
    let onCustomColorTapped: (ColorPickerType) -> Void
    
    enum ColorPickerType {
        case text, background
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.colorSettings)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.textColor)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        ColorButton(
                            color: color,
                            isSelected: bannerStyle.textColor == color
                        ) {
                            bannerStyle.textColor = color
                        }
                    }
                    
                    #if os(macOS)
                    CustomColorButtonMacOS(selectedColor: $bannerStyle.textColor)
                    #else
                    CustomColorButton {
                        onCustomColorTapped(.text)
                    }
                    #endif
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.backgroundColor)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        ColorButton(
                            color: color,
                            isSelected: bannerStyle.backgroundColor == color
                        ) {
                            bannerStyle.backgroundColor = color
                            bannerStyle.backgroundType = .color
                        }
                    }
                    
                    #if os(macOS)
                    CustomColorButtonMacOS(selectedColor: $bannerStyle.backgroundColor)
                    #else
                    CustomColorButton {
                        onCustomColorTapped(.background)
                    }
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
}

struct BackgroundSettingsSection: View {
    @Binding var bannerStyle: BannerStyle
    @Binding var selectedImage: Image?
    let isSubscribed: Bool
    let onPremiumFeatureTapped: (String, String?) -> Void
    let onImagePickerTapped: () -> Void
    let loadBackgroundImage: (String) -> Image?
    let onClearImage: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.backgroundSettings)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                BackgroundTypeButton(
                    type: .color,
                    isSelected: bannerStyle.backgroundType == .color
                ) {
                    bannerStyle.backgroundType = .color
                    bannerStyle.backgroundImagePath = nil
                }

                BackgroundTypeButton(
                    type: .image,
                    isSelected: bannerStyle.backgroundType == .image
                ) {
                    bannerStyle.backgroundType = .image
                }
            }

            if bannerStyle.backgroundType == .image {
                Divider()
                
                Button(action: {
                    if !isSubscribed {
                        onPremiumFeatureTapped(L10n.StyleSettings.imageBackground, L10n.PremiumFeature.backgroundImagesDesc)
                        return
                    }
                    onImagePickerTapped()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )

                        if !isSubscribed {
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.orange)
                                        .padding(8)
                                }
                                Spacer()
                            }
                        }

                        if let imagePath = bannerStyle.backgroundImagePath, let image = loadBackgroundImage(imagePath) {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                                
                                Text(L10n.StyleSettings.selectImage)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)

                if bannerStyle.backgroundImagePath != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(L10n.StyleSettings.imageOpacity)
                            Spacer()
                            Text(String(format: "%.1f", bannerStyle.backgroundImageOpacity))
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $bannerStyle.backgroundImageOpacity, in: 0.1...1.0, step: 0.1)
                    }

                    Button(role: .destructive) {
                        onClearImage()
                    } label: {
                        Text(L10n.StyleSettings.removeBackgroundImage)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
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
}

struct AnimationSettingsSection: View {
    @Binding var bannerStyle: BannerStyle
    let onPremiumFeatureTapped: (String, String?) -> Void
    let isSubscribed: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.animationSettings)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.StyleSettings.animationType)
                    .font(.subheadline)
                    .fontWeight(.medium)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(AnimationType.allCases, id: \.self) { animationType in
                        AnimationTypeButton(
                            animationType: animationType,
                            isSelected: bannerStyle.animationType == animationType,
                            isSubscribed: isSubscribed
                        ) {
                            if animationType.isPremium && !isSubscribed {
                                onPremiumFeatureTapped(animationType.displayName, animationType.description)
                            } else {
                                bannerStyle.animationType = animationType
                            }
                        }
                    }
                }
            }

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
                    Text("0.5x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("3.0x")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
}

struct AnimationConfigSection: View {
    @Binding var bannerStyle: BannerStyle
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.animationConfig)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            switch bannerStyle.animationType {
            case .blink:
                BlinkConfigView(config: $bannerStyle.blinkConfig)
            case .breathing:
                BreathingConfigView(config: $bannerStyle.breathingConfig)
            case .wave:
                WaveConfigView(config: $bannerStyle.waveConfig)
            case .bounce:
                BounceConfigView(config: $bannerStyle.bounceConfig)
            case .led:
                LEDConfigView(config: $bannerStyle.ledConfig)
            default:
                EmptyView()
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
}

struct BlinkConfigView: View {
    @Binding var config: BlinkConfig?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.blinkConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.minOpacity)
                    Spacer()
                    Text(String(format: "%.1f", config?.minOpacity ?? 0.3))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.minOpacity ?? 0.3 },
                    set: { 
                        if config == nil { config = BlinkConfig() }
                        config?.minOpacity = $0 
                    }
                ), in: 0...0.8, step: 0.1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.frequency)
                    Spacer()
                    Text(String(format: "%.1f", config?.frequency ?? 1.0))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.frequency ?? 1.0 },
                    set: { 
                        if config == nil { config = BlinkConfig() }
                        config?.frequency = $0 
                    }
                ), in: 0.5...3.0, step: 0.1)
            }
        }
    }
}

struct BreathingConfigView: View {
    @Binding var config: BreathingConfig?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.breathingConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.minScale)
                    Spacer()
                    Text(String(format: "%.1f", config?.minScale ?? 0.8))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.minScale ?? 0.8 },
                    set: { 
                        if config == nil { config = BreathingConfig() }
                        config?.minScale = $0 
                    }
                ), in: 0.5...1.0, step: 0.05)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.maxScale)
                    Spacer()
                    Text(String(format: "%.1f", config?.maxScale ?? 1.2))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.maxScale ?? 1.2 },
                    set: { 
                        if config == nil { config = BreathingConfig() }
                        config?.maxScale = $0 
                    }
                ), in: 1.0...1.5, step: 0.05)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.minOpacity)
                    Spacer()
                    Text(String(format: "%.1f", config?.minOpacity ?? 0.5))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.minOpacity ?? 0.5 },
                    set: { 
                        if config == nil { config = BreathingConfig() }
                        config?.minOpacity = $0 
                    }
                ), in: 0.2...0.9, step: 0.1)
            }
        }
    }
}

struct WaveConfigView: View {
    @Binding var config: WaveConfig?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.waveConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.amplitude)
                    Spacer()
                    Text("\(Int(config?.amplitude ?? 15))")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { Double(config?.amplitude ?? 15) },
                    set: { 
                        if config == nil { config = WaveConfig() }
                        config?.amplitude = $0 
                    }
                ), in: 5...30, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.frequency)
                    Spacer()
                    Text(String(format: "%.1f", config?.frequency ?? 0.5))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.frequency ?? 0.5 },
                    set: { 
                        if config == nil { config = WaveConfig() }
                        config?.frequency = $0 
                    }
                ), in: 0.2...1.0, step: 0.1)
            }
        }
    }
}

struct BounceConfigView: View {
    @Binding var config: BounceConfig?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.bounceConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.bounceHeight)
                    Spacer()
                    Text("\(Int(config?.bounceHeight ?? 20))")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { Double(config?.bounceHeight ?? 20) },
                    set: { 
                        if config == nil { config = BounceConfig() }
                        config?.bounceHeight = $0 
                    }
                ), in: 5...50, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.elasticity)
                    Spacer()
                    Text(String(format: "%.2f", config?.elasticity ?? 0.3))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.elasticity ?? 0.3 },
                    set: { 
                        if config == nil { config = BounceConfig() }
                        config?.elasticity = $0 
                    }
                ), in: 0.1...0.8, step: 0.05)
            }
        }
    }
}

struct LEDConfigView: View {
    @Binding var config: LEDConfig?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StyleSettings.ledConfig)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.ledSize)
                    Spacer()
                    Text("\(Int(config?.dotSize ?? 3))")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { Double(config?.dotSize ?? 3) },
                    set: {
                        if config == nil { config = LEDConfig() }
                        config?.dotSize = CGFloat($0)
                    }
                ), in: 2...10, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.ledSpacing)
                    Spacer()
                    Text("\(Int(config?.dotSpacing ?? 6))")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { Double(config?.dotSpacing ?? 6) },
                    set: {
                        if config == nil { config = LEDConfig() }
                        config?.dotSpacing = CGFloat($0)
                    }
                ), in: 2...15, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.StyleSettings.ledGlowIntensity)
                    Spacer()
                    Text(String(format: "%.1f", config?.glowIntensity ?? 0.5))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { config?.glowIntensity ?? 0.5 },
                    set: { 
                        if config == nil { config = LEDConfig() }
                        config?.glowIntensity = $0 
                    }
                ), in: 0...1.0, step: 0.1)
            }
        }
    }
}

struct PresetStylesSection: View {
    @Binding var bannerStyle: BannerStyle
    
    private let presets: [(name: String, bgColor: Color, textColor: Color, animation: AnimationType)] = [
        ("经典红白", .red, .white, .scroll),
        ("科技蓝", .blue, .white, .scroll),
        ("霓虹紫", .purple, .white, .blink),
        ("温暖橙", .orange, .white, .breathing),
        ("清新绿", .green, .white, .wave),
        ("活力黄", .yellow, .black, .bounce)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.StyleSettings.presetStyles)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(presets, id: \.name) { preset in
                    PresetStyleButton(
                        name: preset.name,
                        bgColor: preset.bgColor,
                        textColor: preset.textColor,
                        animation: preset.animation
                    ) {
                        bannerStyle.backgroundColor = preset.bgColor
                        bannerStyle.textColor = preset.textColor
                        bannerStyle.animationType = preset.animation
                        bannerStyle.fontSize = 48
                        bannerStyle.isBold = true
                        bannerStyle.animationSpeed = 1.0
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
}
