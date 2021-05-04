//
//  UIImage+SavedCaptured.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import UIKit

extension UIImage {
    func convertCapturedImageToData() -> Data? {
        if self.imageOrientation == UIImage.Orientation.up {
            return self.pngData()
        }

        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage?.pngData()
    }
}
