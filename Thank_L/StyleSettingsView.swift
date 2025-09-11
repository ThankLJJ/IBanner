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
    
    // MARK: - 状态属性
    @State private var showingColorPicker = false
    @State private var colorPickerType: ColorPickerType = .text
    @State private var tempColor: Color = .white
    @State private var showingImagePicker = false
    @State private var selectedImage: Image? = nil
    
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
            .navigationTitle("样式设置")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
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
    }
    
    // MARK: - 预览区域
    private var previewSection: some View {
        VStack(spacing: 12) {
            Text("预览效果")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 预览容器
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bannerStyle.backgroundColor)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Text(bannerStyle.text.isEmpty ? "预览文字" : bannerStyle.text)
                    .font(.system(
                        size: min(bannerStyle.fontSize * 0.4, 24),
                        weight: bannerStyle.isBold ? .bold : .regular
                    ))
                    .foregroundColor(bannerStyle.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - 文字设置区域
    private var textSettingsSection: some View {
        VStack(spacing: 16) {
            Text("文字设置")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 字体大小设置
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("字体大小")
                    Spacer()
                    Text("\(Int(bannerStyle.fontSize))")
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: $bannerStyle.fontSize,
                    in: 20...100,
                    step: 2
                ) {
                    Text("字体大小")
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
                Text("粗体")
                Spacer()
                Toggle("", isOn: $bannerStyle.isBold)
            }
            
            Divider()
            
            // 字体样式选择
            VStack(alignment: .leading, spacing: 12) {
                Text("字体样式")
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
                .fill(Color(.systemGray6))
                #else
                .fill(Color.gray.opacity(0.1))
                #endif
        )
    }
    
    // MARK: - 颜色设置区域
    private var colorSettingsSection: some View {
        VStack(spacing: 16) {
            Text("颜色设置")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 文字颜色
            VStack(alignment: .leading, spacing: 12) {
                Text("文字颜色")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        colorButton(color: color, isSelected: bannerStyle.textColor == color) {
                            bannerStyle.textColor = color
                        }
                    }
                    
                    // 自定义颜色按钮
                    customColorButton {
                        colorPickerType = .text
                        tempColor = bannerStyle.textColor
                        showingColorPicker = true
                    }
                }
            }
            
            Divider()
            
            // 背景颜色
            VStack(alignment: .leading, spacing: 12) {
                Text("背景颜色")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        colorButton(color: color, isSelected: bannerStyle.backgroundColor == color) {
                            bannerStyle.backgroundColor = color
                        }
                    }
                    
                    // 自定义颜色按钮
                    customColorButton {
                        colorPickerType = .background
                        tempColor = bannerStyle.backgroundColor
                        showingColorPicker = true
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .fill(Color(.systemGray6))
                #else
                .fill(Color.gray.opacity(0.1))
                #endif
        )
    }
    
    // MARK: - 背景设置区域
    private var backgroundSettingsSection: some View {
        VStack(spacing: 16) {
            Text("背景设置")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 背景类型选择
            VStack(alignment: .leading, spacing: 12) {
                Text("背景类型")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    ForEach(BackgroundType.allCases, id: \.self) { type in
                        backgroundTypeButton(type)
                    }
                }
            }
            
            // 图片背景设置
            if bannerStyle.backgroundType == .image {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("背景图片")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // 图片预览区域 - 可直接点击选择
                    Button(action: {
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
                                        Text("加载中...")
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
                                    Text("点击选择背景图片")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    Text("支持 JPG、PNG 格式")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    // 显示当前选中的图片
                    if bannerStyle.backgroundType == .image,
                       let imagePath = bannerStyle.backgroundImagePath,
                       !imagePath.isEmpty {
                        HStack {
                            Text("已选择: \(URL(fileURLWithPath: imagePath).lastPathComponent)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button("移除") {
                                 // 删除图片文件
                                 BannerDataManager.shared.deleteBackgroundImage(at: imagePath)
                                 // 清除路径
                                 bannerStyle.backgroundImagePath = nil
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
                                Text("图片透明度")
                                Spacer()
                                Text("\(Int(bannerStyle.backgroundImageOpacity * 100))%")
                                    .foregroundColor(.secondary)
                            }
                            
                            Slider(
                                value: $bannerStyle.backgroundImageOpacity,
                                in: 0.1...1.0,
                                step: 0.1
                            ) {
                                Text("图片透明度")
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
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .fill(Color(.systemGray6))
                #else
                .fill(Color.gray.opacity(0.1))
                #endif
        )
    }
    
    // MARK: - 动画设置区域
    private var animationSettingsSection: some View {
        VStack(spacing: 16) {
            Text("动画效果")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 动画类型选择
            VStack(alignment: .leading, spacing: 12) {
                Text("动画类型")
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
                        Text("动画速度")
                        Spacer()
                        Text(String(format: "%.1fx", bannerStyle.animationSpeed))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: $bannerStyle.animationSpeed,
                        in: 0.5...3.0,
                        step: 0.1
                    ) {
                        Text("动画速度")
                    } minimumValueLabel: {
                        Text("慢")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("快")
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
                .fill(Color(.systemGray6))
                #else
                .fill(Color.gray.opacity(0.1))
                #endif
        )
    }
    
    // MARK: - 预设样式区域
    private var presetStylesSection: some View {
        VStack(spacing: 16) {
            Text("快速样式")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                presetStyleButton("演唱会", .red, .white, .blink)
                presetStyleButton("生日派对", .pink, .white, .gradient)
                presetStyleButton("接机牌", .white, .black, .none)
                presetStyleButton("代驾服务", .blue, .white, .breathing)
                presetStyleButton("谢谢", .green, .white, .none)
                presetStyleButton("请稍等", .yellow, .black, .blink)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .fill(Color(.systemGray6))
                #else
                .fill(Color.gray.opacity(0.1))
                #endif
        )
    }
    
    // MARK: - 颜色选择器弹窗
    private var colorPickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                ColorPicker(
                    "选择颜色",
                    selection: $tempColor,
                    supportsOpacity: false
                )
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle(colorPickerType == .text ? "文字颜色" : "背景颜色")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        showingColorPicker = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
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
    }
    
    // MARK: - 辅助方法
    private func fontStyleButton(_ fontStyle: FontStyle) -> some View {
        Button(action: {
            bannerStyle.fontStyle = fontStyle
        }) {
            VStack(spacing: 4) {
                Text(fontStyle.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
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
    }
    
    /// 动画类型按钮
    private func animationTypeButton(_ animationType: AnimationType) -> some View {
        Button {
            bannerStyle.animationType = animationType
        } label: {
            VStack(spacing: 8) {
                Text(animationType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
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
                Text("选择背景图片")
                    .font(.headline)
                
                #if os(iOS)
                 Button("从相册选择") {
                     // 延迟执行以避免模态视图冲突
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                         // 创建协调器
                         imagePickerCoordinator = ImagePickerCoordinator { image in
                             selectedUIImage = image
                             selectedImage = Image(uiImage: image)
                             
                             // 保存图片并获取路径
                             if let savedPath = BannerDataManager.shared.saveBackgroundImage(image) {
                                 bannerStyle.backgroundImagePath = savedPath
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
                Button("从文件选择") {
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.image]
                    panel.allowsMultipleSelection = false
                    
                    if panel.runModal() == .OK,
                       let url = panel.url,
                       let image = NSImage(contentsOf: url) {
                        selectedNSImage = image
                        selectedImage = Image(nsImage: image)
                        
                        // 保存图片并获取路径
                        if let savedPath = BannerDataManager.shared.saveBackgroundImage(image) {
                            bannerStyle.backgroundImagePath = savedPath
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
                    Button("移除背景图片") {
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
            .navigationTitle("背景图片")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
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