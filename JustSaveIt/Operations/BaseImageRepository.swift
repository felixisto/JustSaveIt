//
//  BaseImageRepository.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import UIKit

enum BaseImageRepositoryError: Error {
    case unknown
    case fileNotFound
}

class BaseImageRepository: ImageRepositoryProtocol {
    var directoryName: String {
        fatalError("Override me")
    }
    
    var uniqueIDKey: String {
        fatalError("Override me")
    }
    
    var fileSystem: SimpleFileSystem {
        return SimpleFileSystem.shared
    }
    
    func generateUniqueImageID() -> String {
        let key = CategoryImageRepository.UNIQUE_ID_KEY
        var counter = UserDefaults.standard.integer(forKey: key)
        counter += 1
        UserDefaults.standard.set(counter, forKey: key)
        return "\(counter)"
    }
    
    func fetchImage(withID id: String, success: @escaping (UIImage)->Void, failure: @escaping (Error)->Void) {
        let path = imagePath(for: id)
        let fs = fileSystem
        
        PerformOnBackground.async {
            do {
                let data = try fs.readFromFile(at: path)
                
                guard let image = UIImage(data: data, scale: 1.0) else {
                    throw BaseImageRepositoryError.fileNotFound
                }
                
                success(image)
            } catch let e {
                failure(e)
            }
        }
    }
    
    func save(image: UIImage, withID id: String, success: @escaping ()->Void, failure: @escaping (Error)->Void) {
        let path = imagePath(for: id)
        let fs = fileSystem
        
        PerformOnBackground.async {
            do {
                guard let data = image.convertCapturedImageToData() else {
                    throw BaseImageRepositoryError.unknown
                }
                
                try fs.createFile(at: path, contents: data, attributes: nil)
                
                success()
            } catch let e {
                failure(e)
            }
        }
    }
    
    func delete(imageWithID id: String) {
        let path = imagePath(for: id)
        let fs = fileSystem
        
        PerformOnBackground.async {
            try? fs.deleteItem(at: path)
        }
    }
    
    func imagePath(for fileName: String) -> URL {
        return fileSystem.documentsSubdirectoryFileURL(directoryName: CategoryImageRepository.DIRECTORY_NAME,
                                                       fileName: fileName)
    }
}
