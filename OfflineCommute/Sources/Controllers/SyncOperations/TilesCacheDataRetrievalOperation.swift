//
//  TilesCacheDataRetrievalOperation.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/07/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

//http:||tile.openstreetmap.org|16|32747|21794.png"

private struct Constants {
  static let opentStreetMapRequetFormat = "http://tile.openstreetmap.org/%ld/%ld/%ld.png"
  //    return NSURL(string: NSString(format: , path.z, path.x, path.y) as String)!
}

import UIKit


class TilesCacheDataRetrievalOperation: NetworkDataRetrievalOperation {

  private let coordinate:(x:Int, y:Int, z:Int)
  
  init(x:Int, y:Int, z:Int) {
    coordinate = (x,y,z)
    super.init()
  }
  
  override func prepareForRetrieval() throws {
    requestEndPoint = NSString(format: Constants.opentStreetMapRequetFormat, coordinate.z, coordinate.x, coordinate.y) as String
    try super.prepareForRetrieval()
  }
  
  override func convertData() throws {
    guard let data = data else {
      throw DataRetrievalOperationError.NoData
    }

    let fileName = requestEndPoint!.stringByReplacingOccurrencesOfString("/", withString: "|")
    
    let cacheFilePath = NSFileManager.applicationCachesDirectory.URLByAppendingPathComponent(fileName)
    data.writeToURL(cacheFilePath, atomically: true)
    
  }
  
}
