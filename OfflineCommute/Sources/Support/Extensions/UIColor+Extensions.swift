//
//  UIColor+Extensions.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 29/06/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

extension UIColor {
//  func grayscale() -> UIColor {
//
//    var red: CGFloat = 0
//    var green: CGFloat = 0
//    var blue: CGFloat = 0
//    var alpha: CGFloat = 0
//    
//    
//    
//    if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
//      return UIColor(white: 0.299 * red + 0.587 * green + 0.114 * blue, alpha: alpha)
//    }
//    return self
//    
//  }
  
  func grayscale(scale:CGFloat = 1.0) -> UIColor {
    
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightenes: CGFloat = 0
    var alpha: CGFloat = 0
    
    if getHue(&hue, saturation: &saturation, brightness: &brightenes, alpha: &alpha) {
      return UIColor(hue: hue, saturation: saturation * (1.0 - scale), brightness: brightenes, alpha: alpha)
    }
    
    return self
    
  }

}
