// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import UIKit

/**
 Localisable base class.
 Introduced to siplify internationalization of application. 

 USAGE:
 1) In IB need to allign all UI controls, that comforms to Localizable protocol and should be localized
 to "localizableControls" outlet collection
 2) Specify Localizable Contoller Key that should used as root key for localization strings.
 3) If linked in step 1 control text field begins with '.' it value should be concatenated to root key (step 2)
 and replaced by appropriate string from Locolazable.strings
 4) Otherwise value should be localizaed itself.
*/

class LocalizableViewController: UIViewController, Localizable {
  
  @IBOutlet var localizableControls:[AnyObject]!
  @IBInspectable var localizableContollerKey:String = ""
  
  func localize(rootKey:String = "") {
    let controllerKey = rootKey + localizableContollerKey
    if nil != localizableControls {
      for each in localizableControls! {
        each.localize?(controllerKey)
      }
    }
    self.title = self.title?.localized(controllerKey)
  }
  
  override func viewDidLoad() {
    self.localize()
    super.viewDidLoad()
  }
}
