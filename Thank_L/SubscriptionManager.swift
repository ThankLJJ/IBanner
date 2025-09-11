//
//  SubscriptionManager.swift
//  Thank_L
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import Foundation
import StoreKit
import SwiftUI

// MARK: - 订阅管理器
@MainActor
class SubscriptionManager: ObservableObject {
    // 单例实例
    static let shared = SubscriptionManager()
    
    // 订阅状态
    @Published var isSubscribed: Bool = false
    @Published var subscriptionStatus: SubscriptionStatus = .notSubscribed
    @Published var currentProduct: Product?
    @Published var purchaseError: String?
    
    // 产品ID - 需要在App Store Connect中配置
    private let productID = "com.thankl.premium.lifetime"
    
    // 可用产品
    @Published var availableProducts: [Product] = []
    
    private init() {
        // 启动时检查订阅状态
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }
    
    // MARK: - 订阅状态枚举
    enum SubscriptionStatus {
        case notSubscribed      // 未订阅
        case subscribed         // 已订阅
        case expired            // 已过期
        case inGracePeriod      // 宽限期
        case unknown            // 未知状态
    }
    
    // MARK: - 加载产品信息
    func loadProducts() async {
        do {
            print("🔄 开始加载StoreKit产品，产品ID: \(productID)")
            
            // 从App Store获取产品信息
            let products = try await Product.products(for: [productID])
            
            print("📦 StoreKit返回产品数量: \(products.count)")
            
            await MainActor.run {
                self.availableProducts = products
                self.currentProduct = products.first
                
                if let product = products.first {
                    print("✅ 产品加载成功: \(product.id) - \(product.displayPrice)")
                    self.purchaseError = nil
                } else {
                    let errorMsg = "未找到产品ID为 \(productID) 的产品。请检查：\n1. StoreKit配置文件是否已添加到Xcode项目\n2. 产品ID是否正确\n3. 是否在模拟器中运行"
                    print("❌ \(errorMsg)")
                    self.purchaseError = errorMsg
                }
            }
        } catch {
            let errorMsg = "无法加载产品信息: \(error.localizedDescription)"
            print("❌ StoreKit加载错误: \(errorMsg)")
            
            await MainActor.run {
                self.purchaseError = errorMsg
            }
        }
    }
    
    // MARK: - 检查订阅状态
    func checkSubscriptionStatus() async {
        do {
            // 获取当前有效的交易记录（包括非续费订阅）
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    // 检查是否是我们的终身解锁产品
                    if transaction.productID == productID {
                        await MainActor.run {
                            self.isSubscribed = true
                            self.subscriptionStatus = .subscribed
                        }
                        return
                    }
                }
            }
            
            // 如果没有找到有效购买记录
            await MainActor.run {
                self.isSubscribed = false
                self.subscriptionStatus = .notSubscribed
            }
        } catch {
            print("检查购买状态失败: \(error.localizedDescription)")
            await MainActor.run {
                self.subscriptionStatus = .unknown
            }
        }
    }
    
    // MARK: - 购买终身解锁
    func purchaseSubscription() async -> Bool {
        guard let product = currentProduct else {
            await MainActor.run {
                self.purchaseError = "产品信息不可用"
            }
            return false
        }
        
        do {
            // 发起购买请求
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // 验证购买结果
                if case .verified(let transaction) = verification {
                    // 完成交易
                    await transaction.finish()
                    
                    await MainActor.run {
                        self.isSubscribed = true
                        self.subscriptionStatus = .subscribed
                        self.purchaseError = nil
                    }
                    return true
                } else {
                    await MainActor.run {
                        self.purchaseError = "购买验证失败"
                    }
                    return false
                }
                
            case .userCancelled:
                // 用户取消购买
                await MainActor.run {
                    self.purchaseError = nil
                }
                return false
                
            case .pending:
                // 购买待处理（如需要家长同意）
                await MainActor.run {
                    self.purchaseError = "购买请求待处理，请稍后查看"
                }
                return false
                
            @unknown default:
                await MainActor.run {
                    self.purchaseError = "未知购买结果"
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.purchaseError = "购买失败: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - 恢复购买
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            await MainActor.run {
                self.purchaseError = "恢复购买失败: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - 获取产品价格
    func getProductPrice() -> String {
        guard let product = currentProduct else {
            return "¥19.90"
        }
        return product.displayPrice
    }
    
    // MARK: - 获取产品描述
    func getProductDescription() -> String {
        guard let product = currentProduct else {
            return "解锁所有高级功能"
        }
        return product.description
    }
    
    // MARK: - 清除错误信息
    func clearError() {
        purchaseError = nil
    }
}

// MARK: - 订阅检查扩展
extension SubscriptionManager {
    // 检查是否可以使用高级功能
    func canUsePreviewFeature() -> Bool {
        return isSubscribed
    }
    
    // 获取订阅状态描述
    func getSubscriptionStatusDescription() -> String {
        switch subscriptionStatus {
        case .subscribed:
            return "已购买终身解锁"
        case .notSubscribed:
            return "未购买"
        case .expired:
            return "购买已过期"
        case .inGracePeriod:
            return "购买宽限期"
        case .unknown:
            return "状态未知"
        }
    }
}