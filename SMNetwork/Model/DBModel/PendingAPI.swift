//
//  PendingAPI+CoreDataClass.swift
//  
//
//  Created by Subramanian on 07/11/17.
//
//

import Foundation
import CoreData

public class PendingAPI: NSManagedObject {
    
    // Insert the api details inside the app.
    public static func insertNewRecord(url: String, requestType: String, postBody: String?) {
        let context = SMNetworkCoreDataManager.sharedInstance.createPrivateContext()
        
        let apiCache: PendingAPI = NSEntityDescription.insertNewObject(forEntityName: Database.Entities.PendingAPI, into: context) as! PendingAPI
        apiCache.url = url
        apiCache.requestType = requestType
        
        apiCache.timeStamp = APICache.currentTimeInGMT()?.timeIntervalSinceReferenceDate ?? Double(arc4random())
        Logger.log(message: "Timestamp - \(apiCache.timeStamp)")
        apiCache.postBody = postBody
        
        SMNetworkCoreDataManager.sharedInstance.saveContext(context: context)
    }
    
    
    //Get the pending api details
    static func getPendingAPIs(predicate: NSPredicate?, sort : [NSSortDescriptor]?, context: NSManagedObjectContext) -> [PendingAPI]? {
        
        let (result, error) =  SMNetworkCoreDataManager.sharedInstance.fetchRequest(entity: Database.Entities.PendingAPI, predicate: predicate, sortDescriptors: sort, context: context)
        
        guard error == nil else {
            return nil
        }
        
        guard let pendingRequestList = result, pendingRequestList.count > 0 else {
            return nil
        }
        
        return result as? [PendingAPI]
    }
    
    // Delete a record from base on predicate
    static func deleteRecord(predicate: NSPredicate?, context: NSManagedObjectContext) {
        
        if let listOfPendingAPIs = getPendingAPIs(predicate: predicate, sort: nil, context: context) {
            
            for pendingAPI in listOfPendingAPIs {
                context.delete(pendingAPI)
                SMNetworkCoreDataManager.sharedInstance.saveContext(context: context)
            }
        }
    }
}
