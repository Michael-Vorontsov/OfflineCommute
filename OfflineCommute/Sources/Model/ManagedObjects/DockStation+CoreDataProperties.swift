//
//  DockStation+CoreDataProperties.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 27/02/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DockStation {

    @NSManaged var distance: NSNumber?
    @NSManaged var address: String?
    @NSManaged var longitude: NSNumber!
    @NSManaged var latitude: NSNumber!
    @NSManaged var title: String!
    @NSManaged var active: NSNumber?
    @NSManaged var totalPlaces: NSNumber?
    @NSManaged var vacantPlaces: NSNumber?
    @NSManaged var sid: String!
    @NSManaged var bikesAvailable: NSNumber?
    @NSManaged var updateDate: NSDate!

}
