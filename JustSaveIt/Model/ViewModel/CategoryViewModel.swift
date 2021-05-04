//
//  CategoryViewModel.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import SwiftUI
import CoreData
import Combine

struct CategoryViewInfo {
    var title: String
    var imageID: String
    var image: UIImage
    
    static func make(from item: PrimaryViewItem) -> CategoryViewInfo {
        return CategoryViewInfo(title: item.title, imageID: item.imageID, image: item.image)
    }
}

struct CategoryViewItem: Identifiable {
    var id: Int {
        return title.hash
    }
    
    var title: String
    var description: String
    var imageID: String
    var image: UIImage
    var userRating: Int32
    var dateCreated: Date
    var categoryName: String
    
    var asItemInfo: ItemViewInfo {
        return ItemViewInfo(title: title, description: description, imageID: imageID, userRating: userRating, dateCreated: dateCreated, categoryName: categoryName)
    }
}

struct CategoryViewModelDependencies {
    var categoryImageRepo: ImageRepositoryProtocol
    var itemImageRepo: ImageRepositoryProtocol
    var imagePicker: ImagePicker
    var parser: CategoryViewItemParserProtocol
    
    var itemsRepo: ItemsRepositoryProtocol
    
    var categoryTextValidator: UserCategoryTextValidatorProtocol
    var itemTextValidator: UserItemTextValidatorProtocol
    
    static func make(from other: PrimaryViewModelDependencies) -> CategoryViewModelDependencies {
        return CategoryViewModelDependencies(categoryImageRepo: other.categoryImageRepo, itemImageRepo: other.itemImageRepo, imagePicker: other.imagePicker, parser: other.itemsParser, itemsRepo: other.itemsRepository, categoryTextValidator: other.categoryTextValidator, itemTextValidator: other.itemTextValidator)
    }
}

class CategoryViewModel: ObservableObject {
    let dependencies: CategoryViewModelDependencies
    
    var categoryName: String {
        return info.title
    }
    
    @Published var info: CategoryViewInfo
    @Published var items: [CategoryViewItem] = []
    
    private var itemViewModels: [ItemViewModel] = []
    
    private var itemsSubscriber: AnyCancellable?
    
    init(dependencies: CategoryViewModelDependencies, info: CategoryViewInfo) {
        self.dependencies = dependencies
        self.info = info
        
        let categoryName = self.categoryName
        
        self.itemsSubscriber = dependencies.itemsRepo.categoryItemsPublisher(byCategory: categoryName)
            .sink(receiveValue: {  [weak self] (items) in
                self?.updateData(items)
            })
    }
    
    func itemViewModel(for item: CategoryViewItem) -> ItemViewModel {
        if let first = itemViewModels.first(where: { (element) -> Bool in
            element.info.title == item.title
        }) {
            return first
        }
        
        fatalError("Cannot find item view model")
    }
    
    func deleteItems(at offsets: IndexSet) {
        for offset in offsets {
            let itemName = items[offset].title
            dependencies.itemsRepo.delete(named: itemName)
            
            DebugLogging.logMessage(self, "Delete category item '\(itemName)'")
        }
        
        do {
            try dependencies.itemsRepo.saveChanges()
        } catch let e {
            DebugLogging.logError(self, "Failed to delete items, error: \(e)")
        }
    }
}

// Update data
extension CategoryViewModel {
    func updateData(_ data: [UserItem]) {
        updateItemsData(data)
        updateItemViewModels()
        updateImages()
    }
    
    func updateItemsData(_ data: [UserItem]) {
        items.removeAll()
        
        for entity in data {
            do {
                let item = try dependencies.parser.parse(entity)
                items.append(item)
            } catch {
                
            }
        }
    }
    
    func updateItemViewModels() {
        itemViewModels.removeAll()
        
        for item in items {
            let dependencies = ItemViewModelDependencies.make(from: self.dependencies)
            let model = ItemViewModel(dependencies: dependencies, info: item.asItemInfo, image: item.image)
            itemViewModels.append(model)
        }
    }
    
    func updateImages() {
        weak var weakSelf = self
        
        let dataCopy = items
        
        for item in dataCopy {
            let id = item.imageID
            
            dependencies.categoryImageRepo.fetchImage(withID: id) { (image) in
                weakSelf?.updateImage(image, forID: id)
            } failure: { (error) in
                
            }
        }
    }
    
    func updateImage(_ image: UIImage, forID id: String) {
        weak var weakSelf = self
        
        PerformOnMain.perform {
            guard let strongSelf = weakSelf else {
                return
            }
            
            for e in 0..<strongSelf.items.count {
                if strongSelf.items[e].imageID == id {
                    strongSelf.items[e].image = image
                    break
                }
            }
        }
    }
}
