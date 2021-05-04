//
//  ItemsRepositoryProtocol.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import CoreData
import Combine

protocol ItemsRepositoryProtocol {
    // Properties
    
    var items: [UserItem] { get }
    var itemsPublisher: Published<[UserItem]>.Publisher { get }
    
    // Convienience wrapper of @itemsPublisher that filters emitted values by category name.
    func categoryItemsPublisher(byCategory name: String) -> AnyPublisher<Array<UserItem>, Never>
    
    // Operations
    
    func saveChanges() throws
    func updateFromStore()
    func createNew() -> UserItem
    func delete(named name: String)
    
    func category(named name: String) -> UserCategory?
    func categoryItem(named name: String, byCategoryName categoryName: String) -> UserItem?
    
    // Validators
    
    func isNameTaken(_ name: String, ofCategoryName categoryName: String) -> Bool
}

// Filters
extension ItemsRepositoryProtocol {
    var filterItemsByCategoryName: ([UserItem], String) -> [UserItem] {
        return { (items, categoryName) in
            return items.filter { (element) -> Bool in
                guard let category = element.category else {
                    return false
                }
                return category.name == categoryName
            }
        }
    }
}
