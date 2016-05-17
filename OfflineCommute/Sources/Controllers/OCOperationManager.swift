//
//  OCOperationManager.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 17/05/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

private struct Constants {
  static let appIdKey = "app_id"
  static let appKeyKey = "app_key"
}

protocol TFLOperation:NetworkDataRetrievalOperationProtocol {}

class OCOperationManager: DataRetrievalOperationManager {
  
  let appKey:String
  let appId: String
  
  init(remote:String, appKey:String, appID:String) {
    self.appKey = appKey
    self.appId = appID
    super.init(remote: remote)
  }
  
  override internal func prepareOperation(operation:NSOperation) {
    super.prepareOperation(operation)
    if let operation = operation as? TFLOperation {
      var parameters =  operation.requestParameters ?? [String : AnyObject]()
      parameters[Constants.appIdKey] = appId
      parameters[Constants.appKeyKey] = appKey
      operation.requestParameters = parameters
    }
    
  }


}
