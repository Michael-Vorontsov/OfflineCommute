//
//  OCClusterAnnotationView.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/06/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit


class OCClusterAnotationView: MKAnnotationView {
  lazy var label:UILabel = {
    let label = UILabel(frame: self.bounds)
    label.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    label.textAlignment = .Center
    label.textColor = UIColor.whiteColor()
    self.addSubview(label)
    label.backgroundColor = UIColor.blueColor()
    
    return label
  }()
  
  var count:Int {
    get {
      return Int(label.text!)!
    }
    set {
      label.text = String(newValue)
      
      let sizePoint:CGFloat = 5.0
      let annotationsCount = newValue
      let scale = Int(log(Double(annotationsCount)))
      let size = 30.0 + sizePoint * CGFloat(scale)
      let center = self.center
      self.frame = CGRectMake(0, 0, size, size)
      self.center = center
      layer.cornerRadius = size / 2.0
      self.clipsToBounds = true
    }
  }
  
  
}