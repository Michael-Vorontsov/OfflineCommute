//
//  ManagedObjectSyncOperation.swift
//  wallet
//
//  Created by Mykhailo Vorontsov on 24/02/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreData

class ManagedObjectSyncOperation: BasicSyncOperation {
  
  
  init(dataManager: CoreDataManager) {
    self.dataManager = dataManager
    super.init()
  }
  
  let dataManager: CoreDataManager
  
  /**
   Function for parsing managed objects in background.
   Mandatory to override
   */
  func parseManagedObjects(dataInfo:AnyObject, context:NSManagedObjectContext) -> [NSManagedObjectID]{
    
    return []
  }
  
  override func parseObjects(dataInfo: AnyObject) -> [AnyObject] {
    guard  !cancelled else {
      return []
    }
    var resultBalance:[AnyObject] = []
    let context = self.dataManager.dataContext
    context.performBlockAndWait { () -> Void in
      resultBalance = self.parseManagedObjects(dataInfo, context: context)
      self.dataManager.saveContext(context)
    }
    return resultBalance
  }
}
