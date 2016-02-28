//
//  DockStationsSyncOperation.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/02/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreData

private struct Constants {
  static let dockStationPath = "/bikepoint"
  static let nameKey = "commonName"
  static let typeKey = "placeType"
  static let serverIDKey = "id"
  static let latitudeKey = "lat"
  static let longitudeKey = "lon"

  static let keyAddKey = "key"
  static let modifiedAddKey = "modified"
  static let valueAddKey = "value"
  
  static let bikesAddProperty = "NbBikes"
  static let vacantAddProperty = "NbEmptyDocks"
  static let docksAddProperty = "NbDocks"
  static let lockedAddProperty = "Locked"

  static let additonalPropertiesKey = "additionalProperties"
}

class DockStationsSyncOperation: ManagedObjectSyncOperation {
  
  override func requestPath() -> String {
    return baseServiceAddress + Constants.dockStationPath + "?" + BasicSyncOperation.convertToQuerry(self.requestParrameters()!)
  }
  
  override func parseManagedObjects(dataInfo: AnyObject, context: NSManagedObjectContext) -> [NSManagedObjectID] {


    guard let dataInfo = dataInfo as? [NSDictionary] else {
      return []
    }

    // Clear old data
    do {
      let oldDocks = try context.executeFetchRequest(NSFetchRequest(entityName: "DockStation")) as? [NSManagedObject] ?? []
      
      for oldStation in oldDocks {
        context.deleteObject(oldStation)
      }
    } catch {
      
    }
    
    var results:[NSManagedObjectID] = []
    
    let formatter = NSDateFormatter()
//2016-02-27T19:39:34.263
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    
    for dockStationData in dataInfo {
      

      guard let name = dockStationData[Constants.nameKey] as? String,
        let typeString = dockStationData[Constants.typeKey] as? String,
        let serverID = dockStationData[Constants.serverIDKey] as? String,
        let latitude = dockStationData[Constants.latitudeKey] as? Double,
        let longitude = dockStationData[Constants.longitudeKey] as? Double,
        let additional = dockStationData[Constants.additonalPropertiesKey] as? [NSDictionary],
        let dockStation = NSEntityDescription.insertNewObjectForEntityForName("DockStation", inManagedObjectContext: context) as? DockStation
        else {
          break
      }
//      print("\(typeString)")
      
      results.append(dockStation.objectID)
      dockStation.sid = serverID
      dockStation.title = name
      dockStation.latitude = latitude
      dockStation.longitude = longitude
      
      var earliestDate = NSDate()
      
      for addInfo in additional {
        guard let key = addInfo[Constants.keyAddKey] as? String ,
          updateTimeString = addInfo[Constants.modifiedAddKey] as? String,
          value = addInfo[Constants.valueAddKey] as? String else {
            break
        }
        
        
        let string = NSMutableString(string: updateTimeString)
        string.replaceOccurrencesOfString("T", withString: " ", options:.CaseInsensitiveSearch, range: NSMakeRange(0, string.length))
        let date = formatter.dateFromString(String(string)) ?? NSDate()
        
        earliestDate = date.earlierDate(earliestDate)
        
        switch key {
        case Constants.bikesAddProperty:
          guard let value = Int(value) else {
            break
          }
          dockStation.bikesAvailable = value
        case Constants.vacantAddProperty:
          guard let value = Int(value) else {
            break
          }
          dockStation.vacantPlaces = value
        case Constants.docksAddProperty:
          guard let value = Int(value) else {
            break
          }
          dockStation.totalPlaces = value
        case Constants.lockedAddProperty:
          let value = (value as NSString).boolValue
          dockStation.active = !value
        default: break
        }
      }
      dockStation.updateDate = earliestDate
      
    }
    return results
  }

}
