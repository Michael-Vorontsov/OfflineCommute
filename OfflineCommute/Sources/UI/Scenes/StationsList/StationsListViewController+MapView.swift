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
    let annotationView = self.mapView.viewForAnnotation(mapClusterAnnotation)
    
    
    if let clusterView = annotationView as? OCClusterAnotationView {
      if mapClusterAnnotation.isCluster() {
        clusterView.count = mapClusterAnnotation.annotations.count
      } else {
        // Redraw annotation
        mapView.removeAnnotation(mapClusterAnnotation)
        mapView.addAnnotation(mapClusterAnnotation)
        return
      }
    }
    else if let badgeView = annotationView as? BadgeAnnotationView {
      if mapClusterAnnotation.isCluster() {
        // Redraw annotation
        mapView.removeAnnotation(mapClusterAnnotation)
        mapView.addAnnotation(mapClusterAnnotation)
        
        //          badgeView.count = mapClusterAnnotation.annotations.count
      } else {
        guard let dockAnnotation = mapClusterAnnotation?.annotations.first as? DockStation else { return }
        let bikesCount = dockAnnotation.bikesAvailable?.integerValue ?? 0
        let dockCount = dockAnnotation.vacantPlaces?.integerValue ?? 0
        badgeView.rates = [bikesCount, dockCount]
      }
    }
    
  }
  
  func mapClusterController(mapClusterController: CCHMapClusterController!, titleForMapClusterAnnotation mapClusterAnnotation: CCHMapClusterAnnotation!) -> String! {
    
    
    
    if mapClusterAnnotation.isCluster() {
      return String(mapClusterAnnotation.annotations.count)
    }
    
    if let dockAnnotation = mapClusterAnnotation.annotations.first as? DockStation where !mapClusterAnnotation.isCluster() {
      return dockAnnotation.title
    }
    
    return nil
    
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
    
    
    guard let clusterAnnotation = annotation as? CCHMapClusterAnnotation else { return nil}
    if  clusterAnnotation.isCluster() {
      let clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.clusterViewReuseID) as? OCClusterAnotationView
        ?? OCClusterAnotationView(annotation: clusterAnnotation, reuseIdentifier: Constants.clusterViewReuseID)
      clusterView.count = clusterAnnotation.annotations.count
      return clusterView
    }
    
    let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.pinViewReuseID) as? BadgeAnnotationView
      ?? BadgeAnnotationView(annotation: clusterAnnotation, reuseIdentifier: Constants.pinViewReuseID)
    
    guard let dockAnnotation = clusterAnnotation.annotations.first as? DockStation ?? annotation as? DockStation else { return nil}
    
    annotationView.canShowCallout = true
    
    let bikesCount = dockAnnotation.bikesAvailable?.integerValue ?? 0
    let dockCount = dockAnnotation.vacantPlaces?.integerValue ?? 0
    
    annotationView.rates = [bikesCount, dockCount]

    return annotationView
  }

// Animate selected annotation view
//  func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
//    let animation = CABasicAnimation(keyPath: "transform.scale")
//    animation.toValue = 1.5
//    animation.repeatCount = 999
//    animation.autoreverses = true
//    animation.duration = 2.0
//    
//    view.layer.addAnimation(animation, forKey: "transform.scale")
//    
//  }
//  
//  func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
//    view.layer.removeAllAnimations()
//  }
  
}