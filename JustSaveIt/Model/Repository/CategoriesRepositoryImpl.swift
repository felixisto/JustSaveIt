//
//  CategoriesRepositoryImpl.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 28.04.21.
//

import CoreData
import Combine

class CategoriesRepositoryImpl: CategoriesRepositoryProtocol {
    let context: NSManagedObjectContext
    
    @Published var items: [UserCategory] = []
    
    var itemsPublisher: Published<[UserCategory]>.Publisher {
        return $items
    }
    
    private let lock = SimpleLock()
    
    private let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: UserCategory.self))
    
    // The actual items state. @items is set to this value when the context is saved. Then, this value is cleared.
    private var uncommitedItems: [UserCategory] = []
    
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
            items = result as? [UserCategory] ?? []
            uncommitedItems = items
        } catch {
            
        }
    }
    
    func createNew() -> UserCategory {
        let category = UserCategory(context: context)
        uncommitedItems.append(category)
        return category
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
    
    func isNameTaken(_ name: String) -> Bool {
        guard let categories = try? CoreDataHelpers.fetchCategory(context: context, byName: name) else {
            return false
        }
        
        return !categories.isEmpty
    }
    
}
