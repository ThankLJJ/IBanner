//
//  ContentView.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/12.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI
// 免费版本：移除StoreKit导入
// import StoreKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// 主界面视图
/// 提供横幅文字输入、样式设置、模板选择等核心功能
struct ContentView: View {
    // MARK: - 状态管理
    @StateObject private var dataManager = BannerDataManager.shared
    // 免费版本：移除订阅管理器
    // @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var bannerStyle = BannerStyle(
        text: "",
        fontSize: 48,
        textColor: .white,
        backgroundColor: .blue,
        animationType: .scroll,
        animationSpeed: 1.0,
        isBold: true
    )
    
    // MARK: - 界面状态
    @State private var showingBanner = false
    @State private var showingStyleSettings = false
    @State private var showingTemplates = false
    @State private var showingHistory = false
    // 免费版本：移除订阅界面状态
    // @State private var showingSubscription = false
    @State private var isTextFieldFocused = false
    
    // 免费版本：移除预览次数限制
    // @State private var previewCount = 0
    // private let maxFreePreview = 0 // 免费用户无法预览，需要订阅
    
    // MARK: - 主视图
    var body: some View {
        // 使用NavigationSplitView为iPad提供更好的布局体验
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad布局：使用NavigationSplitView
            NavigationSplitView {
                // 侧边栏：快速操作和设置
                sidebarContent
            } detail: {
                // 主内容区域
                mainContent
            }
            .navigationSplitViewStyle(.balanced)
        } else {
            // iPhone布局：使用NavigationView
            NavigationView {
                mainContent
            }
        }
        #else
        // macOS布局：使用NavigationView
        NavigationView {
            mainContent
        }
        #endif
    }
    
    // MARK: - 侧边栏内容（iPad专用）
    @ViewBuilder
    private var sidebarContent: some View {
        List {
            Section(L10n.QuickSettings.title) {
                NavigationLink {
                    StyleSettingsView(bannerStyle: $bannerStyle)
                } label: {
                    Label(L10n.Navigation.styleSettings, systemImage: "paintbrush")
                }

                NavigationLink {
                    TemplateView(bannerStyle: $bannerStyle)
                } label: {
                    Label(L10n.Navigation.templates, systemImage: "doc.text")
                }

                NavigationLink {
                    HistoryView(bannerStyle: $bannerStyle)
                } label: {
                    Label(L10n.Navigation.history, systemImage: "clock")
                        .badge(dataManager.historyList.count)
                }
            }
            
            Section(L10n.Content.preview) {
                // 小型预览区域
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(bannerStyle.backgroundColor)
                            .frame(height: 60)
                        
                        Text(bannerStyle.text.isEmpty ? "预览文字" : bannerStyle.text)
                            .font(.system(
                                size: 14,
                                weight: bannerStyle.isBold ? .bold : .regular
                            ))
                            .foregroundColor(bannerStyle.textColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 8)
                    }
                    
                    Button("全屏展示") {
                        showBanner()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(bannerStyle.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("iBanner")
        .listStyle(.sidebar)
    }
    
    // MARK: - 主内容区域
    @ViewBuilder
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 输入区域
                inputSection
                
                // 预览区域
                previewSection
                
                // 快速设置区域
                quickSettingsSection
                
                // 操作按钮区域
                actionButtonsSection
                
                // 历史记录和模板快捷入口（仅在iPhone上显示）
                #if os(iOS)
                if UIDevice.current.userInterfaceIdiom != .pad {
                    quickAccessSection
                }
                #else
                quickAccessSection
                #endif
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, adaptivePadding)
            .padding(.vertical, 16)
        }
        .navigationTitle("iBanner")
        #if os(iOS)
        .navigationBarTitleDisplayMode(UIDevice.current.userInterfaceIdiom == .pad ? .inline : .large)
        #endif
        .toolbar {
            // 仅在iPhone上显示工具栏菜单
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom != .pad {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(L10n.Navigation.styleSettings, systemImage: "paintbrush") {
                            showingStyleSettings = true
                        }
                        
                        Button(L10n.Navigation.templates, systemImage: "doc.text") {
                            showingTemplates = true
                        }
                        
                        Button(L10n.Navigation.history, systemImage: "clock") {
                            showingHistory = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("样式设置", systemImage: "paintbrush") {
                        showingStyleSettings = true
                    }
                    
                    Button("模板库", systemImage: "doc.text") {
                        showingTemplates = true
                    }
                    
                    Button("历史记录", systemImage: "clock") {
                        showingHistory = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            #endif
        }
        .fullScreenCover(isPresented: $showingBanner) {
            BannerDisplayView(bannerStyle: bannerStyle)
        }
        .sheet(isPresented: $showingStyleSettings) {
            StyleSettingsView(bannerStyle: $bannerStyle)
        }
        .sheet(isPresented: $showingTemplates) {
            TemplateView(bannerStyle: $bannerStyle)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(bannerStyle: $bannerStyle)
        }
        // 免费版本：移除订阅界面
        // .sheet(isPresented: $showingSubscription) {
        //     SubscriptionView()
        // }
        .onAppear {
            loadLastUsedStyle()
            // 免费版本：移除订阅检查
            // subscriptionManager.checkSubscriptionStatus()
        }
    }
    
    // MARK: - 计算属性：自适应边距
    private var adaptivePadding: CGFloat {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20
        #else
        return 20
        #endif
    }

    // MARK: - 输入区域
    private var inputSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("横幅内容")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                // 字符计数
                Text("\(bannerStyle.text.count)/100")
                    .font(.caption)
                    .foregroundColor(bannerStyle.text.count > 80 ? .orange : .secondary)
            }
            
            // 文字输入框
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    #if os(iOS)
                    .fill(Color(.systemGray6))
                    #else
                    .fill(Color.gray.opacity(0.1))
                    #endif
                    .frame(minHeight: 120)
                
                TextEditor(text: $bannerStyle.text)
                    .font(.system(size: 18))
                    .padding(12)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
                
                // 占位符
                if bannerStyle.text.isEmpty {
                    Text("输入要显示的文字...\n支持 Emoji 😊")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isTextFieldFocused ? Color.blue : Color.clear, lineWidth: 2)
            )
            .onTapGesture {
                isTextFieldFocused = true
            }
        }
    }
    
    // MARK: - 预览区域
    private var previewSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("预览效果")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                // 当前样式信息
                HStack(spacing: 8) {
                    Circle()
                        .fill(bannerStyle.textColor)
                        .frame(width: 12, height: 12)
                    
                    Circle()
                        .fill(bannerStyle.backgroundColor)
                        .frame(width: 12, height: 12)
                    
                    Text(bannerStyle.animationType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 预览容器
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(bannerStyle.backgroundColor)
                    .frame(height: 100)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Text(bannerStyle.text.isEmpty ? "预览文字" : bannerStyle.text)
                    .font(.system(
                        size: min(bannerStyle.fontSize * 0.3, 20),
                        weight: bannerStyle.isBold ? .bold : .regular
                    ))
                    .foregroundColor(bannerStyle.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
            }
            .onTapGesture {
                // 点击预览区域打开样式设置
                showingStyleSettings = true
            }
        }
    }
    
    // MARK: - 快速设置区域
    private var quickSettingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("快速设置")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // 快速颜色选择
            VStack(alignment: .leading, spacing: 12) {
                Text("颜色主题")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        quickColorTheme("经典", .white, .blue)
                        quickColorTheme("应援", .white, .red)
                        quickColorTheme("生日", .white, .pink)
                        quickColorTheme("接机", .black, .white)
                        quickColorTheme("代驾", .white, .green)
                        quickColorTheme("谢谢", .white, .orange)
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // 快速动画选择
            VStack(alignment: .leading, spacing: 12) {
                Text("动画效果")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(AnimationType.allCases.prefix(4), id: \.self) { animation in
                            quickAnimationButton(animation)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                #if os(iOS)
                .fill(Color(.systemGray6))
                #else
                .fill(Color.gray.opacity(0.1))
                #endif
        )
    }
    
    // MARK: - 操作按钮区域
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // 主要操作按钮
            HStack(spacing: 16) {
                // 样式设置按钮
                Button {
                    showingStyleSettings = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "paintbrush.pointed")
                        Text("样式设置")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // 模板选择按钮
                Button {
                    showingTemplates = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                        Text("选择模板")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            
            // 展示按钮
            Button {
                showBanner()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text(getShowButtonText())
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
            .disabled(bannerStyle.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(bannerStyle.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
        }
    }
    
    // MARK: - 快捷入口区域
    private var quickAccessSection: some View {
        HStack(spacing: 16) {
            // 历史记录
            Button {
                showingHistory = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                    
                    Text("历史记录")
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Text("\(dataManager.historyList.count)条")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        #if os(iOS)
                        .fill(Color(.systemGray6))
                        #else
                        .fill(Color.gray.opacity(0.1))
                        #endif
                )
            }
            
            // 模板库
            Button {
                showingTemplates = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                    
                    Text("模板库")
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Text("\(BannerTemplate.builtInTemplates.count)个")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        #if os(iOS)
                        .fill(Color(.systemGray6))
                        #else
                        .fill(Color.gray.opacity(0.1))
                        #endif
                )
            }
        }
    }
    
    // MARK: - 辅助方法
    /// 快速颜色主题按钮
    private func quickColorTheme(_ name: String, _ textColor: Color, _ bgColor: Color) -> some View {
        Button {
            bannerStyle.textColor = textColor
            bannerStyle.backgroundColor = bgColor
        } label: {
            VStack(spacing: 6) {
                // 颜色预览
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(bgColor)
                        .frame(width: 60, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(bgColor == .white ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    
                    Text("Aa")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor)
                }
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /// 快速动画按钮
    private func quickAnimationButton(_ animation: AnimationType) -> some View {
        Button {
            bannerStyle.animationType = animation
        } label: {
            VStack(spacing: 6) {
                // 动画图标
                Image(systemName: animationIcon(for: animation))
                    .font(.system(size: 20))
                    .foregroundColor(bannerStyle.animationType == animation ? .blue : .secondary)
                    .frame(width: 40, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(bannerStyle.animationType == animation ? Color.blue.opacity(0.1) : Color.clear)
                    )
                
                Text(animation.displayName)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
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
        case .wave:
            return "water.waves"
        case .bounce:
            return "arrow.up.backward"
        case .particles:
            return "sparkles"
        case .led:
            return "grid"
        }
    }
    
    /// 显示横幅
    private func showBanner() {
        // 免费版本：直接显示横幅，无需付费检查
        displayBanner()
    }
    
    /// 实际显示横幅的方法
    private func displayBanner() {
        // 保存到历史记录
        dataManager.addHistory(bannerStyle)
        
        // 保存当前样式
        saveCurrentStyle()
        
        // 显示横幅
        showingBanner = true
    }
    
    /// 加载上次使用的样式
    private func loadLastUsedStyle() {
        if let styleData = UserDefaults.standard.data(forKey: "LastUsedStyle"),
           let style = try? JSONDecoder().decode(BannerStyle.self, from: styleData) {
            bannerStyle = style
            bannerStyle.text = "" // 清空文字内容
        }
    }
    
    /// 保存当前样式
    private func saveCurrentStyle() {
        if let styleData = try? JSONEncoder().encode(bannerStyle) {
            UserDefaults.standard.set(styleData, forKey: "LastUsedStyle")
        }
    }
    
    // 免费版本：移除预览次数相关方法
    // /// 加载预览次数
    // private func loadPreviewCount() {
    //     previewCount = UserDefaults.standard.integer(forKey: "PreviewCount")
    // }
    // 
    // /// 保存预览次数
    // private func savePreviewCount() {
    //     UserDefaults.standard.set(previewCount, forKey: "PreviewCount")
    // }
    
    /// 获取展示按钮文本
    private func getShowButtonText() -> String {
        // 免费版本：统一显示"开始展示"
        return "开始展示"
    }
}

// MARK: - 预览
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
