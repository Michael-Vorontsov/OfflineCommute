//
//  UpdateDistanceSyncOperation.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/02/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class UpdateDistanceSyncOperation: BasicSyncOperation {
  
  let center:CLLocationCoordinate2D
  let dataManager: CoreDataManager
  
  init(dataManager: CoreDataManager, center:CLLocationCoordinate2D) {
    self.dataManager = dataManager
    self.center = center
    super.init()
  }
  
  override func main() {
    let context = dataManager.dataContext
    context.performBlockAndWait { () -> Void in
      // Clear old data
      do {
        guard let allDocks = try context.executeFetchRequest(NSFetchRequest(entityName: "DockStation")) as? [DockStation] else {
          self.breakWithError(NSError(domain: "CoreData", code: 1, userInfo: nil))
          return
        }
        
        let location = CLLocation(latitude: self.center.latitude, longitude: self.center.longitude)
        
        for dock in allDocks {
          let dockLocation = CLLocation(latitude:dock.latitude.doubleValue, longitude: dock.longitude.doubleValue)
          
          let distance = location.distanceFromLocation(dockLocation)
          
          dock.distance = distance
        }
        self.dataManager.saveContext(context)
        
      } catch {
      }
    }
    
    
  }

}
