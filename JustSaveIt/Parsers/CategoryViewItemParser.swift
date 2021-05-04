//
//  CategoryViewItemParser.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import UIKit

protocol CategoryViewItemParserProtocol {
    func parse(_ value: UserItem) throws -> CategoryViewItem
}

enum CategoryViewItemParserError: Error {
    case invalidParameter
}

struct CategoryViewItemParser: CategoryViewItemParserProtocol {
    let defaultImage: UIImage
    
    init(defaultImage: UIImage = UIImage()) {
        self.defaultImage = defaultImage
    }
    
    func parse(_ value: UserItem) throws -> CategoryViewItem {
        guard let name = value.name else {
            throw CategoryViewItemParserError.invalidParameter
        }
        
        guard let description = value.userDescription else {
            throw CategoryViewItemParserError.invalidParameter
        }
        
        guard let imageID = value.imageID else {
            throw CategoryViewItemParserError.invalidParameter
        }
        
        guard let dateCreated = value.dateCreated else {
            throw CategoryViewItemParserError.invalidParameter
        }
        
        guard let categoryName = value.category?.name else {
            throw CategoryViewItemParserError.invalidParameter
        }
        
        return CategoryViewItem(title: name, description: description, imageID: imageID, image: defaultImage, userRating: value.userRating, dateCreated: dateCreated, categoryName: categoryName)
    }
}
