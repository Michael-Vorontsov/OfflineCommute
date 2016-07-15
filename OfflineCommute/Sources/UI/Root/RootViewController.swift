//
//  RootViewController.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 08/07/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

enum DockStationMode: Int {
  
  case List
  case Map
  
  func next() -> DockStationMode {
    return DockStationMode(rawValue: rawValue + 1) ?? .List
  }
}

class RootViewController: UIViewController, UITabBarDelegate {
  
  @IBOutlet weak var tabView: UITabBar!
  @IBOutlet weak var dockLocatorButton: UITabBarItem!
  var subNavController:UINavigationController! = nil
  
  var dockStationsMode:DockStationMode = .List
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dockLocatorButton.title = ".list".localized();
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func titleForDockStationMode(mode:DockStationMode) -> String {
    switch dockStationsMode {
    case .List:
      return "list".localized()
      
    case .Map:
      return "map".localized()
      
    default:
      return ""
      
    }
  }
  
  func swithcDockStationModeTouched(item:UITabBarItem) {
    item.badgeValue = titleForDockStationMode(dockStationsMode)
    dockStationsMode = dockStationsMode.next()
    item.title = titleForDockStationMode(dockStationsMode)
    
    guard let stationController = subNavController.topViewController as? StationsListViewController else {return}
    switch dockStationsMode {
    case .List:
      stationController.switchToList()
    case .Map:
      stationController.switchToMap()
    }
  }
  
  func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    
    if item == dockLocatorButton {
      swithcDockStationModeTouched(item)
    }
    
  }
  
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepareForSegue(segue, sender: sender)
    if let newNavController = segue.destinationViewController as? UINavigationController {
      subNavController = newNavController
    }
  }
  
  
}
