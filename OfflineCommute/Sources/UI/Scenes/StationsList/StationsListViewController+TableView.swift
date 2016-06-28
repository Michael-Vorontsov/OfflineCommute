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
}

// MARK: -UITableViewDelegate
extension StationsListViewController: UITableViewDataSource  {
  
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
    
    cell.badge.rates = [station.bikesAvailable.integerValue ?? 0,
      station.vacantPlaces.integerValue ?? 0
    ]
    
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
