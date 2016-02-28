// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import UIKit
import CoreLocation

public class GeocodingSyncOperation: BasicSyncOperation {
  
  lazy var geocoder = {
    return CLGeocoder()
  }()
  
  let requestAddress: String
  
  init(request:String) {
    requestAddress = request
    super.init()
  }

  override public func main() {
    guard !self.cancelled else {
      return;
    }
    
    let semaphore:dispatch_semaphore_t = dispatch_semaphore_create(0);
    
    geocoder.geocodeAddressString(requestAddress, inRegion: nil) { ( placemarks, error) -> Void in
      
      guard !self.cancelled else {
        dispatch_semaphore_signal(semaphore)
        return
      }
      
      self.state = .ProcessingData

      guard nil == error else {
        self.breakWithError(error)
        dispatch_semaphore_signal(semaphore)
        return
      }
      
      if placemarks != nil {
        self.results = placemarks!
      }
      
      dispatch_semaphore_signal(semaphore)
    }
    
    self.state = .AwaitingRawData
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    
    self.state = self.cancelled ? (nil == self.error ? .Cancelled : .Error) : .Completed
  }
  
  override public func cancel() {
    geocoder.cancelGeocode()
    super.cancel()
  }
  
}
