//
//  UIImage.swift
//  gallery-test
//
//  Created by Yelyzaveta Boiarchuk on 07.07.2022.
//

import Foundation
import UIKit

extension UIImage {
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage;
    }

}

