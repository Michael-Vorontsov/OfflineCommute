//
//  StationsListViewController+TableView.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/06/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

private struct Constants {
  static let CellReuseID = "Cell"
  static let ZoomedDistance = 500.0
}

// MARK: -UITableViewDelegate
extension StationsListViewController: UITableViewDataSource, UITableViewDelegate  {
  
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
    if let distance = station.distance?.integerValue where distance > 0 {
      cell.distanceLabel.text = String(distance) + "m"
    } else {
      cell.distanceLabel.text = "-"
    }
    
    cell.badge.rates = [
      station.bikesAvailable.integerValue ?? 0,
      station.vacantPlaces.integerValue ?? 0
    ]
    
    if let updateDate = station.updateDate {
      let lastUpdateTimeInterval = Int(abs(updateDate.timeIntervalSinceNow))
      let maxTime = 5 * 60 * 60
      let obsoleteness =  CGFloat(min(lastUpdateTimeInterval, maxTime)) / CGFloat(maxTime)
      cell.badge.obsoleteness = obsoleteness
      cell.updateTimeLabel.text = stringForNowSinceDate(updateDate)
    } else {
      cell.updateTimeLabel.text = ""
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let dockStation = self.resultsController.objectAtIndexPath(indexPath) as? DockStation else {return}
    
    self.mapClusterController.selectAnnotation(
      dockStation,
      andZoomToRegionWithLatitudinalMeters: Constants.ZoomedDistance,
      longitudinalMeters: Constants.ZoomedDistance
    )
    
  }
  
  func stringForNowSinceDate(date:NSDate) -> String{
    let dateComponents = dateCalendar.components([.Minute , .Hour, .Day], fromDate: date, toDate: NSDate(), options: .MatchStrictly)
    var dateString = ""
    if dateComponents.day > 0 {
      dateString  += "\(dateComponents.day) days"
    } else {
      dateString += "\(dateComponents.hour)h \(dateComponents.minute)m "
      dateString = dateString.stringByReplacingOccurrencesOfString("0h ", withString: "", options: [], range: nil)
      dateString = dateString.stringByReplacingOccurrencesOfString("0m ", withString: "", options: [], range: nil)
    }
    
    if dateString.characters.count > 1 {
      dateString += " ago"
    } else {
      dateString = "fresh"
    }
    
    return dateString
  }
}
