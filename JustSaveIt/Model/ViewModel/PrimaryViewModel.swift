//
//  PrimaryViewModel.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import SwiftUI
import CoreData
import Combine

struct PrimaryViewItem: Identifiable {
    var id: Int {
        return title.hash
    }
    
    var title: String
    var description: String
    var imageID: String
    var image: UIImage
}

struct PrimaryViewModelDependencies {
    var categoriesRepository: CategoriesRepositoryProtocol
    var itemsRepository: ItemsRepositoryProtocol
    
    var categoryImageRepo: ImageRepositoryProtocol
    var itemImageRepo: ImageRepositoryProtocol
    
    var categoriesParser: PrimaryViewItemParserProtocol
    var itemsParser: CategoryViewItemParserProtocol
    
    var imagePicker: ImagePicker
    
    var categoryTextValidator: UserCategoryTextValidatorProtocol
    var itemTextValidator: UserItemTextValidatorProtocol
}

class PrimaryViewModel: ObservableObject {
    let dependencies: PrimaryViewModelDependencies
    
    @Published var items: [PrimaryViewItem] = []
    
    private var itemsSubscriber: AnyCancellable?
    
    init(dependencies: PrimaryViewModelDependencies) {
        self.dependencies = dependencies
        
        self.itemsSubscriber = dependencies.categoriesRepository.itemsPublisher.sink(receiveValue: { [weak self] (items) in
            self?.updateData(items)
        })
    }
    
    func deleteItems(at offsets: IndexSet) {
        for offset in offsets {
            let itemName = items[offset].title
            dependencies.categoriesRepository.delete(named: itemName)
            
            DebugLogging.logMessage(self, "Delete category '\(itemName)'")
        }
        
        do {
            try dependencies.categoriesRepository.saveChanges()
        } catch let e {
            DebugLogging.logError(self, "Failed to delete items, error: \(e)")
        }
    }
}

// Update data
extension PrimaryViewModel {
    func updateData(_ data: [UserCategory]) {
        updateItemsData(data)
        updateImages()
    }
    
    func updateItemsData(_ data: [UserCategory]) {
        items.removeAll()
        
        for entity in data {
            do {
                let item = try dependencies.categoriesParser.parse(entity)
                items.append(item)
            } catch {
                
            }
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
