//
//  AppDelegate.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/02/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreData


private struct Constants {
  static let baseMockAddress = "http://private-c1975-lebarawallet.apiary-mock.com/v1"
//  static let baseTFLAddress = "https://api.tfl.gov.uk"
  static let baseTFLAddress = "https://api.tfl.gov.uk"
  
  //  https://api.tfl.gov.uk/BikePoint?app_id=&app_key=
  
  static let appId = "f931f27e"
  static let appKey = "2692ab08868e3f112a0fc60ca8f5141f"
  
  static let appIdKey = "app_id"
  static let appKeyKey = "app_key"
}


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

  static var sharedInstance:AppDelegate {
    get {
      return UIApplication.sharedApplication().delegate as! AppDelegate
    }
  }
  
  var window: UIWindow?
  
  lazy var  trackingManager:RouteTrackingController = {
    let trackingManager = RouteTrackingController()
    trackingManager.coreDataManager = self.coreDataManager
    return trackingManager
  }()
  lazy var coreDataManager:CoreDataManager = {
    return CoreDataManager(databaseName:"CommuteDB" , modelName: "OfflineCommute")
  }()
  lazy var dataOperationManager:OCOperationManager = {
    let manager = OCOperationManager(remote:Constants.baseTFLAddress, appKey:Constants.appKey, appID: Constants.appId)
    let builder = self.objectBuilder
    manager.objectBuilder = builder
    manager.coreDataManager =  builder.coreDataManager
    return manager
  }()
  lazy var  objectBuilder:ObjectBuilder = {
    return OCObjectBuilder(dataManager:self.coreDataManager)
  }()
  

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    dataOperationManager.coreDataManager = coreDataManager
    
    trackingManager.resume()
    
    // Override point for customization after application launch.
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
    //Clear all waypoints
    let request = NSFetchRequest(entityName: "Waypoint")
    let waypoints = try! coreDataManager.mainContext.executeFetchRequest(request) as! [NSManagedObject]
    coreDataManager.mainContext.deleteObjects(waypoints)
    
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Log all waypoints
    let request = NSFetchRequest(entityName: "Waypoint")
    let waypoints = try! coreDataManager.mainContext.executeFetchRequest(request) as! [Waypoint]
    for pin in waypoints {
      print("Date:\(pin.date!)     Lng: \(pin.lng!)     lat:\(pin.lat) \n\n")
    }
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
  }
  

  }

