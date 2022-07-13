//
//  FrameConfig.swift
//  gallery-test
//
//  Created by Yelyzaveta Boiarchuk on 12.07.2022.
//

import Foundation
import UIKit

enum FrameStyle: String {
    case gold = "Gold"
    case home = "Home"
    case wooden = "Wooden"
    case polaroid = "Polaroid"
}


func getFrameBorders(style: FrameStyle) -> (vertical: Double, horizontal: Double) {
    switch style {
    case .gold:
        return (0.115, 0.15)
    case .home:
        return (0.12, 0.152)
    case .wooden:
        return (0.082, 0.116)
    case .polaroid:
        return (0.15, 0.14)
    }
}


func getFrameImage(style: FrameStyle) -> UIImage {
    switch style {
    case .gold:
        return UIImage(named: Bundle.main.path(forResource: "frame-gold", ofType: "png")!)!
    case .home:
        return UIImage(named: Bundle.main.path(forResource: "frame-home", ofType: "png")!)!
    case .wooden:
        return UIImage(named: Bundle.main.path(forResource: "frame-wooden", ofType: "png")!)!
    case .polaroid:
        return UIImage(named: Bundle.main.path(forResource: "frame-polaroid", ofType: "png")!)!
    }
    
}

