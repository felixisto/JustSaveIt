//
//  ItemViewModel.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 27.04.21.
//

import UIKit

struct ItemViewInfo {
    var title: String
    var description: String
    var imageID: String
    var userRating: Int32
    var dateCreated: Date
    
    var dateCreatedFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: dateCreated)
    }
    
    var categoryName: String
}

struct ItemViewModelDependencies {
    var itemsRepo: ItemsRepositoryProtocol
    var itemImageRepo: ImageRepositoryProtocol
    
    var itemTextValidator: UserItemTextValidatorProtocol
    
    static func make(from other: CategoryViewModelDependencies) -> ItemViewModelDependencies {
        return ItemViewModelDependencies(itemsRepo: other.itemsRepo, itemImageRepo: other.itemImageRepo, itemTextValidator: other.itemTextValidator)
    }
}

class ItemViewModel: ObservableObject {
    let dependencies: ItemViewModelDependencies
    
    @Published var info: ItemViewInfo
    @Published var image: UIImage
    
    @Published var starRatingVM: StarRatingViewModel
    
    private let originalInfo: ItemViewInfo
    
    init(dependencies: ItemViewModelDependencies, info: ItemViewInfo, image: UIImage? = nil) {
        self.dependencies = dependencies
        self.info = info
        self.image = image ?? UIImage()
        self.originalInfo = info
        
        let starDependencies = StarRatingViewModelDependencies(itemsRepo: dependencies.itemsRepo)
        self.starRatingVM = StarRatingViewModel(dependencies: starDependencies, starsValue: info.userRating)
        
        updateData()
    }
    
    func saveDescription() throws {
        let repository = dependencies.itemsRepo
        let item = repository.categoryItem(named: info.title, byCategoryName: info.categoryName)
        item?.userDescription = info.description
        
        do {
            try dependencies.itemTextValidator.validate(description: info.description, forCategoryName: info.categoryName)
            
            try repository.saveChanges()
        } catch let e {
            info.description = originalInfo.description
            
            DebugLogging.logError(self, "Failed to save description, error: \(e)")
            
            throw e
        }
    }
    
    func errorMessage(for error: Error) -> String {
        if let e = error as? UserItemTextValidatorError {
            return e.rawValue
        }
        
        return "Unknown error"
    }
}

// Update data
extension ItemViewModel {
    func updateData() {
        updateImage()
    }
    
    func updateImage() {
        weak var weakSelf = self
        
        dependencies.itemImageRepo.fetchImage(withID: info.imageID) { (image) in
            weakSelf?.updateImage(image)
        } failure: { (error) in
            
        }
    }
    
    func updateImage(_ image: UIImage) {
        weak var weakSelf = self
        
        PerformOnMain.perform {
            weakSelf?.image = image
        }
    }
}
