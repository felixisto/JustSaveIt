//
//  ImagePicker.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import UIKit
import SwiftUI

class ImagePicker {
    var delegate: ImagePickerDelegate?
    var sourceType: UIImagePickerController.SourceType = .camera
    
    func buildView() -> some View {
        return ImagePickerViewController(sourceType: sourceType, delegate: delegate)
    }
}

protocol ImagePickerDelegate {
    func onPicked(image: UIImage)
    
    func onCancel()
    
    func onError(_ error: Error)
}
