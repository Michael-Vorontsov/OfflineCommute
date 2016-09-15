//
//  OCCachableTileOverlay.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/06/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

class OCCachableTileOverlay: MKTileOverlay {
  //  class VHTileOverlay:MKTileOverlay {
  
  let operationQueue = NSOperationQueue()
  let directoryPath = NSFileManager.applicationCachesDirectory
  let session = NSURLSession.sharedSession()
  
  override init(URLTemplate: String?) {
    super.init(URLTemplate: URLTemplate)
  }
  
  //  override func URLForTilePath(path: MKTileOverlayPath) -> NSURL {
  //    return NSURL(string: NSString(format: "http://tile.openstreetmap.org/%ld/%ld/%ld.png", path.z, path.x, path.y) as String)!
  //  }
  
  override func loadTileAtPath(path: MKTileOverlayPath, result: (NSData?, NSError?) -> Void) {
    //    guard let result = result else {
    //      return
    //    }
    
    var pathToFile = self.URLForTilePath(path).absoluteString
    pathToFile = pathToFile!.stringByReplacingOccurrencesOfString("/", withString: "|")
    if let cachedData = self.loadFileWithName(pathToFile! as String) {
      result(cachedData, nil)
    }
    
    let task = session.dataTaskWithURL(self.URLForTilePath(path)) { (data, response, error) in
      if let data = data {
        self.saveFileWithName(pathToFile!, imageData: data)
      }
      result(data, error)
    }
    task.resume()
    
  }
  
  func pathToImage(imageName:String) -> NSURL {
    let imageFile = directoryPath.URLByAppendingPathComponent(imageName)
    return imageFile!
  }
  
  func loadFileWithName(fileName:String) -> NSData? {
    let data = NSData(contentsOfURL: pathToImage(fileName))
    return data
  }
  
  func saveFileWithName(name:String, imageData:NSData) -> Bool {
    let success = imageData.writeToURL(pathToImage(name), atomically: true)
    return success
  }
  
}
