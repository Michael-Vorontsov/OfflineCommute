//
//  TilesCacheDataRetrievalOperation.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/07/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

private struct Constants {
  static let openStreetMapRequestFormat = "http://tile.openstreetmap.org/%ld/%ld/%ld.png"
}

import UIKit

class TilesCacheDataRetrievalOperation: NetworkDataRetrievalOperation {
  
  private var downloadLocation: NSURL? = nil
  private let coordinate:(x:Int, y:Int, z:Int)
  
  init(x:Int, y:Int, z:Int, directory:NSURL? = nil) {
    coordinate = (x,y,z)
    downloadLocation = directory
    super.init()
  }
  
  override func prepareForRetrieval() throws {
    requestEndPoint = NSString(format: Constants.openStreetMapRequestFormat, coordinate.z, coordinate.x, coordinate.y) as String
    try super.prepareForRetrieval()
  }
  
  override func convertData() throws {
    guard let data = data else {
      throw DataRetrievalOperationError.NoData
    }

    let fileName = requestEndPoint!.stringByReplacingOccurrencesOfString("/", withString: "|")
    let directoryLocation = downloadLocation ?? NSFileManager.applicationCachesDirectory
    let cacheFilePath = directoryLocation.URLByAppendingPathComponent(fileName)
    data.writeToURL(cacheFilePath, atomically: true)
    
  }
  
}
