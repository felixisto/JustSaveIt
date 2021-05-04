//
//  UserCategoryTextValidator.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 28.04.21.
//

import Foundation

enum UserCategoryTextValidatorError: String, Error {
    case invalidName = "Pick another name"
    case emptyName = "Name can't be empty"
    case nameTooLong = "Name is too long"
    case nameIsTaken = "Name is already taken"
    case mustPickImage = "Pick an image"
    case descriptionTooLong = "Description is too long"
}

protocol UserCategoryTextValidatorProtocol {
    func isNameTaken(_ name: String) -> Bool
    
    func validate(name: String) throws
    func validate(description: String) throws
}

class UserCategoryTextValidator: UserCategoryTextValidatorProtocol {
    public static let MAX_NAME_LENGTH = 16
    public static let MAX_DESCRIPTION_LENGTH = 16
    
    let categoriesRepo: CategoriesRepositoryProtocol
    
    init(categoriesRepo: CategoriesRepositoryProtocol) {
        self.categoriesRepo = categoriesRepo
    }
    
    func isNameTaken(_ name: String) -> Bool {
        return categoriesRepo.isNameTaken(name)
    }
    
    func validate(name: String) throws {
        if name.isEmpty {
            throw UserCategoryTextValidatorError.emptyName
        }
        
        if name.count > UserCategoryTextValidator.MAX_NAME_LENGTH {
            throw UserCategoryTextValidatorError.nameTooLong
        }
        
        if isNameTaken(name) {
            throw UserCategoryTextValidatorError.nameIsTaken
        }
    }
    
    func validate(description: String) throws {
        if description.count > UserCategoryTextValidator.MAX_DESCRIPTION_LENGTH {
            throw UserCategoryTextValidatorError.descriptionTooLong
        }
    }
}
