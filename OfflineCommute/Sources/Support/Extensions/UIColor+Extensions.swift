//
//  UIColor+Extensions.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 29/06/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

private let consts = (
  red : 0.299 as CGFloat,
  green : 0.587 as CGFloat,
  blue : 0.114 as CGFloat
)

extension UIColor {
  
  func grayscale(scale:CGFloat) -> UIColor {
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    let grayness = consts.red * red + consts.green * green + consts.blue * blue
    
    red   = red   * (1 - scale) + grayness * scale
    green = green * (1 - scale) + grayness * scale
    blue  = blue  * (1 - scale) + grayness * scale
    alpha *= 1.0 - (0.5 * scale)
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    
  }

}
