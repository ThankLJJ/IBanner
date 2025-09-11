//
//  TemplateView.swift
//  iBanner - 临时横幅工具
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

/// 模板选择视图
/// 提供内置模板和用户收藏模板的选择功能
struct TemplateView: View {
    @Binding var bannerStyle: BannerStyle
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = BannerDataManager.shared
    
    @State private var selectedCategory: TemplateCategory = .all
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                searchSection
                
                // 分类选择
                categorySection
                
                // 模板列表
                templateList
            }
            .navigationTitle("模板库")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 搜索区域
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索模板...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .fill(Color(.systemGray6))
                #else
                .fill(Color.gray.opacity(0.1))
                #endif
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    // MARK: - 分类选择
    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TemplateCategory.allCases, id: \.self) { category in
                    categoryButton(category)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - 模板列表
    private var templateList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredTemplates, id: \.id) { template in
                    templateCard(template)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - 分类按钮
    private func categoryButton(_ category: TemplateCategory) -> some View {
        Button {
            selectedCategory = category
        } label: {
            Text(category.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selectedCategory == category ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        #if os(iOS)
                        .fill(selectedCategory == category ? Color.blue : Color(.systemGray5))
                        #else
                        .fill(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                        #endif
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 模板卡片
    private func templateCard(_ template: BannerTemplate) -> some View {
        Button {
            applyTemplate(template)
        } label: {
            VStack(spacing: 12) {
                // 预览区域
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(template.style.backgroundColor)
                        .frame(height: 80)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Text(template.text)
                        .font(.system(
                            size: min(template.style.fontSize * 0.25, 16),
                            weight: template.style.isBold ? .bold : .regular
                        ))
                        .foregroundColor(template.style.textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                }
                
                // 模板信息
                VStack(spacing: 4) {
                    Text(template.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        // 分类标签
                        Text(template.category.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    #if os(iOS)
                                    .fill(Color(.systemGray6))
                                    #else
                                    .fill(Color.gray.opacity(0.1))
                                    #endif
                            )
                        
                        Spacer()
                        
                        // 动画类型图标
                        Image(systemName: animationIcon(for: template.style.animationType))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    #if os(iOS)
                    .fill(Color(.systemBackground))
                    #else
                    .fill(Color(NSColor.controlBackgroundColor))
                    #endif
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 计算属性
    /// 过滤后的模板列表
    private var filteredTemplates: [BannerTemplate] {
        var templates = BannerTemplate.builtInTemplates
        
        // 按分类过滤
        if selectedCategory != .all {
            templates = templates.filter { $0.category == selectedCategory }
        }
        
        // 按搜索文本过滤
        if !searchText.isEmpty {
            templates = templates.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.text.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return templates
    }
    
    // MARK: - 辅助方法
    /// 应用模板
    private func applyTemplate(_ template: BannerTemplate) {
        bannerStyle.text = template.text
        bannerStyle.fontSize = template.style.fontSize
        bannerStyle.textColor = template.style.textColor
        bannerStyle.backgroundColor = template.style.backgroundColor
        bannerStyle.animationType = template.style.animationType
        bannerStyle.animationSpeed = template.style.animationSpeed
        bannerStyle.isBold = template.style.isBold
        
        // 添加触觉反馈（仅iOS）
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
        
        // 延迟关闭，让用户看到选择效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
    
    /// 获取动画类型对应的图标
    private func animationIcon(for animation: AnimationType) -> String {
        switch animation {
        case .none:
            return "minus"
        case .scroll:
            return "arrow.left.arrow.right"
        case .blink:
            return "lightbulb"
        case .gradient:
            return "paintpalette"
        case .breathing:
            return "heart.fill"
        case .typewriter:
            return "keyboard"
        case .randomFlash:
            return "sparkles"
        }
    }
}

// MARK: - 预览
struct TemplateView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateView(bannerStyle: .constant(BannerStyle(
            text: "预览文字",
            fontSize: 48,
            textColor: .white,
            backgroundColor: .blue,
            animationType: .scroll,
            animationSpeed: 1.0,
            isBold: true
        )))
    }
}