//
//  CacheTilesGroupOperation.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 03/08/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

struct Limits<T> {
  let min: T
  let max: T
}

struct MapLimits<T> {
  let x: Limits<T>
  let y: Limits<T>
  let z: Limits<T>
}

class CacheTilesGroupOperation: GroupDataRetrievalOperation {
  
  let constraints:MapLimits<Int>
  
  init(constraints:MapLimits<Int>) {
    self.constraints = constraints
    super.init()
  }
  
  override func prepareForRetrieval() throws {
    var operations = [NSOperation]()
    for zIndex in (constraints.x.min...constraints.x.max) {
      let scale = (zIndex - constraints.z.min + 1) * 2
      for xIndex in ((constraints.x.min - 1) * scale...(constraints.x.max + 1) * scale) {
        for yIndex in ((constraints.x.min - 1) * scale...(constraints.x.max + 1) * scale) {
          let operation = TilesCacheDataRetrievalOperation(x: xIndex, y: yIndex, z:zIndex)
          operations.append(operation)
        }
      }
    }
    self.operations = operations
    try super.prepareForRetrieval()
  }

}
