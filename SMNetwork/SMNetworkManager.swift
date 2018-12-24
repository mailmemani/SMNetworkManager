//
//  SMNetworkManager.swift
//  SMNetwork
//
//  Created by Subramanian on 5/11/16.
//  Copyright © 2016 Subramanian. All rights reserved.
//

import Foundation


class SMNetworkManager{
    
    // Shared instance
    static let sharedInstance = SMNetworkManager()
    
    // Avoid initialization
    private init() {
    }
    
    // MARK: Methods
    // MARK: API Request
    func makeAPIRequest(apiObject: APIBase,
                        completionHandler:@escaping ResponseHandler) {
        
        var shouldUpdateNetworkStatus = true
        
        if !ConnectionManager.sharedInstance.isReachable && apiObject.shouldSyncOnceNetworkReachable() {
            
            // No need to inform caller about the network not reachable if the api support offline sync
            shouldUpdateNetworkStatus = false
            
            // Store api details if the flag is enabled on the api object
            OfflineAPIManager.sharedInstance.syncWhenNetworkReachable(apiObject: apiObject, completionHandler: { (status) in
                // Send if we need to pass any data back.
                completionHandler(nil, nil, ConnectionManager.sharedInstance.isReachable)
            })
        }
        
        // Check Cache Control
        if apiObject.enableCacheControl() {
            // Get from Database
            let (requestBinary, isExpired) = APICache.fetchCachedResponse(uniqueKey: apiObject.cacheKey(), apiObject: apiObject)
            if let requestBinary = requestBinary  {
                if let requestObject = NSKeyedUnarchiver.unarchiveObject(with: requestBinary as Data) as? Dictionary<String, AnyObject> {
                    apiObject.parseAPIResponse(response: requestObject)
                    print("*** Content Loaded From Cache ***")
                    
                    // No need to inform caller about the network not reachable if the api response is already cached.
                    shouldUpdateNetworkStatus = false
                    
                    completionHandler(requestObject as AnyObject?, nil, ConnectionManager.sharedInstance.isReachable)
                    guard isExpired == true else {
                        print("*** Content  not expired ***")
                        return
                    }
                }
            }
        }
        
        if ConnectionManager.sharedInstance.isReachable {
            print("*** Server Request Initiated ***")
            // Make Server Request
            APIManager.sharedInstance.initiateRequest(apiObject, apiRequestCompletionHandler: completionHandler)
        } else if (shouldUpdateNetworkStatus) {
            // If there is no previous cached data or the api supports offline sync then we need to inform the caller about the network not reachable.
            completionHandler(nil, nil, ConnectionManager.sharedInstance.isReachable)
        }
    }
    
    // MARK: Clear Cache
    func clearCache() {
        APICache.clearAllCachedContent()
    }
}
