//
//  StyleSettingsComponents.swift
//  Thank_L
//
//  StyleSettingsView 的可复用组件
//

import SwiftUI

struct FontStyleButton: View {
    let fontStyle: FontStyle
    let isSelected: Bool
    let isSubscribed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if fontStyle.isPremium && !isSubscribed {
                action()
                return
            }
            action()
        }) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(fontStyle.displayName)
                        .font(.caption)
                        .fontWeight(.medium)

                    if fontStyle.isPremium && !isSubscribed {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                }

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
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct BackgroundTypeButton: View {
    let type: BackgroundType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(type.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                )
        }
    }
}

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                )
                .overlay(
                    color == .white ?
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    : nil
                )
        }
        .buttonStyle(.plain)
    }
}

struct CustomColorButton: View {
    let action: () -> Void
    
    var body: some View {
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
        .buttonStyle(.plain)
    }
}

#if os(macOS)
struct CustomColorButtonMacOS: View {
    @Binding var selectedColor: Color
    
    var body: some View {
        ZStack {
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

            ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                .labelsHidden()
                .opacity(0.02)
                .frame(width: 40, height: 40)
        }
    }
}
#endif

struct AnimationTypeButton: View {
    let animationType: AnimationType
    let isSelected: Bool
    let isSubscribed: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            if animationType.isPremium && !isSubscribed {
                action()
                return
            }
            action()
        } label: {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text(animationType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if animationType.isPremium && !isSubscribed {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }

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
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? Color.blue : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PresetStyleButton: View {
    let name: String
    let bgColor: Color
    let textColor: Color
    let animation: AnimationType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
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
}

struct ArtisticStyleButton: View {
    let style: ArtisticStyle
    let isSelected: Bool
    let isSubscribed: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            if style.isPremium && !isSubscribed {
                action()
                return
            }
            action()
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(style.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    if style.isPremium && !isSubscribed {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                }
                
                Text(style.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct NeonStyleButton: View {
    let style: NeonStyle
    let isSelected: Bool
    let isSubscribed: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            if style.isPremium && !isSubscribed {
                action()
                return
            }
            action()
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(style.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    if style.isPremium && !isSubscribed {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                }
                
                Text(style.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct ConfigSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let displayValue: String?

    init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 1,
        displayValue: String? = nil
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.displayValue = displayValue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text(displayValue ?? String(format: "%.1f", value))
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $value, in: range, step: step) {
                Text(title)
            } minimumValueLabel: {
                Text(String(format: "%.0f", range.lowerBound))
                    .font(.caption)
                    .foregroundColor(.secondary)
            } maximumValueLabel: {
                Text(String(format: "%.0f", range.upperBound))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
