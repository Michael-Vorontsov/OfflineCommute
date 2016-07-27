//
//  UIViewController+MapViewContainer.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 26/07/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import MapKit
import UIKit

protocol MapContainerController: MKMapViewDelegate {
  var mapViewContainer:UIView! {get}
  var mapView:MKMapView! {get set}
  func setupMapView()
}

extension MapContainerController {
  
  func setupMapView() {
    let mapView = MKMapView(frame: self.mapViewContainer.bounds)
    mapView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    mapView.delegate = self
    
    let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png";
    let overlay = OCCachableTileOverlay(URLTemplate: template)
    overlay.canReplaceMapContent = true
    
    mapView.setUserTrackingMode(.FollowWithHeading, animated: false)
    // Comment/Uncomment below to toggle cachable map tiles
    mapView.addOverlay(overlay, level: .AboveLabels)
    
    mapViewContainer.addSubview(mapView)
    self.mapView = mapView
  }
  
}