//
//  PrimaryViewCategoryItemParser.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import UIKit

protocol PrimaryViewCategoryItemParserProtocol {
    func parse(_ value: UserCategory) throws -> PrimaryViewCategoryItem
}

enum PrimaryViewCategoryItemParserError: Error {
    case invalidParameter
}

struct PrimaryViewCategoryItemParser: PrimaryViewCategoryItemParserProtocol {
    let defaultImage: UIImage
    
    init(defaultImage: UIImage = UIImage()) {
        self.defaultImage = defaultImage
    }
    
    func parse(_ value: UserCategory) throws -> PrimaryViewCategoryItem {
        guard let name = value.name else {
            throw PrimaryViewCategoryItemParserError.invalidParameter
        }
        
        guard let description = value.userDescription else {
            throw PrimaryViewCategoryItemParserError.invalidParameter
        }
        
        guard let imageID = value.imageID else {
            throw PrimaryViewCategoryItemParserError.invalidParameter
        }
        
        return PrimaryViewCategoryItem(title: name, description: description, imageID: imageID, image: defaultImage)
    }
}
