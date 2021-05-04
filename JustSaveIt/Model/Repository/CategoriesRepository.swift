//
//  CategoriesRepositoryProtocol.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import CoreData

protocol CategoriesRepositoryProtocol {
    // Properties
    
    var items: [UserCategory] { get }
    var itemsPublisher: Published<[UserCategory]>.Publisher { get }
    
    // Operations
    
    func saveChanges() throws
    func updateFromStore()
    func createNew() -> UserCategory
    func delete(named name: String)
    
    // Validators
    
    func isNameTaken(_ name: String) -> Bool
}
