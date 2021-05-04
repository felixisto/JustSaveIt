//
//  UserItemTextValidator.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 28.04.21.
//

import Foundation

enum UserItemTextValidatorError: String, Error {
    case invalidName = "Pick another name"
    case emptyName = "Name can't be empty"
    case nameTooLong = "Name is too long"
    case nameIsTaken = "Name is already taken"
    case mustPickImage = "Pick an image"
    case descriptionTooLong = "Description is too long"
}

protocol UserItemTextValidatorProtocol {
    func isNameTaken(_ name: String, forCategoryName categoryName: String) -> Bool
    
    func validate(name: String, forCategoryName categoryName: String) throws
    func validate(description: String, forCategoryName categoryName: String) throws
}

class UserItemTextValidator: UserItemTextValidatorProtocol {
    public static let MAX_NAME_LENGTH = 16
    public static let MAX_DESCRIPTION_LENGTH = 16
    
    let itemsRepo: ItemsRepositoryProtocol
    
    init(itemsRepo: ItemsRepositoryProtocol) {
        self.itemsRepo = itemsRepo
    }
    
    func isNameTaken(_ name: String, forCategoryName categoryName: String) -> Bool {
        return itemsRepo.isNameTaken(name, ofCategoryName: categoryName)
    }
    
    func validate(name: String, forCategoryName categoryName: String) throws {
        if name.isEmpty {
            throw UserItemTextValidatorError.emptyName
        }
        
        if name.count > UserItemTextValidator.MAX_NAME_LENGTH {
            throw UserItemTextValidatorError.nameTooLong
        }
        
        if isNameTaken(name, forCategoryName: categoryName) {
            throw UserItemTextValidatorError.nameIsTaken
        }
    }
    
    func validate(description: String, forCategoryName categoryName: String) throws {
        if description.count > UserItemTextValidator.MAX_DESCRIPTION_LENGTH {
            throw UserItemTextValidatorError.descriptionTooLong
        }
    }
}
