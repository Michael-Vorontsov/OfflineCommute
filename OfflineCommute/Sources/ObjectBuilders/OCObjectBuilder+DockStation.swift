//
//  OCObjectBuilder+DockStation.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 19/05/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData

private struct Constants {
  
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

extension ObjectBuilder {
  
  func buildDoctStations(dataInfo:[NSDictionary]) -> [NSManagedObjectID] {
    let context = coreDataManager.dataContext
    var results = [NSManagedObjectID]()
    context.performBlockAndWait() {
     
      // Clear old data
      
//      if let oldDocks = ((try? context.executeFetchRequest(NSFetchRequest(entityName: "DockStation"))) as? [NSManagedObject]) where oldDocks.count > 0 {
//        context.deleteObjects(oldDocks)
//      }
      let oldDocks = ((try? context.executeFetchRequest(NSFetchRequest(entityName: "DockStation"))) as? [DockStation])
      
      let formatter = NSDateFormatter()
      //2016-02-27T19:39:34.263
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
      
      for dockStationData in dataInfo {
        
        
        
        guard let name = dockStationData[Constants.nameKey] as? String,
          //          let typeString = dockStationData[Constants.typeKey] as? String,
          let serverID = dockStationData[Constants.serverIDKey] as? String,
          let latitude = dockStationData[Constants.latitudeKey] as? Double,
          let longitude = dockStationData[Constants.longitudeKey] as? Double,
          let additional = dockStationData[Constants.additonalPropertiesKey] as? [NSDictionary] else {
            break;
        }
        
//        let predicate = NSPredicate(format: "name = %@", name)
//        oldD
      let dockStation = oldDocks?.filter({ (element) -> Bool in
        return element.title == name
      }).last ?? NSEntityDescription.insertNewObjectForEntityForName("DockStation", inManagedObjectContext: context) as! DockStation
//      else {
//        break

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
      
      context.save(recursive: true)
    }
    return results
  }
  
}