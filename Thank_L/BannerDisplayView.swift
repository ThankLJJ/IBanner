//
//  BannerDisplayView.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// 横幅全屏展示页面
/// 支持多种动画效果：滚动、闪烁、渐变、呼吸灯等
struct BannerDisplayView: View {
    // MARK: - 属性
    let bannerStyle: BannerStyle
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 动画状态
    @State private var scrollOffset: CGFloat = 0
    @State private var isBlinking: Bool = false
    @State private var gradientOffset: CGFloat = 0
    @State private var breathingOpacity: Double = 1.0
    @State private var isAnimating: Bool = false
    
    // 新动效状态变量
    @State private var typewriterText: String = ""
    @State private var typewriterIndex: Int = 0
    @State private var randomFlashPositions: [CGPoint] = []
    @State private var randomFlashOpacities: [Double] = []
    @State private var randomFlashTimer: Timer?
    
    // 屏幕尺寸
    @State private var screenSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景层
                backgroundView
                    .ignoresSafeArea(.all)
                
                // 文字内容层
                textContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                screenSize = geometry.size
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
            // 手势处理
            .onTapGesture(count: 2) {
                // 双击退出
                dismiss()
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // 向下滑动退出
                        if value.translation.height > 100 {
                            dismiss()
                        }
                    }
            )
        }
        #if os(iOS)
        .navigationBarHidden(true)
        .statusBarHidden(true)
        .ignoresSafeArea(.all) // 默认全屏显示
        #elseif os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all) // 默认全屏显示
        #endif
        .preferredColorScheme(.dark) // 确保状态栏为浅色
    }
    
    // MARK: - 背景视图
    @ViewBuilder
    private var backgroundView: some View {
        ZStack {
            // 基础背景
            if bannerStyle.backgroundType == .image && bannerStyle.backgroundImagePath != nil {
                // 图片背景 - 自适应屏幕大小
                AsyncImage(url: getImageURL()) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill) // 填充整个屏幕，保持比例
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 占满整个容器
                        .clipped() // 裁剪超出部分
                        .opacity(bannerStyle.backgroundImageOpacity)
                } placeholder: {
                    // 加载中显示纯色背景
                    bannerStyle.backgroundColor
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // 纯色背景
                bannerStyle.backgroundColor
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // 动画效果层
            if bannerStyle.animationType == .gradient {
                // 彩虹渐变背景
                LinearGradient(
                    colors: [
                        .red, .orange, .yellow, .green, .blue, .purple, .pink
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(0.8) // 半透明以便与背景图片混合
                .offset(x: gradientOffset)
                .animation(
                    .linear(duration: 3.0 / bannerStyle.animationSpeed)
                    .repeatForever(autoreverses: false),
                    value: gradientOffset
                )
            }
        }
    }
    
    // MARK: - 文字内容视图
    @ViewBuilder
    private var textContentView: some View {
        switch bannerStyle.animationType {
        case .scroll:
            scrollingTextView
        case .blink:
            blinkingTextView
        case .breathing:
            breathingTextView
        case .typewriter:
            typewriterTextView
        case .randomFlash:
            randomFlashTextView
        default:
            staticTextView
        }
    }
    
    // MARK: - 静态文字视图
    private var staticTextView: some View {
        Text(bannerStyle.text)
            .font(.system(
                size: bannerStyle.fontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, 20)
            .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
    }
    
    // MARK: - 滚动文字视图
    private var scrollingTextView: some View {
        HStack(spacing: 0) {
            // 第一个文字实例
            Text(bannerStyle.text)
                .font(.system(
                    size: bannerStyle.fontSize,
                    weight: bannerStyle.isBold ? .bold : .regular
                ))
                .foregroundColor(bannerStyle.textColor)
                .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                .fixedSize()
            
            // 间距
            Spacer()
                .frame(width: screenSize.width * 0.5)
            
            // 第二个文字实例（用于无缝循环）
            Text(bannerStyle.text)
                .font(.system(
                    size: bannerStyle.fontSize,
                    weight: bannerStyle.isBold ? .bold : .regular
                ))
                .foregroundColor(bannerStyle.textColor)
                .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                .fixedSize()
        }
        .offset(x: scrollOffset)
        .animation(
            .linear(duration: 8.0 / bannerStyle.animationSpeed)
            .repeatForever(autoreverses: false),
            value: scrollOffset
        )
    }
    
    // MARK: - 闪烁文字视图
    private var blinkingTextView: some View {
        Text(bannerStyle.text)
            .font(.system(
                size: bannerStyle.fontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, 20)
            .opacity(isBlinking ? 0.3 : 1.0)
            .animation(
                .easeInOut(duration: 0.8 / bannerStyle.animationSpeed)
                .repeatForever(autoreverses: true),
                value: isBlinking
            )
    }
    
    // MARK: - 呼吸灯文字视图
    private var breathingTextView: some View {
        Text(bannerStyle.text)
            .font(.system(
                size: bannerStyle.fontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, 20)
            .opacity(breathingOpacity)
            .scaleEffect(breathingOpacity)
            .animation(
                .easeInOut(duration: 2.0 / bannerStyle.animationSpeed)
                .repeatForever(autoreverses: true),
                value: breathingOpacity
            )
    }
    
    // MARK: - 逐字显示文字视图
    private var typewriterTextView: some View {
        Text(typewriterText)
            .font(.system(
                size: bannerStyle.fontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            ))
            .foregroundColor(bannerStyle.textColor)
            .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, 20)
            .onAppear {
                startTypewriterAnimation()
            }
    }
    
    // MARK: - 随机闪现文字视图
    private var randomFlashTextView: some View {
        ZStack {
            ForEach(0..<randomFlashPositions.count, id: \.self) { index in
                if index < randomFlashOpacities.count {
                    Text(bannerStyle.text)
                        .font(.system(
                            size: bannerStyle.fontSize * 0.8, // 稍微小一点避免重叠
                            weight: bannerStyle.isBold ? .bold : .regular
                        ))
                        .foregroundColor(bannerStyle.textColor)
                        .modifier(FontStyleModifier(fontStyle: bannerStyle.fontStyle, textColor: bannerStyle.textColor))
                        .opacity(randomFlashOpacities[index])
                        .position(randomFlashPositions[index])
                        .scaleEffect(randomFlashOpacities[index])
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startRandomFlashAnimation()
        }
    }
    
    // MARK: - 辅助函数
    /// 获取背景图片URL
    private func getImageURL() -> URL? {
        guard let imagePath = bannerStyle.backgroundImagePath else { return nil }
        
        // 获取Documents目录
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsPath.appendingPathComponent(imagePath)
        
        // 检查文件是否存在
        if FileManager.default.fileExists(atPath: imageURL.path) {
            return imageURL
        }
        
        // 如果是内置资源，尝试从Bundle加载
        if let bundleURL = Bundle.main.url(forResource: imagePath.replacingOccurrences(of: ".jpg", with: "").replacingOccurrences(of: ".png", with: ""), withExtension: nil) {
            return bundleURL
        }
        
        return nil
    }
    
    // MARK: - 新动效控制方法
    /// 开始逐字显示动画
    private func startTypewriterAnimation() {
        typewriterText = ""
        typewriterIndex = 0
        
        let interval = 0.1 / bannerStyle.animationSpeed // 根据动画速度调整间隔
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if typewriterIndex < bannerStyle.text.count {
                let index = bannerStyle.text.index(bannerStyle.text.startIndex, offsetBy: typewriterIndex)
                typewriterText = String(bannerStyle.text[...index])
                typewriterIndex += 1
            } else {
                // 完成后暂停一段时间，然后重新开始
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 / bannerStyle.animationSpeed) {
                    startTypewriterAnimation()
                }
                timer.invalidate()
            }
        }
    }
    
    /// 开始随机闪现动画
    private func startRandomFlashAnimation() {
        // 初始化多个闪现位置
        let flashCount = 5
        randomFlashPositions = []
        randomFlashOpacities = Array(repeating: 0.0, count: flashCount)
        
        // 生成随机位置
        for _ in 0..<flashCount {
            let x = CGFloat.random(in: 50...(screenSize.width - 50))
            let y = CGFloat.random(in: 100...(screenSize.height - 100))
            randomFlashPositions.append(CGPoint(x: x, y: y))
        }
        
        // 启动定时器，随机闪现
        randomFlashTimer = Timer.scheduledTimer(withTimeInterval: 0.3 / bannerStyle.animationSpeed, repeats: true) { _ in
            let randomIndex = Int.random(in: 0..<flashCount)
            
            // 闪现效果
            withAnimation(.easeInOut(duration: 0.5 / bannerStyle.animationSpeed)) {
                randomFlashOpacities[randomIndex] = 1.0
            }
            
            // 淡出效果
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 / bannerStyle.animationSpeed) {
                withAnimation(.easeInOut(duration: 0.3 / bannerStyle.animationSpeed)) {
                    randomFlashOpacities[randomIndex] = 0.0
                }
            }
            
            // 随机更新位置
            if Bool.random() {
                let x = CGFloat.random(in: 50...(screenSize.width - 50))
                let y = CGFloat.random(in: 100...(screenSize.height - 100))
                randomFlashPositions[randomIndex] = CGPoint(x: x, y: y)
            }
        }
    }
    
    // MARK: - 动画控制方法
    /// 开始动画
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        switch bannerStyle.animationType {
        case .scroll:
            // 计算滚动距离
            #if os(iOS)
            let font = UIFont.systemFont(
                ofSize: bannerStyle.fontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            )
            #elseif os(macOS)
            let font = NSFont.systemFont(
                ofSize: bannerStyle.fontSize,
                weight: bannerStyle.isBold ? .bold : .regular
            )
            #endif
            let textWidth = bannerStyle.text.widthOfString(usingFont: font)
            scrollOffset = -(textWidth + screenSize.width * 0.5)
            
        case .blink:
            isBlinking = true
            
        case .gradient:
            gradientOffset = -screenSize.width
            
        case .breathing:
            breathingOpacity = 0.5
            
        case .typewriter:
            startTypewriterAnimation()
            
        case .randomFlash:
            startRandomFlashAnimation()
            
        case .none:
            break
        }
    }
    
    /// 停止动画
    private func stopAnimation() {
        // 停止随机闪现定时器
        randomFlashTimer?.invalidate()
        randomFlashTimer = nil
        
        // 重置动画状态
        typewriterText = ""
        typewriterIndex = 0
        randomFlashPositions = []
        randomFlashOpacities = []
        
        isAnimating = false
    }
}

// MARK: - String扩展
extension String {
    /// 计算字符串在指定字体下的宽度
    #if os(iOS)
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    #elseif os(macOS)
    func widthOfString(usingFont font: NSFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    #endif
}

// MARK: - 字体样式修饰符
struct FontStyleModifier: ViewModifier {
    let fontStyle: FontStyle
    let textColor: Color
    
    func body(content: Content) -> some View {
        switch fontStyle {
        case .normal:
            content
            
        case .artistic:
            content
                .shadow(color: textColor.opacity(0.3), radius: 2, x: 2, y: 2)
                .overlay(
                    content
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(
                                colors: [textColor, textColor.opacity(0.7), textColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .mask(content)
                )
                
        case .neon:
            content
                .foregroundColor(textColor)
                .shadow(color: textColor, radius: 5, x: 0, y: 0)
                .shadow(color: textColor, radius: 10, x: 0, y: 0)
                .shadow(color: textColor, radius: 15, x: 0, y: 0)
                .overlay(
                    content
                        .foregroundColor(.white)
                        .opacity(0.8)
                )
        }
    }
}

// MARK: - 预览
struct BannerDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 静态预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "🎉 欢迎使用 iBanner 🎉",
                    fontSize: 48,
                    textColor: .white,
                    backgroundColor: .blue,
                    animationType: .none
                )
            )
            .previewDisplayName("静态显示")
            
            // 滚动预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "📱 滚动横幅效果展示",
                    fontSize: 52,
                    textColor: .yellow,
                    backgroundColor: .black,
                    animationType: .scroll,
                    animationSpeed: 1.0
                )
            )
            .previewDisplayName("滚动效果")
            
            // 闪烁预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "✨ 闪烁灯牌效果 ✨",
                    fontSize: 56,
                    textColor: .white,
                    backgroundColor: .red,
                    animationType: .blink,
                    animationSpeed: 1.5,
                    isBold: true
                )
            )
            .previewDisplayName("闪烁效果")
            
            // 呼吸灯预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "💫 呼吸灯效果",
                    fontSize: 50,
                    textColor: .white,
                    backgroundColor: .purple,
                    animationType: .breathing,
                    animationSpeed: 0.8
                )
            )
            .previewDisplayName("呼吸灯效果")
            
            // 渐变背景预览
            BannerDisplayView(
                bannerStyle: BannerStyle(
                    text: "🌈 彩虹渐变背景",
                    fontSize: 48,
                    textColor: .white,
                    backgroundColor: .clear,
                    animationType: .gradient,
                    animationSpeed: 1.2,
                    isBold: true
                )
            )
            .previewDisplayName("渐变背景")
        }
    }
}