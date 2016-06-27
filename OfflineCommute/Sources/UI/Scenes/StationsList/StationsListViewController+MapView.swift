//
//  StationsListViewController+MapView.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/06/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CCHMapClusterController

private struct Constants {
  static let pinViewReuseID = "Pin"
  static let clusterViewReuseID = "Cluster"
  static let animationDuration = 0.5
}

extension StationsListViewController: CCHMapClusterControllerDelegate {
  func mapClusterController(mapClusterController: CCHMapClusterController!, willReuseMapClusterAnnotation mapClusterAnnotation: CCHMapClusterAnnotation!) {
    guard let view = self.mapView.viewForAnnotation(mapClusterAnnotation) as? OCClusterAnotationView else { return }
    view.count = mapClusterAnnotation.annotations.count
    
  }
  
  func mapClusterController(mapClusterController: CCHMapClusterController!, titleForMapClusterAnnotation mapClusterAnnotation: CCHMapClusterAnnotation!) -> String! {
    guard let dockAnnotation = mapClusterAnnotation.annotations.first as? DockStation where !mapClusterAnnotation.isCluster() else { return nil}
    return dockAnnotation.title
  }
  
  func mapClusterController(mapClusterController: CCHMapClusterController!, subtitleForMapClusterAnnotation mapClusterAnnotation: CCHMapClusterAnnotation!) -> String! {
    guard let dockAnnotation = mapClusterAnnotation.annotations.first as? DockStation where !mapClusterAnnotation.isCluster() else { return nil}
    return dockAnnotation.subtitle
  }
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
  }
  
}

// MARK: - MKMapViewDelegate
extension StationsListViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    let render = MKTileOverlayRenderer(overlay: overlay)
    return render
  }
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
    let clusterAnnotation = annotation as? CCHMapClusterAnnotation
    if  let  clusterAnnotation = clusterAnnotation where clusterAnnotation.isCluster() {
      let clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.clusterViewReuseID) as? OCClusterAnotationView
        ?? OCClusterAnotationView(annotation: clusterAnnotation, reuseIdentifier: Constants.clusterViewReuseID)
      clusterView.count = clusterAnnotation.annotations.count
      return clusterView
    }
    
    guard let dockAnnotation = clusterAnnotation?.annotations.first as? DockStation ?? annotation as? DockStation else { return nil}
    
    let view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.pinViewReuseID) as? MKPinAnnotationView
      ?? MKPinAnnotationView(annotation: dockAnnotation, reuseIdentifier: Constants.pinViewReuseID)
    
    view.canShowCallout = true
    
//    let callout = UIView(frame: CGRectMake(0,0,10,10))
//    callout.backgroundColor = UIColor.redColor()
    let callout = UIButton(type: .InfoLight)
    view.leftCalloutAccessoryView = callout
    
    
    let bikesCount = dockAnnotation.bikesAvailable?.integerValue ?? 0
    let dockCount = dockAnnotation.vacantPlaces?.integerValue ?? 0
    
    if bikesCount < 1 && dockCount < 1 {
      view.pinTintColor = UIColor.lightGrayColor()
    } else if bikesCount < 1 {
      view.pinTintColor = UIColor.yellowColor()
    } else if dockCount < 1 {
      view.pinTintColor = UIColor.blueColor()
    } else {
      view.pinTintColor = UIColor.greenColor()
    }
    return view
  }
  
}