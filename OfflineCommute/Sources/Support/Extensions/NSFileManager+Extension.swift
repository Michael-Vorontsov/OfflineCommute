// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import Foundation

extension NSFileManager {
  /**
   Return application document directory
   */
  @nonobjc static let applicationDocumentsDirectory: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls.last!
  }()
  
}
