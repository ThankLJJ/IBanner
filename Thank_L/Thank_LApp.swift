//
//  Thank_LApp.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/10.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI

/// iBanner应用主入口
/// 一款轻量级的iOS横幅展示工具，支持文字、表情、动态效果展示
@main
struct Thank_LApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // 默认使用浅色模式以获得更好的横幅展示效果
        }
    }
}
