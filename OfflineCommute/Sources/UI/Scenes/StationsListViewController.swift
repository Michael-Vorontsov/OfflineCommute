//
//  ViewController.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/02/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CCHMapClusterController

private struct Constants {
  static let CellReuseID = "Cell"
  static let animationDuration = 0.5
}

extension DockStation: MKAnnotation {
  var coordinate: CLLocationCoordinate2D {
    get {
      return CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue)
    }
  }
  
  var subtitle: String? { get {
    let available = self.bikesAvailable?.integerValue ?? 0
    let free = self.vacantPlaces?.integerValue ?? 0
    
      return "bikes: \(available) / free: \(free)"
    }
  }
  
}

class StationsListViewController: LocalizableViewController, NSFetchedResultsControllerDelegate, UITabBarDelegate {
  
  @IBOutlet weak var mapViewContainer: UIView!
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.tableFooterView = UIView()
    }
  }
  
  lazy var mapView:MKMapView = {
    let mapView = MKMapView(frame: self.mapViewContainer.bounds)
    mapView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    mapView.delegate = self
    return mapView
    
  }()

  
  lazy var mapClusterController:CCHMapClusterController = {
    let controller = CCHMapClusterController(mapView:self.mapView)
    controller.delegate = self
    if let annotations = self.resultsController.fetchedObjects as? [DockStation] {
      controller.addAnnotations(annotations, withCompletionHandler: nil)
    }
    return controller
  }()

  lazy var locationManager = {
    return CLLocationManager()
  }()

  lazy var dataManager:CoreDataManager = {
    return AppDelegate.sharedInstance.coreDataManager
  }()
  
  lazy var syncManager:DataRetrievalOperationManager = {
    return AppDelegate.sharedInstance.dataOperationManager
  }()
  
  lazy var dateFormatter:NSDateFormatter = {
    let formatter = NSDateFormatter()
    return formatter
  }()
  
  lazy var dateCalendar:NSCalendar = {
    return NSCalendar.currentCalendar()
//    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//    return calendar
  }()
  
  var currentLocationAnnotation:MKAnnotation?
  
  lazy var resultsController:NSFetchedResultsController = {
    let fetchRequest = NSFetchRequest(entityName: "DockStation")
    
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: true), NSSortDescriptor(key: "sid", ascending: true)]
    
    let context:NSManagedObjectContext = self.dataManager.mainContext
    
    let controller:NSFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

    controller.delegate = self
    do {
      try controller.performFetch()
    } catch {
      
    }
    return controller
  }()
}




// MARK: -Overrides

extension StationsListViewController {
  
  
  override func viewDidLoad() {
    super.viewDidLoad()

    
    let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png";
    let overlay = OCCachableTileOverlay(URLTemplate: template)
    overlay.canReplaceMapContent = true
    
    let newMapView = self.mapView
    mapView.setUserTrackingMode(.FollowWithHeading, animated: false)

// Comment/Uncomment below to toggle cachable map tiles
//    newMapView.addOverlay(overlay, level: .AboveLabels)
    
    mapViewContainer.addSubview(newMapView)
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    _ = mapClusterController
    mapView.showsUserLocation = true
    showCurrentLocation(self)
    
  }
  
  override func viewDidAppear(animated: Bool) {
//    let manager = CLLocationManager()
//    manager.requestWhenInUseAuthorization()
//    locationManager = manager
    locationManager.requestWhenInUseAuthorization()

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
      self.refresh()
    }
  }
}

// MARK: -Actions
extension StationsListViewController {
  
  @IBAction func refresh() {
    
    let centerLocation = self.currentLocationAnnotation?.coordinate ?? mapView.userLocation.location?.coordinate ?? CLLocationCoordinate2DMake( 51.5085300, -0.1257400)
    
    let netOperation = DockStationsSyncOperation()
    let fileOperation = DockStationFileOperation()
    let distanceOpeartion = UpdateDistanceSyncOperation(center: centerLocation)
    fileOperation.addDependency(netOperation)
    
    distanceOpeartion.addDependency(netOperation)
    distanceOpeartion.addDependency(fileOperation)
    
    syncManager.addOperations([netOperation, fileOperation, distanceOpeartion]) { (success, results, error) -> Void in
//    syncManager.addOperations([netOperation, distanceOpeartion]) { (success, results, error) -> Void in
      print("Data fetching completed")
    }
  }
  
  @IBAction func switchToList() {
    tableView.hidden = false
    UIView.animateWithDuration(Constants.animationDuration, animations: { () -> Void in
        self.tableView.alpha = 0.7
      }){ (completed) -> Void in
//        self.mapView.hidden = true
    }
  }

  @IBAction func switchToMap() {
    self.mapView.hidden = false
    UIView.animateWithDuration(Constants.animationDuration, animations: { () -> Void in
        self.tableView.alpha = 0.0
      }) { (completed) -> Void in
        self.tableView.hidden = true
    }
  }
  
  @IBAction func showCurrentLocation(sender: AnyObject) {
    self.mapView.setUserTrackingMode(.FollowWithHeading, animated: true)
    if let currentLocation = mapView.userLocation.location?.coordinate {
      let distanceOperation = UpdateDistanceSyncOperation(center:currentLocation)
      syncManager.addOperations([distanceOperation])
    }
  }
  

}


//MARKL -NSFetchedResultsControllerDelegate
extension StationsListViewController {
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    
    guard let anObject = anObject as? DockStation else {
      return
    }
    
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
      mapClusterController.addAnnotations([anObject], withCompletionHandler: nil)
//      mapView.addAnnotation(anObject)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
      mapClusterController.removeAnnotations([anObject], withCompletionHandler: nil)

//      mapView.removeAnnotation(anObject)
    case  .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
    case .Update: break
//      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//      tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//      mapClusterController.removeAnnotations([anObject], withCompletionHandler: nil)
//      mapClusterController.addAnnotations([anObject], withCompletionHandler: nil)
//      mapView.removeAnnotation(anObject)
//      mapView.addAnnotation(anObject)
    }
  }
}

// MARK: -UITabbarDelegate
extension StationsListViewController {
  func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    switch item.tag {
    case 1:
      switchToMap()
    case 0:
      switchToList()
    default: break
    }
  }
}

//MARK: -UISearchBarDelegate 
extension StationsListViewController:UISearchBarDelegate {
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    
    guard let text = searchBar.text else {
      assert(true, "Text field text is nil!")
      return
    }
    
    let geoOperation = GeocodingSyncOperation(request: text)
    
    syncManager.addOperations([geoOperation]) { [weak self] (success, results, error) -> Void in
      
      
      guard let guardSelf = self else {
        return
      }
      
      guard success, let firstPlacemark = results.first as? CLPlacemark, let coordinate = firstPlacemark.location?.coordinate  else {
        return
      }
      
//      guardSelf.mapView.setUserTrackingMode(.None, animated: false)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      
      if nil != guardSelf.currentLocationAnnotation {
        guardSelf.mapView.removeAnnotation(guardSelf.currentLocationAnnotation!)
      }
      
      guardSelf.mapView.addAnnotation(annotation)
      guardSelf.currentLocationAnnotation = annotation
      
      guardSelf.mapView.showAnnotations([annotation], animated: true)
      let distanceOpeartion = UpdateDistanceSyncOperation(center: guardSelf.currentLocationAnnotation!.coordinate)
      guardSelf.syncManager.addOperations([distanceOpeartion], completionBLock: { (success, results, error) -> Void in
        
      })
    }
    
  }
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
  }

}

