// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import UIKit

/**
 Class responsible for retriving data from remote servever. 
 
 For each data type specific operation should be created.
 */

public class SyncOperationManager: NSObject {
  
  /**
   Shared instance of Sync Manager be accessible in different part of application
   */
  public static let sharedManager = SyncOperationManager()

  /**
   Operation queue
   */
  private(set) lazy var operationQueue: NSOperationQueue = {
    return NSOperationQueue()
  }()
  
  /**
   Helpers function for creating completion block operation for specififc operations
   */
  private func completionBlockOperationForOperations(operations:[BasicSyncOperation],
    completionBLock: (success:Bool, results:[AnyObject] , error:NSError?) -> Void) -> NSOperation {
    
    let completionOperation = NSBlockOperation { () -> Void in
      var success = true
      var error:NSError? = nil
      var results:[AnyObject]! = []
      
      for operation: BasicSyncOperation in operations {
        guard operation.finished && !operation.cancelled else {
          error = operation.error
          success = false
          break
        }
        if (operation.results?.count > 0) {
          results.appendContentsOf(operation.results!)
        }

      }
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionBLock(success: success, results: results, error: error)
      })
    }
    return completionOperation
  }
  
  /**
   Add operations to Queue with completion block
   */
  func addOperations(operations: [BasicSyncOperation],
    completionBLock: (success: Bool, results: [AnyObject], error: NSError?) -> Void) -> Void {
    
      let completionOperation = completionBlockOperationForOperations(operations, completionBLock: completionBLock)
      
      for operation in operations {
        completionOperation.addDependency(operation)
      }
      
      self.operationQueue.addOperations(operations, waitUntilFinished: false)
      self.operationQueue.addOperation(completionOperation)
  }
  
}
