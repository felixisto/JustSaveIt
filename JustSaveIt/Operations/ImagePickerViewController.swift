//
//  ImagePickerViewController.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import SwiftUI
import UIKit

final public class ImagePickerViewController: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIImagePickerController
    
    var delegate: ImagePickerDelegate?
    
    @Environment(\.presentationMode) private var presentationMode
    
    private let sourceType: UIImagePickerController.SourceType
    
    init(sourceType: UIImagePickerController.SourceType, delegate: ImagePickerDelegate? = nil) {
        self.sourceType = sourceType
        self.delegate = delegate
    }
    
    // # UIViewControllerRepresentable

    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(presentationMode: presentationMode, sourceType: sourceType)
        coordinator.delegate = delegate
        return coordinator
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerViewController>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerViewController>) {

    }
    
    // # Coordinator
    
    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var delegate: ImagePickerDelegate?
        
        @Binding private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType

        init(presentationMode: Binding<PresentationMode>,
             sourceType: UIImagePickerController.SourceType) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
        }

        public func imagePickerController(_ picker: UIImagePickerController,
                                          didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            delegate?.onPicked(image: uiImage)
            presentationMode.dismiss()

        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            delegate?.onCancel()
            presentationMode.dismiss()
        }
    }
}
