//
//  PickItemImageViewModel.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import SwiftUI
import CoreData

struct PickItemImageViewModelDependencies {
    var imageRepo: ImageRepositoryProtocol
    var imagePicker: ImagePicker
    
    static func make(from other: MakeCategoryViewModelDependencies) -> PickItemImageViewModelDependencies {
        return PickItemImageViewModelDependencies(imageRepo: other.imageRepo, imagePicker: other.imagePicker)
    }
    
    static func make(from other: MakeItemViewModelDependencies) -> PickItemImageViewModelDependencies {
        return PickItemImageViewModelDependencies(imageRepo: other.itemImageRepo, imagePicker: other.imagePicker)
    }
}

class PickItemImageViewModel: ObservableObject {
    let dependencies: PickItemImageViewModelDependencies
    
    @Published var isPresenting: Bool = false
    @Published var isImagePicked: Bool = false
    @Published var pickedImage = UIImage()
    
    init(dependencies: PickItemImageViewModelDependencies) {
        self.dependencies = dependencies
        
        dependencies.imagePicker.delegate = self
    }
    
    func buildImagePickerView() -> some View {
        return dependencies.imagePicker.buildView()
    }
    
    func captureImage() {
        dependencies.imagePicker.sourceType = .camera
        
        self.isPresenting = true
    }
    
    func uploadImage() {
        dependencies.imagePicker.sourceType = .photoLibrary
        
        self.isPresenting = true
    }
}

// # ImagePickerDelegate
extension PickItemImageViewModel: ImagePickerDelegate {
    func onPicked(image: UIImage) {
        pickedImage = image
        
        self.isImagePicked = true
        self.isPresenting = false
    }
    
    func onCancel() {
        self.isPresenting = false
    }
    
    func onError(_ error: Error) {
        self.isPresenting = false
    }
}
