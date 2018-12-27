//
//  OfflineAPIManager.swift
//
//
//  Created by Subramanian on 07/11/17.
//  Copyright © 2018 Subramanian. All rights reserved.
//

import Foundation

public typealias CompletionHandlerPendingRequest = (Bool) -> Void

open class OfflineAPIManager {
    
    // Shared instance
    public static let sharedInstance = OfflineAPIManager()
    
    // Avoid initialization
    private init() {
        
    }
    
    
    fileprivate func registerForNetworkChange() {
        ConnectionManager.sharedInstance.registerForNextworkMonitor { (isReachable) in
            // Sync or Store api details based on the network status
            if isReachable == true {
                OfflineAPIManager.sharedInstance.syncAllPendingAPIRequest()
            }
        }
    }
    
    // MARK: Insert new api object which need to be synced once network comes.
    public func syncWhenNetworkReachable(apiObject: APIBase, completionHandler: @escaping CompletionHandlerPendingRequest) {
        
        var postBodyString: String?
        
        if let postBodyDictionary = apiObject.requestParameter() {
            do {
                let data = try JSONSerialization.data(withJSONObject: postBodyDictionary, options: .prettyPrinted)
                postBodyString = String.init(data: data, encoding: .utf8)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        PendingAPI.insertNewRecord(url: apiObject.urlForRequest(), requestType: apiObject.requestType().rawValue, postBody: postBodyString)
        completionHandler(true)
    }
    
    // Synch all the pending api request if network is available
    public func syncAllPendingAPIRequest() {
        
        guard ConnectionManager.sharedInstance.isReachable ==  true else {
            return
        }
        
        let context = SMNetworkCoreDataManager.sharedInstance.createPrivateContext()
        
        let sort = NSSortDescriptor.init(key: Database.PendingAPIFields.TimeStamp, ascending: true)
        if let pendingAPIList = PendingAPI.getPendingAPIs(predicate: nil, sort: [sort], context: context) {
            
            for pendingRequest in pendingAPIList {
                if let url = pendingRequest.url, let requestType = pendingRequest.requestType {
                    var postBody : Dictionary<String, AnyObject>?
                    
                    // Post body string to dictionary
                    if let postBodyString = pendingRequest.postBody, let data = postBodyString.data(using: .utf8) {
                        do {
                            postBody = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject>
                        } catch {
                            print(error)
                        }
                    }
                    
                    let apiObject = SyncOfflineRequestToServer(url: url, apiRequestType: requestType, postBody: postBody, requestId: pendingRequest.timeStamp)
                    
                    SMNetworkManager.sharedInstance.makeAPIRequest(apiObject: apiObject, completionHandler: { (response, error, isNetworkReachable) in
                        
                        if let _ = error {
                            //HTTP error
                            return
                        }
                        
                        if apiObject.isSuccess == true {
                            let predicate = NSPredicate(format: "%K == %lf", Database.PendingAPIFields.TimeStamp , apiObject.requestId)
                            let context = SMNetworkCoreDataManager.sharedInstance.createPrivateContext()
                            PendingAPI.deleteRecord(predicate: predicate, context: context)
                        }
                    })
                }
            }
        }
    }
}
