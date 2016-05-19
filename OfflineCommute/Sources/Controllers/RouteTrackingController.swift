//
//  RouteTrackingController.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 18/05/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let consts = (
  minTimeInterval : 60.0 as NSTimeInterval,
  distance : 500.0
)

class RouteTrackingController: NSObject, CLLocationManagerDelegate {
  
  var isTracking:Bool = false
  
//  var lastPoint:CLLocation?
  
  var lastUpdateDate:NSDate?
  var coreDataManager: CoreDataManager!
  
  let locationManager = CLLocationManager()
  
  func resume() {
    
    locationManager.requestAlwaysAuthorization()

    isTracking = true
    locationManager.delegate = self
    locationManager.startUpdatingLocation()
  }
  
  func pause() {
    locationManager.stopUpdatingLocation()
    isTracking = false
  }
  
  // MARK: CLLocationManagerDelegate
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    //TODO: Notify user about error
    print("Location manager failed with error:\(error)")
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let now = NSDate()
    if let lastUpdateDate = lastUpdateDate where now.timeIntervalSinceDate(lastUpdateDate) < consts.minTimeInterval {
      return
    }
    
    lastUpdateDate = now
    
    let context = coreDataManager.dataContext
    context.performBlock({
      for location in locations {
        let waypoint = NSEntityDescription.insertNewObjectForEntityForName("Waypoint", inManagedObjectContext: context) as! Waypoint
        
        waypoint.lat = location.coordinate.latitude
        waypoint.lng = location.coordinate.longitude
        waypoint.date = now
        
      }
      
      context.save(recursive: true)
    })
  }
  
}


