//
//  APICache.swift
//
//
//  Created by Subramanian on 5/6/16.
//
//

import Foundation
import CoreData

internal class APICache: NSManagedObject {
    
    static let timeZone = "GMT"
    static let expiryDateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    
    // MARK: Fetch Data
    static func fetchCachedResponse(uniqueKey: String?, apiObject: APIBase) -> (NSData?, Bool) {
        var initiateRequest: Bool = false
        
        let context = SMNetworkCoreDataManager.sharedInstance.createPrivateContext()
        
        let predicate = NSPredicate(format: "%K == %@", Database.APICacheFields.Key , uniqueKey ?? generateUniqueKey(apiObject: apiObject))
        
        let (result, error) = SMNetworkCoreDataManager.sharedInstance.fetchRequest(entity: Database.Entities.APICache, predicate: predicate, sortDescriptors: nil, context: context)
        
        
        guard error == nil else {
            return (nil, initiateRequest)
        }
        
        guard let cahcedResponseList = result, cahcedResponseList.count > 0 else {
            return (nil, initiateRequest)
        }
        
        let cachedResponseList = getCachedResponse(predicate: predicate, context: context)
        
        if let cachedResponseList = cachedResponseList {
            let managedObject = cachedResponseList[0]
            if let value = managedObject.value {
                if isExpired(ttl: managedObject.ttl!) == true {
                    // If the context is expired then make api request to get latest content
                    initiateRequest = true
                }
                return (value, initiateRequest)
            }
        }
        
        return (nil, initiateRequest)
    }
    
    static func getCachedResponse(predicate: NSPredicate?, context: NSManagedObjectContext) -> [APICache]? {
        
        let (result, error) =  SMNetworkCoreDataManager.sharedInstance.fetchRequest(entity: Database.Entities.APICache, predicate: predicate, sortDescriptors: nil, context: context)
        
        guard error == nil else {
            return nil
        }
        
        guard let cahcedResponseList = result, cahcedResponseList.count > 0 else {
            return nil
        }
        
        return result as? [APICache]
    }
    
    
    // Generate Unique Key for API Response
    static func generateUniqueKey(apiObject : APIBase) -> String {
        let questionSymbol = "?"
        var paramString: String! = ""
        
        // Generate Unique Key for api
        if let parameters = apiObject.requestParameter() {            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                paramString = String.init(data: jsonData, encoding: .utf8)
            } catch let error as NSError {
                print(error)
            }
        }
        
        let predicateKey = apiObject.urlForRequest() + questionSymbol + paramString
        return predicateKey
    }
    
    // MARK: Is Content Valid
    static func isExpired(ttl: NSDate?) -> Bool {
        var isExpired = false
        if let ttl = ttl {
            if let currentTime = currentTimeInGMT(), currentTime.timeIntervalSinceReferenceDate >= ttl.timeIntervalSinceReferenceDate {
                isExpired = true
            }
        }
        return isExpired
    }
    
    // Current Time In GMT
    static func currentTimeInGMT() -> NSDate? {
        let date = NSDate()
        
        let formatter = DateFormatter()
        formatter.dateFormat = expiryDateFormat
        let dateString = formatter.string(from: date as Date)
        formatter.timeZone = NSTimeZone(abbreviation: timeZone) as TimeZone?
        
        return formatter.date(from: dateString) as NSDate?? ?? nil
    }
    
    // Get Expiry Date
    static func addSecondsToDate(date: Date, seconds: NSNumber) -> Date? {
        let calendar = NSCalendar.current
        let newDate = calendar.date(byAdding: .second, value: Int(truncating: seconds), to: date)
        return newDate
    }
    
    // MARK: Save Response
    static func saveResponse(uniqueKey: String?, apiObject: APIBase, cacheData: NSData, ttl: String) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = expiryDateFormat
        let expriyDate = formatter.date(from: ttl)
        
        guard isExpired(ttl: expriyDate as NSDate?) == false else {
            return
        }
        
        // Generate API Key
        let key = generateUniqueKey(apiObject: apiObject)
        let context = SMNetworkCoreDataManager.sharedInstance.createPrivateContext()
        let predicate = NSPredicate(format: "%K == %@", Database.APICacheFields.Key , uniqueKey ?? key)
        
        let cachedResponseList = getCachedResponse(predicate: predicate, context: context)
        
        if let cachedResponseList = cachedResponseList {
            // Update existing data
            let apiCache = cachedResponseList[0]
            apiCache.key = uniqueKey ?? key
            apiCache.value = cacheData
            apiCache.createdAt = currentTimeInGMT()
            apiCache.ttl = expriyDate as NSDate?
        } else {
            // If there is no existing data then insert new content
            let apiCache: APICache = NSEntityDescription.insertNewObject(forEntityName: Database.Entities.APICache, into: context) as! APICache
            apiCache.key = uniqueKey ?? key
            apiCache.value = cacheData
            apiCache.createdAt = currentTimeInGMT()
            apiCache.ttl = expriyDate as NSDate?
        }
        
        SMNetworkCoreDataManager.sharedInstance.saveContext(context: context)
    }
    
    static func clearAllCachedContent() {
        // fetch all items in entity and request to delete them
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Database.Entities.APICache)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // delegate objects
        let context = SMNetworkCoreDataManager.sharedInstance.createPrivateContext()
        let persistentStoreCoordinator = SMNetworkCoreDataManager.sharedInstance.persistentStoreCoordinator
        
        // perform the delete
        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch let error as NSError {
            print(error)
        }
    }
}
