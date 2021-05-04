//
//  StarRatingViewModel.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 27.04.21.
//

import Foundation

struct StarRatingViewModelDependencies {
    var itemsRepo: ItemsRepositoryProtocol
}

class StarRatingViewModel: ObservableObject {
    public static let STARS_COUNT = Range(1...5)
    
    let dependencies: StarRatingViewModelDependencies
    
    let itemInfo: ItemViewInfo?
    
    let saveChanges: Bool
    
    @Published var starsValue: Int32 = 0
    
    init(dependencies: StarRatingViewModelDependencies, starsValue: Int32) {
        self.dependencies = dependencies
        self.itemInfo = nil
        
        self.starsValue = starsValue
        self.saveChanges = false
    }
    
    init(dependencies: StarRatingViewModelDependencies, itemInfo: ItemViewInfo, saveChanges: Bool) {
        self.dependencies = dependencies
        self.itemInfo = itemInfo
        
        self.starsValue = itemInfo.userRating
        self.saveChanges = saveChanges
    }
    
    func setStars(value: Int32) {
        starsValue = value
        
        if saveChanges {
            saveCurrentStars()
        }
    }
    
    func saveCurrentStars() {
        guard let info = itemInfo else {
            return
        }
        
        if let item = dependencies.itemsRepo.categoryItem(named: info.title, byCategoryName: info.categoryName) {
            item.userRating = starsValue
            
            try? dependencies.itemsRepo.saveChanges()
        }
    }
}
