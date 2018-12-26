//
//  APICache+CoreDataProperties.swift
//  
//
//  Created by Subramanian on 5/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension APICache {

    @NSManaged var createdAt: NSDate?
    @NSManaged var ttl: NSDate?
    @NSManaged var key: String?
    @NSManaged var value: NSData?

}
