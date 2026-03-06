//
//  SubscriptionModels.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import Foundation

// MARK: - 订阅产品信息
struct SubscriptionProduct: Codable, Identifiable {
    var id: String { productID } // 使用productID作为唯一标识符
    var productID: String
    var displayName: String
    var description: String
    var price: String
    var duration: SubscriptionDuration
    var features: [String]

    init(productID: String, displayName: String, description: String, price: String, duration: SubscriptionDuration, features: [String]) {
        self.productID = productID
        self.displayName = displayName
        self.description = description
        self.price = price
        self.duration = duration
        self.features = features
    }
}

// MARK: - 订阅时长枚举
enum SubscriptionDuration: String, CaseIterable, Codable {
    case lifetime = "终身解锁"

    var displayName: String {
        return L10n.Subscription.lifetime
    }

    var description: String {
        switch self {
        case .lifetime:
            return L10n.Subscription.lifetimeDesc
        }
    }
}

// MARK: - 高级功能枚举
enum PremiumFeature: String, CaseIterable, Codable {
    case unlimitedPreview = "无限预览"
    case advancedAnimations = "高级动效"
    case customFonts = "自定义字体"
    case backgroundImages = "背景图片"
    case exportFeatures = "导出功能"

    var displayName: String {
        switch self {
        case .unlimitedPreview:
            return L10n.PremiumFeature.unlimitedPreview
        case .advancedAnimations:
            return L10n.PremiumFeature.advancedAnimations
        case .customFonts:
            return L10n.PremiumFeature.customFonts
        case .backgroundImages:
            return L10n.PremiumFeature.backgroundImages
        case .exportFeatures:
            return L10n.PremiumFeature.exportFeatures
        }
    }

    var description: String {
        switch self {
        case .unlimitedPreview:
            return L10n.PremiumFeature.unlimitedPreview
        case .advancedAnimations:
            return L10n.PremiumFeature.advancedAnimations
        case .customFonts:
            return L10n.PremiumFeature.customFonts
        case .backgroundImages:
            return L10n.PremiumFeature.backgroundImages
        case .exportFeatures:
            return L10n.PremiumFeature.exportFeatures
        }
    }

    var icon: String {
        switch self {
        case .unlimitedPreview:
            return "eye.fill"
        case .advancedAnimations:
            return "sparkles"
        case .customFonts:
            return "textformat"
        case .backgroundImages:
            return "photo.fill"
        case .exportFeatures:
            return "square.and.arrow.up.fill"
        }
    }
}

// MARK: - 订阅配置
struct SubscriptionConfig {
    static let lifetimeProductID = "com.thankl.premium.lifetime"

    static let lifetimePrice = "¥1.00"

    static let premiumFeatures: [PremiumFeature] = [
        .unlimitedPreview,
        .advancedAnimations,
        .customFonts,
        .backgroundImages,
        .exportFeatures
    ]

    static func getSubscriptionProducts() -> [SubscriptionProduct] {
        return [
            SubscriptionProduct(
                productID: lifetimeProductID,
                displayName: "高级版 - 终身解锁",
                description: "一次购买，解锁所有高级功能，终身使用",
                price: lifetimePrice,
                duration: .lifetime,
                features: premiumFeatures.map { $0.displayName }
            )
        ]
    }
}
