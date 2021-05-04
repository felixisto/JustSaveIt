//
//  MakeCategoryViewModel.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 25.04.21.
//

import SwiftUI
import CoreData

enum MakeCategoryViewModelError: String, Error {
    case mustPickImage = "Pick an image"
}

struct MakeCategoryViewModelDependencies {
    var categoriesRepository: CategoriesRepositoryProtocol
    var imageRepo: ImageRepositoryProtocol
    var imagePicker: ImagePicker
    var categoryTextValidator: UserCategoryTextValidatorProtocol
    
    static func make(from other: PrimaryViewModelDependencies) -> MakeCategoryViewModelDependencies {
        return MakeCategoryViewModelDependencies(categoriesRepository: other.categoriesRepository, imageRepo: other.itemImageRepo, imagePicker: other.imagePicker, categoryTextValidator: other.categoryTextValidator)
    }
}

class MakeCategoryViewModel: ObservableObject {
    public static let MAX_NAME_LENGTH = 16
    public static let MAX_DESCRIPTION_LENGTH = 16
    
    let dependencies: MakeCategoryViewModelDependencies
    
    @Published var name: String = "Name"
    @Published var userDescription: String = ""
    
    var pickItemImageModel: PickItemImageViewModel
    
    private var imageID: String = ""
    
    init(dependencies: MakeCategoryViewModelDependencies) {
        self.dependencies = dependencies
        self.pickItemImageModel = PickItemImageViewModel(dependencies: PickItemImageViewModelDependencies.make(from: dependencies))
        self.imageID = dependencies.imageRepo.generateUniqueImageID()
    }
    
    func saveAndExit(withSuccess success: @escaping ()->Void, failure: @escaping (Error)->Void) {
        do {
            try dependencies.categoryTextValidator.validate(name: name)
            try dependencies.categoryTextValidator.validate(description: userDescription)
        } catch let e {
            failure(e)
            return
        }
        
        if !pickItemImageModel.isImagePicked {
            failure(MakeCategoryViewModelError.mustPickImage)
            return
        }
        
        weak var weakSelf = self
        
        let failureCompleteOnMain = { (error: Error) in
            // Always complete on main
            PerformOnMain.async {
                failure(error)
            }
        }
        
        // 3
        let saveImageSuccess = {
            // Always complete on main
            PerformOnMain.async {
                weakSelf?.saveAndCommitChanges()
                success()
            }
        }
        
        // 2
        let storeDataToCoreDataSuccess = {
            PerformOnBackground.async {
                weakSelf?.saveImageToRepo(success: saveImageSuccess, failure: failureCompleteOnMain)
            }
        }
        
        // 1
        PerformOnMain.async {
            weakSelf?.storeDataToCoreData(success: storeDataToCoreDataSuccess, failure: failureCompleteOnMain)
        }
    }
    
    func errorMessage(for error: Error) -> String {
        if let e = error as? UserCategoryTextValidatorError {
            return e.rawValue
        }
        
        if let e = error as? MakeCategoryViewModelError {
            return e.rawValue
        }
        
        return "Unknown error"
    }
    
    func isNameTaken(_ name: String) -> Bool {
        return dependencies.categoriesRepository.isNameTaken(name)
    }
    
    private func saveImageToRepo(success: @escaping ()->Void, failure: @escaping (Error)->Void) {
        let image = pickItemImageModel.pickedImage
        dependencies.imageRepo.save(image: image, withID: imageID, success: success, failure: failure)
    }
    
    private func storeDataToCoreData(success: @escaping ()->Void, failure: @escaping (Error)->Void) {
        let category = dependencies.categoriesRepository.createNew()
        category.name = name
        category.userDescription = userDescription
        category.imageID = imageID
        category.dateCreated = Date()
        
        success()
    }
    
    private func saveAndCommitChanges() {
        try? dependencies.categoriesRepository.saveChanges()
        
        DebugLogging.logMessage(self, "Saved new category '\(name)'")
    }
}
