//
//  ImageResizer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/10/24.
//

import Foundation
import UIKit

class ImageResizer {
    
    enum Size: CGFloat {
        case size_512 = 512
        case size_1024 = 1024
        case size_1536 = 1536
    }
    
    static func resizedJpegDataTo512(size: ImageResizer.Size, from imageData: Data) -> Data? {
        // Create a UIImage from the input data
        guard let image = UIImage(data: imageData) else {
            print("Error: Cannot create image from data")
            return nil
        }
        
        return resizedJpegDataTo(size: size, from: image)
    }
    
    static func resizedJpegDataTo(size: ImageResizer.Size, from image: UIImage) -> Data? {
        // Calculate the new size to maintain aspect ratio
        let aspectWidth = size.rawValue / image.size.width
        let aspectHeight = size.rawValue / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)

        // Create UIGraphics context with new size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Convert the resized image back to data
        guard let newImageData = resizedImage?.jpegData(compressionQuality: 0.85) else {
            print("Error: Cannot convert resized image back to Data")
            return nil
        }

        return newImageData
    }
    
}
