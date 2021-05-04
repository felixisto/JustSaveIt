//
//  PickItemImageView.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import SwiftUI
import CoreData

struct PickItemImageView: View {
    @StateObject var model: PickItemImageViewModel
    
    var body: some View {
        if model.isImagePicked {
            VStack {
                Image(uiImage: model.pickedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        } else {
            VStack(alignment: .center, spacing: 12) {
                Text("Pick image:")
                Button("Capture", action: onCaptureImage)
                Button("Upload", action: onUploadImage)
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .border(Color.blue)
            .sheet(isPresented: $model.isPresenting, content: {
                model.buildImagePickerView()
            })
        }
    }
    
    func onCaptureImage() {
        model.captureImage()
    }
    
    func onUploadImage() {
        model.uploadImage()
    }
}

struct PickItemImageView_Preview: View {
    private var viewContext: NSManagedObjectContext {
        return CoreDataStorage.shared.container.viewContext
    }
    
    var body: some View {
        PickItemImageView(model: buildModel())
    }
    
    func buildModel() -> PickItemImageViewModel {
        let dependencies = PickItemImageViewModelDependencies(imageRepo: CategoryImageRepository(), imagePicker: ImagePicker())
        let model = PickItemImageViewModel(dependencies: dependencies)
        model.onPicked(image: UIImage(named: "ImageSample1")!)
        return model
    }
}

struct PickItemImageView_Previews: PreviewProvider {
    static var previews: some View {
        PickItemImageView_Preview()
    }
}
