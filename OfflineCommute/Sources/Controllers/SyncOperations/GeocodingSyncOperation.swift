// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import Foundation
import CoreLocation

public class GeocodingSyncOperation: DataRetrievalOperation {
  
  lazy var geocoder = {
    return CLGeocoder()
  }()
  
  let requestAddress: String
  
  init(request:String) {
    requestAddress = request
    super.init()
  }
  
  
  override public func retriveData() throws {

    var geoError:NSError? = nil
    let semaphore:dispatch_semaphore_t = dispatch_semaphore_create(0);
    
    geocoder.geocodeAddressString(requestAddress, inRegion: nil) { ( placemarks, error) -> Void in

      geoError = error
      if placemarks != nil {
        self.convertedObject = placemarks
      }
      
      dispatch_semaphore_signal(semaphore)
    }
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    
    guard nil == geoError else {
      throw DataRetrievalOperationError.WrappedNSError(error: geoError!)
    }
  }
  
  override public func parseData() throws {
    self.results = self.convertedObject as? [CLPlacemark]
  }
  
  override public func cancel() {
    geocoder.cancelGeocode()
    super.cancel()
  }
  
}
