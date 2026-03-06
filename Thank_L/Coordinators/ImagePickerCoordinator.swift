//
//  ImagePickerCoordinator.swift
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

#if os(iOS)
// MARK: - ImagePickerCoordinator (iOS)
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
#elseif os(macOS)
// MARK: - ImagePickerCoordinator (macOS)
class ImagePickerCoordinator: NSObject, NSOpenPanelDelegate {
    let onImagePicked: (NSImage) -> Void

    init(onImagePicked: @escaping (NSImage) -> Void) {
        self.onImagePicked = onImagePicked
    }
}
#endif
