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
import Mapbox

private struct Constants {
  static let CellReuseID = "Cell"
  static let pinViewReuseID = "Pin"
  static let animationDuration = 0.5
}

//extension MKAnnotation where Self:DockStation {
//extension MGLAnnotation where Self:DockStation {
extension DockStation: MGLAnnotation {
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

class StationsListViewController: LocalizableViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITabBarDelegate {

  @IBOutlet weak var mapViewContainer: UIView!
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.tableFooterView = UIView()
    }
  }
  
  lazy var mapView:MGLMapView = {
    let mapView = MGLMapView(frame: self.mapViewContainer.bounds)
    mapView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    return mapView
    
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
  
  var currentLocationAnnotation:MGLAnnotation?
  
  lazy var resultsController:NSFetchedResultsController = {
    let fetchRequest = NSFetchRequest(entityName: "DockStation")
    
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: true), NSSortDescriptor(key: "sid", ascending: true)]
    
//    fetchRequest.predicate = NSPredicate(format: "distance < 1000", argumentArray: nil)
    
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
    
    mapViewContainer.addSubview(mapView)
    
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
//    mapView.showsUserLocation = true
//    mapView.setUserTrackingMode(.FollowWithHeading, animated: true)
    
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
    let netOperation = DockStationsSyncOperation()
    let fileOperation = DockStationFileOperation()
    let distanceOpeartion = UpdateDistanceSyncOperation(center: CLLocationCoordinate2DMake( 51.5085300, -0.1257400))
    fileOperation.addDependency(netOperation)
    
    distanceOpeartion.addDependency(netOperation)
    distanceOpeartion.addDependency(fileOperation)
    
    syncManager.addOperations([netOperation, fileOperation, distanceOpeartion]) { (success, results, error) -> Void in
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
  }
  

}



// MARK: -UITableViewDelegate
extension StationsListViewController {
  

  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return resultsController.fetchedObjects?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellReuseID, forIndexPath: indexPath) as? DockStationCell,
      let station = resultsController.objectAtIndexPath(indexPath) as? DockStation
      else {
        return UITableViewCell(style: .Default, reuseIdentifier: nil)
    }
    
    cell.nameLabel.text = station.title
    cell.vacantPlacesLabel.text = station.vacantPlaces?.stringValue ?? "-"
    cell.bikesAvalialbleLabel.text = station.bikesAvailable?.stringValue ?? "-"
    cell.distanceLabel.text = String((Int(station.distance ?? 0.0))) + "m" ?? "-"
    
//    NSDateComponents *components = [c components:NSHourCalendarUnit fromDate:d2 toDate:d1 options:0];
//    NSInteger diff = components.minute;
    if (nil != station.updateDate) {
      cell.updateTimeLabel.text = stringForNowSinceDate(station.updateDate)
    } else {
      cell.updateTimeLabel.text = ""
    }
    
    return cell
  }
  
  func stringForNowSinceDate(date:NSDate) -> String{
//    let dateComponents = dateCalendar.components([.Minute , .Hour, .Day], fromDate: date)
    let dateComponents = dateCalendar.components([.Minute , .Hour, .Day], fromDate: date, toDate: NSDate(), options: .MatchStrictly)
    var dateString = "Updated:"
    if dateComponents.day > 0 {
      dateString += "\(dateComponents.day)d "
    }
    if dateComponents.hour > 0 {
      dateString += "\(dateComponents.hour)h "
    }
    if dateComponents.minute > 0 {
      dateString += "\(dateComponents.minute)m "
    }
    dateString += "ago"
    return dateString
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
      mapView.addAnnotation(anObject)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
      mapView.removeAnnotation(anObject)
    case  .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
    case .Update:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      mapView.removeAnnotation(anObject)
      mapView.addAnnotation(anObject)
    }
  }
}

// MARK: - MKMapViewDelegate
extension StationsListViewController {
//  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//    guard let annotation = annotation as? DockStation else {
//      return nil
//    }
//    let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.pinViewReuseID)
//    
//    view.canShowCallout = true
//
//    let bikesCount = annotation.bikesAvailable?.integerValue ?? 0
//    let dockCount = annotation.vacantPlaces?.integerValue ?? 0
//
//    if bikesCount < 1 && dockCount < 1 {
//      view.pinTintColor = UIColor.lightGrayColor()
//    } else if bikesCount < 1 {
//      view.pinTintColor = UIColor.yellowColor()
//    } else if dockCount < 1 {
//      view.pinTintColor = UIColor.blueColor()
//    } else {
//      view.pinTintColor = UIColor.greenColor()
//    }
//    
//    return view
//  }
  
//  func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
//    
//  }
  
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
      
      guardSelf.mapView.setUserTrackingMode(.None, animated: false)
      
      let annotation = MGLPointAnnotation()
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

