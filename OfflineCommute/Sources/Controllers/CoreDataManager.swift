// Copyright (c) 2016 Lebara. All rights reserved.
// Author:  Mykhailo Vorontsov <mykhailo.vorontsov@lebara.com>

import UIKit
import CoreData

enum CoreDataError : Int {
  case Unknown = 1000
  case StoreCoordinatorCreation
  case SavingChanges
}

/**
 Class responsible for storing and retriving data from local database
 */
class CoreDataManager: NSObject {
  
  /** 
   Shared instance of Data Manager be accessible in different part of application
   */
  static let sharedManager = CoreDataManager()
  
  /**
   Init CoreDataManager with default database name
   */
  override convenience init() {
    self.init(withDatabaseName: "WalletDB")
  }
  
  /**
   Init CoreDataManager with specified database name
   */
  init(withDatabaseName aDatabaseName:String) {
    databaseName = aDatabaseName
  }
  
  /**
   CoreDataManager error domain
   */
  static let errorDomain: String = {
    return "error.wallet.database"
  }()

  /**
   NSManagedObject context dedicated for UI operations working on main thread
   */
  lazy var mainContext: NSManagedObjectContext = {
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.parentContext = self.persistentContext
    return managedObjectContext
  }()

  /**
   NSManagedObject context dedicated for synchronous data parsing operations working on background thread
   */
  lazy var dataContext: NSManagedObjectContext = {
    return self.backContext()
  }()

  /**
  Creating separate background context to above main context to perfrom backgound data operations
   */
  func backContext()-> NSManagedObjectContext {
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    managedObjectContext.parentContext = self.mainContext
    return managedObjectContext
  }

  /**
   Flush changes in givven context thtough all parent context to persistent store.
   */
  func saveContext (context:NSManagedObjectContext!) {
    if context.hasChanges {
      do {
        try context.save()
        if (nil != context.parentContext) {
          self.saveContext(context.parentContext)
        }
      } catch {
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
        dict[NSLocalizedFailureReasonErrorKey] = "Error while flushing changes to persisten store"
        dict[NSUnderlyingErrorKey] = error as NSError
        let wrappedError = NSError(domain: CoreDataManager.errorDomain, code: CoreDataError.StoreCoordinatorCreation.rawValue, userInfo: dict)
        NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        assert(false)
      }
    }
  }
  
  /**
   Delete sqlite database file from disk
   */
  func wipeDatabase() {
    do {
      for store in persistentStoreCoordinator.persistentStores {
        let storeURL = store.URL!
        try persistentStoreCoordinator.removePersistentStore(store)
        try NSFileManager.defaultManager().removeItemAtURL(storeURL)
      }
      let url = NSFileManager.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.databaseName).sqlite")
      try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch {
      print("Error occured while trying to wipe persistent store")
    }
  }
  
  // MARK: - Private methods
  
  private var databaseName: String

  private lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = NSBundle.mainBundle().URLForResource("OfflineCommute", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = NSFileManager.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.databaseName).sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch {
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: CoreDataManager.errorDomain, code: CoreDataError.StoreCoordinatorCreation.rawValue, userInfo: dict)
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      
      // If error - try to delete database and create it from scratch
      do {
       try NSFileManager.defaultManager().removeItemAtURL(url)
       try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
      } catch {
        abort();
      }
    }
    return coordinator
  }()
  
  /**
   Private context working in background thread with persisten store directly
   */
  private lazy var persistentContext: NSManagedObjectContext = {
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()
}

