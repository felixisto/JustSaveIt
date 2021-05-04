//
//  MakeItemViewModel.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import SwiftUI
import CoreData

enum MakeItemViewModelError: String, Error {
    case mustPickImage = "Pick an image"
}

struct MakeItemViewModelDependencies {
    var itemsRepo: ItemsRepositoryProtocol
    var itemImageRepo: ImageRepositoryProtocol
    var imagePicker: ImagePicker
    var itemTextValidator: UserItemTextValidatorProtocol
    
    static func make(from other: CategoryViewModelDependencies) -> MakeItemViewModelDependencies {
        return MakeItemViewModelDependencies(itemsRepo: other.itemsRepo, itemImageRepo: other.itemImageRepo, imagePicker: other.imagePicker, itemTextValidator: other.itemTextValidator)
    }
}

class MakeItemViewModel: ObservableObject {
    public static let MAX_NAME_LENGTH = 16
    public static let MAX_DESCRIPTION_LENGTH = 16
    
    let dependencies: MakeItemViewModelDependencies
    
    let categoryName: String
    
    @Published var name: String = "Name"
    @Published var userDescription: String = ""
    
    let pickItemImageModel: PickItemImageViewModel
    let pickUserRatingModel: StarRatingViewModel
    
    private var imageID: String = ""
    
    init(dependencies: MakeItemViewModelDependencies, categoryName: String) {
        self.dependencies = dependencies
        self.categoryName = categoryName
        self.pickItemImageModel = PickItemImageViewModel(dependencies: PickItemImageViewModelDependencies.make(from: dependencies))
        self.pickUserRatingModel = StarRatingViewModel(dependencies: StarRatingViewModelDependencies(itemsRepo: dependencies.itemsRepo), starsValue: 1)
        self.imageID = dependencies.itemImageRepo.generateUniqueImageID()
    }
    
    func saveAndExit(withSuccess success: @escaping ()->Void, failure: @escaping (Error)->Void) {
        do {
            try dependencies.itemTextValidator.validate(name: name, forCategoryName: categoryName)
            try dependencies.itemTextValidator.validate(description: userDescription, forCategoryName: categoryName)
        } catch let e {
            failure(e)
            return
        }
        
        if !pickItemImageModel.isImagePicked {
            failure(MakeItemViewModelError.mustPickImage)
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
        if let e = error as? UserItemTextValidatorError {
            return e.rawValue
        }
        
        if let e = error as? MakeItemViewModelError {
            return e.rawValue
        }
        
        return "Unknown error"
    }
    
    func isNameTaken(_ name: String) -> Bool {
        return dependencies.itemsRepo.isNameTaken(name, ofCategoryName: categoryName)
    }
    
    private func saveImageToRepo(success: @escaping ()->Void, failure: @escaping (Error)->Void) {
        let image = pickItemImageModel.pickedImage
        dependencies.itemImageRepo.save(image: image, withID: imageID, success: success, failure: failure)
    }
    
    private func storeDataToCoreData(success: @escaping ()->Void, failure: @escaping (Error)->Void) {
        let item = dependencies.itemsRepo.createNew()
        item.category = dependencies.itemsRepo.category(named: categoryName)
        item.name = name
        item.userDescription = userDescription
        item.imageID = imageID
        item.dateCreated = Date()
        item.lastDateModified = Date()
        item.userRating = pickUserRatingModel.starsValue
        
        success()
    }
    
    private func saveAndCommitChanges() {
        try? dependencies.itemsRepo.saveChanges()
        
        DebugLogging.logMessage(self, "Saved new category item '\(name)' to category '\(categoryName)'")
    }
}
