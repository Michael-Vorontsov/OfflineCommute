// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import Foundation
import UIKit

protocol Localizable{
  func localize(rootKey: String)
}

extension String {
  func localized(rootKey: String = "") -> String {
    let localizationKey = (self.characters.first != ".") ? self : rootKey + self;
    return  NSLocalizedString(localizationKey, comment: "")
  }
  
}

// XCode issue - can't declare a protocol because after that XCode refuse to bind actions in IB
extension UILabel {
  
  func localize(rootKey: String = "") {
    text = text?.localized(rootKey)
  }
}

extension UIButton {
  func localize(rootKey: String = "") {
    
    setTitle(titleForState(.Normal)?.localized(rootKey), forState: .Normal)
    setTitle(titleForState(.Highlighted)?.localized(rootKey), forState: .Highlighted)
    setTitle(titleForState(.Disabled)?.localized(rootKey), forState: .Disabled)
    setTitle(titleForState(.Selected)?.localized(rootKey), forState: .Selected)
  }
}

extension UITextField {
  func localize(rootKey:String = "") {
    placeholder = placeholder?.localized(rootKey)
  }
}
