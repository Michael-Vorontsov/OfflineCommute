//
//  DockStationFileOperation.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 19/05/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData

/// Operation to fetch dock stations from file, if not bundle available yet.
class DockStationFileOperation: DataRetrievalOperation, ObjectBuildeOperationProtocol {
  
  var objectBuilder:ObjectBuilder!
  var fileURL:NSURL!
  
  override init() {
    super.init()
    // Consider pedendency on common net operation, so it should continue executing after net operation failed
    force = true
  }

  override func prepareForRetrieval() throws {
    
    var shouldBreak = false
    
    // If docks avaialable -> cancel operation
    let context = objectBuilder.coreDataManager.dataContext
    context.performBlockAndWait { 
      let fetchRequest = NSFetchRequest(entityName: "DockStation")
      let allStations = try? context.executeFetchRequest(fetchRequest)
      if allStations?.count > 0 {
        shouldBreak = true
      }
    }
    
    guard false == shouldBreak else {
      self.cancel()
      return
    }
    
    let fileURL = NSBundle.mainBundle().URLForResource("bikepoints", withExtension: "json")
    self.fileURL = fileURL
  }
  
  override func retriveData() throws {
    guard fileURL != nil else {
      throw DataRetrievalOperationError.InvalidParameter(parameterName: "fileURL")
    }
    data = NSData(contentsOfURL: fileURL)
  }
  
  override func convertData() throws {
    guard let data = data  else {
      throw DataRetrievalOperationError.InvalidParameter(parameterName: "data")
    }
    convertedObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
  }
  
  override func parseData() throws {
    
    guard let dataInfo = self.convertedObject as? [NSDictionary] else {
      return
    }
    
    self.results = objectBuilder.buildDoctStations(dataInfo)
  }
  

}
