//
//  HistoryView.swift
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

/// 历史记录视图
/// 显示和管理用户最近使用的横幅记录
struct HistoryView: View {
    @Binding var bannerStyle: BannerStyle
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = BannerDataManager.shared
    
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var selectedHistory: BannerHistory?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                if !dataManager.historyList.isEmpty {
                    searchSection
                }
                
                // 历史记录列表
                if filteredHistory.isEmpty {
                    emptyStateView
                } else {
                    historyList
                }
            }
            .navigationTitle("历史记录")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !dataManager.historyList.isEmpty {
                        Button("清空") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    if !dataManager.historyList.isEmpty {
                        Button("清空") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            #endif
        }
        .alert("清空历史记录", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("清空", role: .destructive) {
                dataManager.clearAllHistory()
            }
        } message: {
            Text("确定要清空所有历史记录吗？此操作无法撤销。")
        }
    }
    
    // MARK: - 搜索区域
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索历史记录...", text: $searchText)
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
        .padding(.bottom, 16)
    }
    
    // MARK: - 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("暂无历史记录")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("使用横幅展示功能后，记录会显示在这里")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - 历史记录列表
    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredHistory, id: \.id) { history in
                    historyCard(history)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - 历史记录卡片
    private func historyCard(_ history: BannerHistory) -> some View {
        Button {
            applyHistory(history)
        } label: {
            VStack(spacing: 12) {
                // 预览区域
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(history.style.backgroundColor)
                        .frame(height: 80)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Text(history.text)
                        .font(.system(
                            size: min(history.style.fontSize * 0.25, 16),
                            weight: history.style.isBold ? .bold : .regular
                        ))
                        .foregroundColor(history.style.textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 12)
                }
                
                // 记录信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // 文字内容（截断显示）
                        Text(history.text)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        // 时间和样式信息
                        HStack(spacing: 12) {
                            // 时间
                            Text(formatDate(history.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // 分隔符
                            Circle()
                                .fill(Color.secondary)
                                .frame(width: 2, height: 2)
                            
                            // 动画类型
                            HStack(spacing: 4) {
                                Image(systemName: animationIcon(for: history.style.animationType))
                                Text(history.style.animationType.displayName)
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    // 删除按钮
                    Button {
                        deleteHistory(history)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
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
    /// 过滤后的历史记录列表
    private var filteredHistory: [BannerHistory] {
        if searchText.isEmpty {
            return dataManager.historyList
        } else {
            return dataManager.historyList.filter {
                $0.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - 辅助方法
    /// 应用历史记录
    private func applyHistory(_ history: BannerHistory) {
        bannerStyle.text = history.text
        bannerStyle.fontSize = history.style.fontSize
        bannerStyle.textColor = history.style.textColor
        bannerStyle.backgroundColor = history.style.backgroundColor
        bannerStyle.animationType = history.style.animationType
        bannerStyle.animationSpeed = history.style.animationSpeed
        bannerStyle.isBold = history.style.isBold
        
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
    
    /// 删除历史记录
    private func deleteHistory(_ history: BannerHistory) {
        withAnimation(.easeInOut(duration: 0.3)) {
            dataManager.deleteHistory(history)
        }
        
        // 添加触觉反馈（仅iOS）
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
        impactFeedback.impactOccurred()
        #endif
    }
    
    /// 格式化日期显示
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.dateFormat = "今天 HH:mm"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
            formatter.dateFormat = "昨天 HH:mm"
        } else if calendar.component(.year, from: date) == calendar.component(.year, from: Date()) {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        
        return formatter.string(from: date)
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
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(bannerStyle: .constant(BannerStyle(
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