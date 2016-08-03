//
//  CacheTilesGroupOperation.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 03/08/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

//typealias Limits<T> = (min:T, max:T)
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
  
  public func prepareForRetrieval() throws {}
  

}
