// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import Foundation

private struct Constants {
  static let baseMockAddress = "http://private-c1975-lebarawallet.apiary-mock.com/v1"
  static let baseTFLAddress = "https://api.tfl.gov.uk"
  
//  https://api.tfl.gov.uk/BikePoint?app_id=&app_key=
  
  static let appId = "f931f27e"
  static let appKey = "2692ab08868e3f112a0fc60ca8f5141f"
  
  static let appIdKey = "app_id"
  static let appKeyKey = "app_key"
}

/**
 Enumb descrived states of sync data
 */
public enum SyncOperationState:Int {
  case Created
  case SubmittingRequest
  case AwaitingRawData
  case ProcessingData
  case Parsing
  case Completed
  case Error
  case Cancelled
}

/**
 Base abstract class for sync operations.
 
 Allow to request from server data and parse it to application object and store it to CoreData in single operation.
 
 Mandatory for subclassing:
  1. requestPath
  2. parseObjects
 Optional for subclassing:
 1. request - allow to setup request by default - get request without headers and data
 2. requestParrameters -allow to specify parameters, not used in basic operation.
 3. requestHeaders - allow to customize headers
 */

public class BasicSyncOperation: NSOperation {

  // MARK: Operation results
  
  public lazy internal(set) var baseServiceAddress:String = {
    
    return Constants.baseTFLAddress
  }()

  /**
  Readonly property contains error if happened during operation execution
  */
  public internal(set) var error:NSError?
  
  /**
   Readonly property contains object parsed during operation execution
   */
  public internal(set) var results:[AnyObject]?
  
  /**
   Current operation state
   */
  public internal(set) var state: SyncOperationState = SyncOperationState.Created
  
  /**
   String URL path for operation request. Mandatory for subclassing
   */
  public func requestPath() -> String  {
    return ""
  }
  
  /**
   Request parameters. No parameters available by default
   */
  public func requestParrameters() -> [String: AnyObject]? {
    return [Constants.appIdKey : Constants.appId, Constants.appKeyKey : Constants.appKey]
  }

  /**
   Request headers. No headers provided by default
   */
  public func requestHeaders() -> [String: String]?  {
    return nil
  }
  
  /**
   Function responsible for parsing retrived data to app objects. 
   Mandatory for subclassing!
   No parsing perfromed by default.
   */
  public func parseObjects(dataInfo : AnyObject) -> [AnyObject] {
    var objects:[AnyObject]? = nil
    if (!cancelled) {
      objects =  [dataInfo]
      self.results = objects
    }
    return objects!;
  }
  
  /**
   Generate URL Request. Can be updated in subclass, use requestPath by default
   */
  public func request() -> NSURLRequest {
   return NSURLRequest(URL: NSURL(string: self.requestPath())!)
  }
  
  /**
   Network session task
   */
  private var task:NSURLSessionDataTask?
  
  /**
   Main
   */
  override public func main() {
    guard !cancelled else {
      return;
    }
    let semaphore:dispatch_semaphore_t = dispatch_semaphore_create(0);
    
    let session = NSURLSession.sharedSession()
    
    task = session.dataTaskWithRequest(request()) { (data, response, nserror) -> Void in
      guard !self.cancelled else {
        dispatch_semaphore_signal(semaphore)
        return;
      }
      
      guard nil == nserror, let data = data else {
        self.state = .Error
        self.error = nserror
        self.cancel()
        dispatch_semaphore_signal(semaphore)
        return;
      }
      
//      let stringData = NSString(data: data, encoding: 0)
      
      self.state = .ProcessingData
      do {
        let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        self.state = .Parsing
        self.results = self.parseObjects(jsonData)
      } catch {
        self.error = nserror
        self.cancel()
      }
      
      dispatch_semaphore_signal(semaphore)
      self.task = nil;
    }
    
    self.state = .AwaitingRawData
    task!.resume()
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    self.state = self.cancelled ? (nil == self.error ? .Cancelled : .Error) : .Completed
  }
  
  /**
  Cancelation
  */
  override public func cancel() {
    task?.cancel()
    super.cancel()
  }

  public func breakWithError(error:NSError!) {
    self.error = error
    self.cancel()
  }
  
}

// Convert parameters to URL string. 
// Code below taken from Alamofire framework
//
// Copyright (c) 2014–2016 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

extension BasicSyncOperation {

  static func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
    var components: [(String, String)] = []
    
    if let dictionary = value as? [String: AnyObject] {
      for (nestedKey, value) in dictionary {
        components += queryComponents("\(key)[\(nestedKey)]", value)
      }
    } else if let array = value as? [AnyObject] {
      for value in array {
        components += queryComponents("\(key)[]", value)
      }
    } else {
      components.append((escape(key), escape("\(value)")))
    }
    
    return components
  }
  
  static func escape(string: String) -> String {
    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    
    let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
    allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
    
    var escaped = ""
    
    //==========================================================================================================
    //
    //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
    //  hundred Chinense characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
    //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
    //  info, please refer to:
    //
    //      - https://github.com/Alamofire/Alamofire/issues/206
    //
    //==========================================================================================================
    
    if #available(iOS 8.3, OSX 10.10, *) {
      escaped = string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
    } else {
      let batchSize = 50
      var index = string.startIndex
      
      while index != string.endIndex {
        let startIndex = index
        let endIndex = index.advancedBy(batchSize, limit: string.endIndex)
        let range = Range(start: startIndex, end: endIndex)
        
        let substring = string.substringWithRange(range)
        
        escaped += substring.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? substring
        
        index = endIndex
      }
    }
    
    return escaped
  }
  
  static func convertToQuerry(parameters: [String: AnyObject]) -> String {
    var components: [(String, String)] = []
    
    for (key, value) in parameters {
      components += queryComponents(key, value)
    }
    
    return (components.map { "\($0)=\($1)" } as [String]).joinWithSeparator("&")
  }
}
