//
//  PrimaryViewItemParser.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import UIKit

protocol PrimaryViewItemParserProtocol {
    func parse(_ value: UserCategory) throws -> PrimaryViewItem
}

enum PrimaryViewItemParserError: Error {
    case invalidParameter
}

struct PrimaryViewItemParser: PrimaryViewItemParserProtocol {
    let defaultImage: UIImage
    
    init(defaultImage: UIImage = UIImage()) {
        self.defaultImage = defaultImage
    }
    
    func parse(_ value: UserCategory) throws -> PrimaryViewItem {
        guard let name = value.name else {
            throw PrimaryViewItemParserError.invalidParameter
        }
        
        guard let description = value.userDescription else {
            throw PrimaryViewItemParserError.invalidParameter
        }
        
        guard let imageID = value.imageID else {
            throw PrimaryViewItemParserError.invalidParameter
        }
        
        return PrimaryViewItem(title: name, description: description, imageID: imageID, image: defaultImage)
    }
}
