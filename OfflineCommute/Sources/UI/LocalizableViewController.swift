// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import UIKit

class LocalizableViewController: UIViewController, Localizable {
  
  @IBOutlet var localizableControls:[AnyObject]!
  @IBInspectable var localizableContollerKey:String = ""
  
  func localize(rootKey:String = "") {
//    let controllerKey = rootKey + localizableContollerKey
//    if nil != localizableControls {
//      for each in localizableControls! {
//        each.localize?(controllerKey)
//      }
//    }
//    self.title = self.title?.localized(controllerKey)
  }
  
//  override func viewDidLoad() {
//    self.localize()
//    super.viewDidLoad()
//  }
}
