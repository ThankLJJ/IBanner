//
//  FontStyleModifier.swift
//  Thank_L
//
//  字体样式路由器 - 根据字体类型分发到对应的样式处理器
//

import SwiftUI

struct FontStyleModifier: ViewModifier {
    let fontStyle: FontStyle
    let artisticStyle: ArtisticStyle
    let artisticConfig: ArtisticStyleConfig
    let neonStyle: NeonStyle
    let neonConfig: NeonStyleConfig
    let textColor: Color

    func body(content: Content) -> some View {
        switch fontStyle {
        case .normal:
            content

        case .artistic:
            content
                .modifier(ArtisticStyleModifier(
                    artisticStyle: artisticStyle,
                    artisticConfig: artisticConfig,
                    textColor: textColor
                ))

        case .neon:
            content
                .modifier(NeonStyleModifier(
                    neonStyle: neonStyle,
                    neonConfig: neonConfig,
                    textColor: textColor
                ))
        }
    }
}
