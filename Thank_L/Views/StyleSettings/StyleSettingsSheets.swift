//
//  StyleSettingsSheets.swift
//  Thank_L
//
//  StyleSettingsView 的Sheet组件
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct ColorPickerSheet: View {
    @Binding var bannerStyle: BannerStyle
    @Binding var isPresented: Bool
    @Binding var tempColor: Color
    let pickerType: ColorSettingsSection.ColorPickerType

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(L10n.StyleSettings.selectColor)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                RoundedRectangle(cornerRadius: 12)
                    .fill(tempColor)
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                ColorPicker("", selection: $tempColor, supportsOpacity: false)
                    .labelsHidden()
                    #if os(macOS)
                    .frame(width: 200, height: 40)
                    #endif
            }
            .padding(.top, 20)

            Spacer()
        }
        .frame(minWidth: 300, minHeight: 300)
        .padding()
        .navigationTitle(pickerType == .text ? L10n.StyleSettings.textSettingsTitle : L10n.StyleSettings.bgColorTitle)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.App.cancel) {
                    isPresented = false
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.App.confirm) {
                    if pickerType == .text {
                        bannerStyle.textColor = tempColor
                    } else {
                        bannerStyle.backgroundColor = tempColor
                    }
                    isPresented = false
                }
                .fontWeight(.semibold)
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 350)
        #endif
    }
}

struct ImagePickerSheet: View {
    @Binding var bannerStyle: BannerStyle
    @Binding var isPresented: Bool
    @Binding var selectedImage: Image?
    let onImagePicked: (Image) -> Void
    let onClearImage: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(L10n.StyleSettings.selectBackgroundImage)
                    .font(.headline)

                #if os(iOS)
                Button(L10n.StyleSettings.selectFromAlbum) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let coordinator = ImagePickerCoordinator { image in
                            let swiftUIImage = Image(uiImage: image)
                            selectedImage = swiftUIImage

                            if let savedPath = BannerDataManager.shared.saveBackgroundImage(image) {
                                bannerStyle.backgroundImagePath = savedPath
                                bannerStyle.backgroundType = .image
                            }

                            isPresented = false
                        }

                        let imagePicker = UIImagePickerController()
                        imagePicker.sourceType = .photoLibrary
                        imagePicker.delegate = coordinator

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
                Button(L10n.StyleSettings.selectFromFile) {
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.image]
                    panel.allowsMultipleSelection = false

                    if panel.runModal() == .OK,
                       let url = panel.url,
                       let image = NSImage(contentsOf: url) {
                        let swiftUIImage = Image(nsImage: image)
                        selectedImage = swiftUIImage

                        if let savedPath = BannerDataManager.shared.saveBackgroundImage(image) {
                            bannerStyle.backgroundImagePath = savedPath
                            bannerStyle.backgroundType = .image
                        }

                        isPresented = false
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                #endif

                if selectedImage != nil {
                    Button(L10n.StyleSettings.removeBackgroundImage) {
                        onClearImage()
                        isPresented = false
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
            .navigationTitle(L10n.StyleSettings.backgroundImage)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.App.cancel) {
                        isPresented = false
                    }
                }
            }
        }
    }
}
