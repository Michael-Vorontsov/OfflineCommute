//
//  DockStationsSyncOperation.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/02/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData


private struct Constants {
  static let dockStationPath = "/bikepoint"
}


class DockStationsSyncOperation: NetworkDataRetrievalOperation, TFLOperation, ObjectBuildeOperationProtocol {
  
  var objectBuilder:ObjectBuilder!
  
  override func prepareForRetrieval() throws {
    requestPath = Constants.dockStationPath
    try super.prepareForRetrieval()
  }
  
  override func parseData() throws {

    guard let dataInfo = self.convertedObject as? [NSDictionary] else {
      return
    }

    self.results = objectBuilder.buildDoctStations(dataInfo)
  }
  
}
