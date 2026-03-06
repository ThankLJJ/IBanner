//
//  ColorExtensions.swift
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

// MARK: - Color扩展支持Codable
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)

        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        #if os(iOS)
        let uiColor = UIColor(self)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif os(macOS)
        let nsColor = NSColor(self)
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif

        try container.encode(Double(red), forKey: .red)
        try container.encode(Double(green), forKey: .green)
        try container.encode(Double(blue), forKey: .blue)
        try container.encode(Double(alpha), forKey: .alpha)
    }
}

// MARK: - 跨平台系统颜色
extension Color {
    /// 跨平台系统背景颜色
    static var platformBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }

    /// 跨平台二级系统背景颜色
    static var platformSecondaryBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }

    /// 跨平台三级系统背景颜色
    static var platformTertiaryBackground: Color {
        #if os(iOS)
        return Color(UIColor.tertiarySystemBackground)
        #else
        return Color(NSColor.controlBackgroundColor).opacity(0.5)
        #endif
    }

    /// 跨平台系统灰色6
    static var platformSystemGray6: Color {
        #if os(iOS)
        return Color(UIColor.systemGray6)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }

    /// 跨平台分组背景颜色
    static var platformGroupedBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemGroupedBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }

    /// 跨平台二级分组背景颜色
    static var platformSecondaryGroupedBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
}
