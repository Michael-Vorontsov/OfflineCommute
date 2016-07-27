//
//  RouteTrackingViewController.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 26/07/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

class RouteTrackingViewController: UIViewController, MapContainerController {
  
  @IBOutlet weak var mapViewContainer: UIView!
  
  lazy var mapView:MKMapView! = {
    self.setupMapView()
    return self.mapView
  }()
  
  @IBOutlet weak var trackingControlButton: UIButton!
  
//  var trackingController: RouteTrackingController 
  
  var tracking:Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    _ = mapView
//    setupMapView()
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func startTracking() {
    guard !tracking else {
      return
    }
    tracking = true
  }
  
  func stopTracking() {
    guard tracking else {
      return
    }
    tracking = false
  }
  
  @IBAction func trackTouched(sender: AnyObject) {
    if tracking {
      stopTracking()
    } else {
      startTracking()
    }
  }

  
}

// MARK: - MKMapViewDelegate
extension RouteTrackingViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    let render = MKTileOverlayRenderer(overlay: overlay)
    return render
  }
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

    let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? BadgeAnnotationView
      ?? BadgeAnnotationView(annotation: annotation, reuseIdentifier: "pin")
    
    annotationView.canShowCallout = true
    configureAnnotationView(annotationView, forAnnotation: annotation)
    
    return annotationView
  }
  
  func configureAnnotationView(view:MKAnnotationView, forAnnotation annotation:MKAnnotation) {
    
    view.canShowCallout = true
    
    guard let view = view as? BadgeAnnotationView, let annotation = annotation as? DockStation else {
      return
    }
    
    let bikesCount = annotation.bikesAvailable?.integerValue ?? 0
    let dockCount = annotation.vacantPlaces?.integerValue ?? 0
    
    view.rates = [bikesCount, dockCount]
  }
}
