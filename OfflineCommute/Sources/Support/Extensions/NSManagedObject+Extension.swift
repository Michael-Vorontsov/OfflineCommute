//
//  NSManagedObject+Extension.swift
//  wallet
//
//  Created by Mykhailo Vorontsov on 25/02/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData

protocol NamedManagedObject {
  static var enityName: String {get}
}

extension NamedManagedObject where Self: NSManagedObject {
  static var enityName:String {
    return NSStringFromClass(Self).componentsSeparatedByString(".").last ?? ""
  }
}