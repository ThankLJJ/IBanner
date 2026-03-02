//
//  PremiumUpgradeSheet.swift
//  Thank_L
//
//  Created by Claude on 2025/2/28.
//  Copyright © 2025 L. All rights reserved.
//

import SwiftUI

/// 高级功能升级提示弹窗
/// 当非订阅用户尝试使用高级功能时显示
struct PremiumUpgradeSheet: View {
    // MARK: - 属性
    /// 被限制的功能名称
    let featureName: String

    /// 功能价值说明（可选）
    var featureDescription: String? = nil

    /// 关闭回调
    var onDismiss: () -> Void

    /// 是否显示订阅页面
    @State private var showingSubscription = false

    // MARK: - 环境
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                // 图标
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }

                // 标题
                VStack(spacing: 8) {
                    Text(L10n.PremiumFeature.premiumFeature)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("「\(featureName)」")
                        .font(.title3)
                        .foregroundColor(.orange)
                }

                // 功能说明
                if let description = featureDescription {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // 功能列表
                VStack(alignment: .leading, spacing: 12) {
                    featureRow(icon: "sparkles", text: L10n.PremiumFeature.advancedAnimations)
                    featureRow(icon: "textformat", text: L10n.PremiumFeature.customFonts)
                    featureRow(icon: "photo.fill", text: L10n.PremiumFeature.backgroundImages)
                    featureRow(icon: "timer", text: L10n.PremiumFeature.unlimitedPreview)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        #if os(iOS)
                        .fill(Color.platformSystemGray6)
                        #else
                        .fill(Color.gray.opacity(0.1))
                        #endif
                )
                .padding(.horizontal, 24)

                Spacer()

                // 按钮区域
                VStack(spacing: 12) {
                    // 升级按钮
                    Button {
                        showingSubscription = true
                    } label: {
                        Text(L10n.PremiumFeature.upgrade)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }

                    // 以后再说按钮
                    Button {
                        dismiss()
                        onDismiss()
                    } label: {
                        Text(L10n.PremiumFeature.later)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
    }

    // MARK: - 辅助视图
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.orange)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.green)
        }
    }
}

// MARK: - 便捷扩展
extension PremiumUpgradeSheet {
    /// 创建动效升级提示
    static func forAnimation(_ animationType: AnimationType, onDismiss: @escaping () -> Void) -> PremiumUpgradeSheet {
        PremiumUpgradeSheet(
            featureName: animationType.displayName,
            featureDescription: animationType.description,
            onDismiss: onDismiss
        )
    }

    /// 创建字体升级提示
    static func forFont(_ fontStyle: FontStyle, onDismiss: @escaping () -> Void) -> PremiumUpgradeSheet {
        PremiumUpgradeSheet(
            featureName: fontStyle.displayName,
            featureDescription: fontStyle.description,
            onDismiss: onDismiss
        )
    }

    /// 创建背景图片升级提示
    static func forBackgroundImage(onDismiss: @escaping () -> Void) -> PremiumUpgradeSheet {
        PremiumUpgradeSheet(
            featureName: L10n.StyleSettings.imageBackground,
            featureDescription: L10n.PremiumFeature.backgroundImagesDesc,
            onDismiss: onDismiss
        )
    }

    /// 创建全屏展示时间限制提示
    static func forUnlimitedDisplay(onDismiss: @escaping () -> Void) -> PremiumUpgradeSheet {
        PremiumUpgradeSheet(
            featureName: L10n.PremiumFeature.unlimitedPreview,
            featureDescription: L10n.PremiumFeature.unlimitedPreviewDesc,
            onDismiss: onDismiss
        )
    }
}

// MARK: - 预览
struct PremiumUpgradeSheet_Previews: PreviewProvider {
    static var previews: some View {
        PremiumUpgradeSheet(
            featureName: "波浪动效",
            featureDescription: "让文字像波浪一样流动",
            onDismiss: {}
        )
    }
}
