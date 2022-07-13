//
//  ImageStyler.swift
//  gallery-test
//
//  Created by Yelyzaveta Boiarchuk on 13.07.2022.
//

import Foundation
import UIKit
import CoreML

class ImageStyler {
    
    private let model = GalleryStylization()
    
    
    func styleImage(_ image: UIImage, as style: ImageStyle) -> UIImage {
        
        var data: [Float] = [0, 0, 0]
        
        switch style {
        case .geometry:
            data[0] = 1
        case .picasso:
            data[1] = 1
        case .munch:
            data[2] = 1
        case .default:
            return image
        }
        
        guard let stylesArray = try? MLMultiArray(data) else { return image }
        guard let buffer = image.pixelBuffer() else { return image }
        let result = try? model.prediction(image: buffer, index: stylesArray)
        guard let resultBuffer = result?.stylizedImage else { return image }
        let ciImage = CIImage(cvPixelBuffer: resultBuffer)
        let tempContext = CIContext(options: nil)
        let tempImage = tempContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(resultBuffer), height: CVPixelBufferGetHeight(resultBuffer)))
        let resized = UIImage(cgImage: tempImage!).resize(to: image.size)
        return resized ?? image
    }
}
