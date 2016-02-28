// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import Foundation

/**
  Abstract class for POST operations.
 
 Insert parameters into a body in x-www-form-urlencoded format.
 */

class PostSyncOperation: BasicSyncOperation {

  override func request() -> NSURLRequest {
    let request = NSMutableURLRequest(URL: NSURL(string: self.requestPath())!)
    request.HTTPMethod = "POST"
    if (nil != self.requestParrameters()) {
      request.HTTPBody = PostSyncOperation.convertToQuerry(self.requestParrameters()!).dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    
    for (key, value) in self.requestHeaders()! {
      request.addValue(value, forHTTPHeaderField:key)
    }
    
    return request
  }
  
  override func requestHeaders() -> [String : String]? {
    let headers =
    [
      "Content-Type" : "application/x-www-form-urlencoded",
      //// Uncomment line bellow to get an error respond from Mock service
      //        "prefered" : "status=400",
    ]
    return headers
  }
  
  
}
