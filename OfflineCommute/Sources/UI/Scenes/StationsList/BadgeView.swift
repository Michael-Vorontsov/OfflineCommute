//
//  BadgeView.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/06/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

class BadgeAnnotationView: MKAnnotationView {
  
  private lazy var badge:BadgeView = {
    let badgeView = BadgeView(frame: CGRectMake(0,0, 30, 30))
    badgeView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    self.addSubview(badgeView)
    return badgeView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    frame = CGRectMake(0, 0, 30, 30)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  var obsoleteness:CGFloat {
    set {
      self.badge.obsoleteness = newValue
    }
    get {
      return self.badge.obsoleteness
    }
  }
  
  var rates:[Int]? {
    set {
        self.badge.rates = newValue
    }
    get {
      return self.badge.rates
    }
  }
  
  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    self.bounds = badge.bounds
  }
  
}

class BadgeView: UIView {
  
  var rates:[Int]? {
    didSet {
        setNeedsDisplay()
    }
  }
  
  var obsoleteness:CGFloat = 1.0 {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  var total:Int?  {
    get {
      var total = 0
      guard let rates = self.rates else { return 0}
      for rate in rates {
        total += rate
      }
      return total
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clearColor()
    opaque = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = UIColor.clearColor()
    opaque = false
    
  }
  
  func colorForIndex(index:Int) -> UIColor {
    return (index % 2 == 0) ? UIColor.redColor().grayscale(obsoleteness) : UIColor.blueColor().grayscale(obsoleteness)
  }
  
  override func drawRect(rect: CGRect) {
    
    super.drawRect(rect)
    
    let radius = floor(min(bounds.size.width, bounds.size.height) / 2.0) - 2.0
    let center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
    var angle:CGFloat = 0.0
    
    guard let total = self.total, let rates = rates else {return}
    var index = 0
    for rate in rates {
      colorForIndex(index).setStroke()
      let endAngle:CGFloat = angle + CGFloat(rate) / CGFloat(total) * CGFloat(M_PI * 2.0)
      let path = UIBezierPath(arcCenter: center,
                              radius: radius,
                              startAngle: angle,
                              endAngle: endAngle,
                              clockwise: true)
      angle = endAngle
      path.lineWidth = 5.0
      path.stroke()
      index += 1
    }
  }
  
}
