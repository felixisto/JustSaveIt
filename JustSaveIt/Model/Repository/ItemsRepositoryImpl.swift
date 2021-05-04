//
//  ItemsRepositoryImpl.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 28.04.21.
//

import CoreData
import Combine

class ItemsRepositoryImpl: ItemsRepositoryProtocol {
    let context: NSManagedObjectContext
    
    @Published var items: [UserItem] = []
    
    var itemsPublisher: Published<[UserItem]>.Publisher {
        return $items
    }
    
    func categoryItemsPublisher(byCategory name: String) -> AnyPublisher<Array<UserItem>, Never> {
        let filter = self.filterItemsByCategoryName
        
        return $items.map { (items) -> [UserItem] in
            return filter(items, name)
        }.eraseToAnyPublisher()
    }
    
    private let lock = SimpleLock()
    
    private let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: UserItem.self))
    
    // The actual items state. @items is set to this value when the context is saved. Then, this value is cleared.
    private var uncommitedItems: [UserItem] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        updateFromStore()
    }
    
    // Operations
    
    func saveChanges() throws {
        try context.save()
        
        items = uncommitedItems
    }
    
    func updateFromStore() {
        do {
            let result = try context.fetch(request)
            items = result as? [UserItem] ?? []
            uncommitedItems = items
        } catch {
            
        }
    }
    
    func createNew() -> UserItem {
        let item = UserItem(context: context)
        uncommitedItems.append(item)
        return item
    }
    
    func delete(named name: String) {
        for item in items {
            if item.name == name {
                context.delete(item)
            }
        }
        
        items.removeAll { (category) -> Bool in
            return category.name == name
        }
    }
    
    // Query
    
    func category(named name: String) -> UserCategory? {
        let predicate = NSPredicate(format: "name == '\(name)'")
        
        guard let result = try? CoreDataHelpers.fetchAllCategories(context: context, with: predicate) else {
            return nil
        }
        
        return result.first
    }
    
    func categoryItem(named name: String, byCategoryName categoryName: String) -> UserItem? {
        let categoryItems = self.filterItemsByCategoryName(items, categoryName)
        
        return categoryItems.first { (element) -> Bool in
            return element.name == name
        }
    }
    
    // Validators
    
    func isNameTaken(_ name: String, ofCategoryName categoryName: String) -> Bool {
        guard let items = try? CoreDataHelpers.fetchItems(context: context, for: categoryName) else {
            return false
        }
        
        return items.contains { (element) -> Bool in
            element.name == name
        }
    }
}
