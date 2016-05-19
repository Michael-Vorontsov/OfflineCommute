//
//  Waypoint+CoreDataProperties.swift
//  OfflineCommute
//
//  Created by Mykhailo Vorontsov on 18/05/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Waypoint {

    @NSManaged var lng: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var lat: NSNumber?

}
