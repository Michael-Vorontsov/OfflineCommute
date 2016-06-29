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

class UpdateDistanceSyncOperation: DataRetrievalOperation, ManagedObjectRetrievalOperationProtocol {
  
  let center:CLLocationCoordinate2D
  
  var dataManager: CoreDataManager!
  
  init(center:CLLocationCoordinate2D) {
    self.center = center
    super.init()
    self.force = true
  }
  
  //  override func main() {
  override func parseData() throws {
    var internalError:ErrorType? = nil
    let context = dataManager.dataContext
    context.performBlockAndWait { () -> Void in
      // Clear old data
      do {
        guard let allDocks = try context.executeFetchRequest(NSFetchRequest(entityName: "DockStation")) as? [DockStation] else {
          return
        }
        
        let location = CLLocation(latitude: self.center.latitude, longitude: self.center.longitude)
        
        for dock in allDocks {
          let dockLocation = CLLocation(latitude:dock.latitude.doubleValue, longitude: dock.longitude.doubleValue)
          
          let distance = location.distanceFromLocation(dockLocation)
          
          dock.distance = distance
        }
        try context.save()
        
      } catch {
        internalError = error
      }
    }
    
    guard nil == internalError else {
      throw internalError!
    }
    
    
  }

}
