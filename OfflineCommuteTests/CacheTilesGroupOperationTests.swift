//
//  CacheTilesGroupOperationTests.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 22/08/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
@testable import OfflineCommute

//extension DataRetrievalOperationManager {
//  var operationQueue: NSOperationQueue!
//}


class CacheTilesGroupOperationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
      
//      let queue = NSOperationQueue()
//      queue.suspended = true
      
      let operationManager = DataRetrievalOperationManager(remote: "http://any.address.test")
      
      let operation = CacheTilesGroupOperation(constraints: MapLimits(x: Limits(min: 10, max: 10),
        y:  Limits(min: 20, max: 20),
        z:  Limits(min: 5, max: 6)))
      
      operation.operationManager = operationManager
      
      let predicate = NSPredicate(format: "operations.count > 1", argumentArray: nil)
      operation.stage = .Awaiting
      operation.status = .Queued
        
//         status == .Queued && stage == .Awaiting
      operation.main()
//      let expectation =
//      self.expectationForPredicate(predicate, evaluatedWithObject: operationManager, handler: nil)
      
//      waitForExpectationsWithTimeout(1.0, handler: nil)
      
      let queue = operationManager.valueForKey("operationQueue") as! NSOperationQueue
      queue.suspended = true

      XCTAssert(operationManager.operations.count > 0)
      
      
      
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
