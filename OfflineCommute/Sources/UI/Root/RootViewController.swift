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

extension UINavigationController {
  /**
   Switch to view controller by poping if it stack or by pushing otherwise.
   
   - parameter controller: controller to switch
   - parameter animated:   animate if true
   
   - returns: true if switched, false otherwise (usually it it is already on screen)
   */
  func switchToController(controller: UIViewController, animated:Bool = true) -> Bool {
    guard controller != topViewController else {
      return false
    }
    
    if viewControllers.contains(controller) {
      popToViewController(controller, animated: animated)
    } else {
      pushViewController(controller, animated: animated)
    }
    return true
  }
}

class RootViewController: UIViewController, UITabBarDelegate {
  
  @IBOutlet weak var tabView: UITabBar!
  @IBOutlet weak var dockLocatorButton: UITabBarItem!
  var subNavController:UINavigationController! = nil
  
  var dockStationsMode:DockStationMode = .List
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dockLocatorButton.title = ".docStation".localized();
    subNavController.switchToController(stationListController, animated: false)
    dockLocatorButton.badgeValue = titleForDockStationMode(dockStationsMode)
}
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    subNavController.viewControllers = [subNavController.topViewController!]
    switch subNavController.topViewController {
    case stationListController?:
      routeTrackingController = nil
    case routeTrackingController?:
      stationListController = nil
    default: break
    }
    
    
    // Dispose of any resources that can be recreated.
  }
  
  private lazy var stationListController:UIViewController! = {
    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("stationListID") as? StationsListViewController
//    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("emptySceneID")
    return controller
  }()
  
  private lazy var routeTrackingController:UIViewController! = {
    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("emptySceneID")
    return controller
  }()
  
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
    dockStationsMode = dockStationsMode.next()
    item.badgeValue = titleForDockStationMode(dockStationsMode)
    
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
      if !subNavController.switchToController(stationListController) {
        swithcDockStationModeTouched(item)
      }
    } else {
      subNavController.switchToController(routeTrackingController)
    }
    
  }
  
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepareForSegue(segue, sender: sender)
    if let newNavController = segue.destinationViewController as? UINavigationController {
      subNavController = newNavController
    }
  }
  
  
}
