//
//  PendingAPI+CoreDataProperties.swift
//  
//
//  Created by Subramanian on 07/11/17.
//
//

import Foundation
import CoreData


extension PendingAPI {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PendingAPI> {
        return NSFetchRequest<PendingAPI>(entityName: "PendingAPI")
    }

    @NSManaged public var url: String?
    @NSManaged public var requestType: String?
    @NSManaged public var postBody: String?
    @NSManaged public var timeStamp: Double

}
