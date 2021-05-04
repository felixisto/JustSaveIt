//
//  CategoryImageRepository.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import UIKit

class CategoryImageRepository: BaseImageRepository {
    public static let DIRECTORY_NAME = "CategoryImages"
    public static let UNIQUE_ID_KEY = "CategoryImageRepository.UniqueID"
    
    override var directoryName: String {
        return CategoryImageRepository.DIRECTORY_NAME
    }
    
    override var uniqueIDKey: String {
        return CategoryImageRepository.UNIQUE_ID_KEY
    }
}
