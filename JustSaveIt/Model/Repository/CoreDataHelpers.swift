//
//  CoreDataHelpers.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 25.04.21.
//

import CoreData

class CoreDataHelpers {
    static func fetchAllCategories(context: NSManagedObjectContext, with predicate: NSPredicate?) throws -> [UserCategory] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: UserCategory.self))
        request.predicate = predicate
        
        return try context.fetch(request) as? [UserCategory] ?? []
    }
    
    static func fetchCategory(context: NSManagedObjectContext, byName name: String) throws -> [UserCategory] {
        let model = CoreDataStorage.shared.model
        
        guard let request = model.fetchRequestFromTemplate(withName: "FetchCategoryByName", substitutionVariables: ["V1" : name]) else {
            return []
        }
        
        return try context.fetch(request) as? [UserCategory] ?? []
    }
    
    static func fetchItems(context: NSManagedObjectContext, for category: UserCategory) throws -> [UserItem] {
        return try fetchItems(context: context, for: category.name ?? "")
    }
    
    static func fetchItems(context: NSManagedObjectContext, for categoryName: String) throws -> [UserItem] {
        let model = CoreDataStorage.shared.model
        
        guard let request = model.fetchRequestFromTemplate(withName: "FetchItemsOfCategory", substitutionVariables: ["V1" : categoryName]) else {
            return []
        }
        
        return try context.fetch(request) as? [UserItem] ?? []
    }
}
