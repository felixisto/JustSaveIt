//
//  ItemImageRepository.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import UIKit

class ItemImageRepository: BaseImageRepository {
    public static let DIRECTORY_NAME = "ItemImages"
    public static let UNIQUE_ID_KEY = "ItemImageRepository.UniqueID"
    
    override var directoryName: String {
        return ItemImageRepository.DIRECTORY_NAME
    }
    
    override var uniqueIDKey: String {
        return ItemImageRepository.UNIQUE_ID_KEY
    }
}
