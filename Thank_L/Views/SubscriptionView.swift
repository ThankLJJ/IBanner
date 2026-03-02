//
//  SubscriptionView.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/12.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI
import StoreKit

/// 订阅购买界面
/// 展示高级版功能和订阅选项
struct SubscriptionView: View {
    // MARK: - 状态管理
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: SubscriptionProduct?
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // MARK: - 主视图
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 头部区域
                    headerSection
                    
                    // 功能介绍区域
                    featuresSection
                    
                    // 订阅选项区域
                    subscriptionOptionsSection
                    
                    // 购买按钮区域
                    purchaseButtonSection
                    
                    // 恢复购买和条款区域
                    footerSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle(L10n.Subscription.premium)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.App.close) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadProducts()
            // 默认选择第一个产品（终身解锁）
            let products = SubscriptionConfig.getSubscriptionProducts()
            print("可用产品数量: \(products.count)") // 调试信息：产品数量
            selectedProduct = products.first
            print("默认选中产品: \(selectedProduct?.displayName ?? "无")") // 调试信息：默认选中
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - 头部区域
    private var headerSection: some View {
        VStack(spacing: 16) {
            // 应用图标和标题
            VStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(L10n.Subscription.unlockAll)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(L10n.Subscription.lifetimeDescFull)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - 功能介绍区域
    private var featuresSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(L10n.Subscription.features)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(PremiumFeature.allCases, id: \.self) { feature in
                    featureCard(feature)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                #if os(iOS)
                .fill(Color.platformSystemGray6)
                #else
                .fill(Color.gray.opacity(0.1))
                #endif
        )
    }
    
    // MARK: - 功能卡片
    private func featureCard(_ feature: PremiumFeature) -> some View {
        VStack(spacing: 8) {
            Image(systemName: feature.icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
            
            Text(feature.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(feature.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .fill(Color.platformBackground)
                #else
                .fill(Color.platformBackground)
                #endif
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - 订阅选项区域
    private var subscriptionOptionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(L10n.Subscription.selectPlan)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(spacing: 12) {
                ForEach(SubscriptionConfig.getSubscriptionProducts()) { product in
                    subscriptionOptionCard(product)
                }
            }
        }
    }

    // MARK: - 订阅选项卡片
    private func subscriptionOptionCard(_ product: SubscriptionProduct) -> some View {
        let isSelected = selectedProduct?.id == product.id
        let isLifetime = product.duration == .lifetime // 检查产品时长是否为终身解锁

        print("渲染产品卡片: \(product.displayName), 选中状态: \(isSelected)") // 调试信息：渲染状态

        return Button {
            print("订阅方案被点击: \(product.displayName)") // 调试信息：记录点击事件
            selectedProduct = product
            print("当前选中产品: \(selectedProduct?.displayName ?? "无")") // 调试信息：记录选中状态
        } label: {
            HStack(spacing: 16) {
                // 选择指示器
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        if isLifetime {
                            Text(L10n.Subscription.recommended)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.orange)
                                )
                        }

                        Spacer()
                    }

                    Text(product.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    if isLifetime {
                        Text(L10n.Subscription.oneTime)
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    #if os(iOS)
                    .fill(Color.platformBackground)
                    #else
                    .fill(Color.platformBackground)
                    #endif
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.blue : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? .blue.opacity(0.2) : .black.opacity(0.05),
                        radius: isSelected ? 4 : 2,
                        x: 0,
                        y: isSelected ? 2 : 1
                    )
            )
        }
        .contentShape(Rectangle()) // 确保整个区域都可点击
        .buttonStyle(.plain) // 使用简洁的按钮样式
    }
    
    // MARK: - 购买按钮区域
    private var purchaseButtonSection: some View {
        VStack(spacing: 12) {
            Button {
                purchaseSubscription()
            } label: {
                HStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 18, weight: .bold))
                    }

                    Text(isLoading ? L10n.App.loading : L10n.Subscription.lifetime)
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isLoading || selectedProduct == nil)
            .opacity(isLoading ? 0.8 : 1.0)

            Text(L10n.Subscription.lifetimeGuarantee)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - 底部区域
    private var footerSection: some View {
        VStack(spacing: 16) {
            // 恢复购买按钮
            Button {
                restorePurchases()
            } label: {
                Text(L10n.Subscription.restore)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
            }
            .disabled(isLoading)

            // 条款和隐私政策
            HStack(spacing: 16) {
                Button(L10n.Subscription.termsOfUse) {
                    // 打开使用条款
                }
                .font(.caption)
                .foregroundColor(.blue)

                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(L10n.Subscription.privacyPolicy) {
                    // 打开隐私政策
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - 辅助方法
    
    /// 加载产品信息
    private func loadProducts() {
        Task {
            // 加载StoreKit产品信息
            await subscriptionManager.loadProducts()
            
            await MainActor.run {
                // 打印StoreKit产品加载状态
                if let currentProduct = subscriptionManager.currentProduct {
                    print("✅ StoreKit产品加载成功: \(currentProduct.id) - \(currentProduct.displayPrice)")
                } else {
                    print("❌ StoreKit产品加载失败: \(subscriptionManager.purchaseError ?? "未知错误")")
                }
                
                // 打印可用产品列表
                print("📦 可用StoreKit产品数量: \(subscriptionManager.availableProducts.count)")
                for product in subscriptionManager.availableProducts {
                    print("   - \(product.id): \(product.displayPrice)")
                }
            }
        }
    }
    
    /// 购买订阅
    private func purchaseSubscription() {
        // 检查是否有选中的产品
        guard selectedProduct != nil else { 
            alertMessage = "请先选择订阅方案"
            showingAlert = true
            return 
        }
        
        // 检查StoreKit产品是否已加载
        guard subscriptionManager.currentProduct != nil else {
            alertMessage = "产品信息不可用，请稍后重试"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            let success = await subscriptionManager.purchaseSubscription()
            
            await MainActor.run {
                isLoading = false
                
                if success {
                    alertMessage = "购买成功！感谢您的支持，现在可以终身无限制使用所有功能了。"
                    showingAlert = true
                    
                    // 延迟关闭界面
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } else {
                    alertMessage = subscriptionManager.purchaseError ?? "购买失败，请稍后重试。"
                    showingAlert = true
                }
            }
        }
    }
    
    /// 恢复购买
    private func restorePurchases() {
        isLoading = true
        
        Task {
            await subscriptionManager.restorePurchases()
            
            await MainActor.run {
                isLoading = false
                
                if subscriptionManager.isSubscribed {
                    alertMessage = "购买记录恢复成功！"
                    showingAlert = true
                    
                    // 延迟关闭界面
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } else {
                    alertMessage = subscriptionManager.purchaseError ?? "未找到购买记录。"
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - 预览
struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}