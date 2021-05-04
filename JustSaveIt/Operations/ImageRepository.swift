//
//  ImageRepository.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import UIKit

/*
 * Performs file operations.
 *
 * Note that all operations are performed on background thread.
 */
protocol ImageRepositoryProtocol {
    func generateUniqueImageID() -> String
    
    func fetchImage(withID id: String, success: @escaping (UIImage)->Void, failure: @escaping (Error)->Void)
    func save(image: UIImage, withID id: String, success: @escaping ()->Void, failure: @escaping (Error)->Void)
    func delete(imageWithID id: String)
}
