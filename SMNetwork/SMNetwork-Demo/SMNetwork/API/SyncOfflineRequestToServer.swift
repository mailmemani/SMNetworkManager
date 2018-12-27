//
//  UpdateToBackendAPI.swift
//  
//
//  Created by Subramanian on 07/11/17.
//  Copyright © 2018 Subramanian. All rights reserved.
//

import UIKit
import Alamofire

// Sync
internal class SyncOfflineRequestToServer: APIBase {
   
    var url: String
    var apiRequestType: String
    var postBody: Dictionary<String, Any>?
    var isSuccess: Bool = false
    var requestId: Double
    
    init(url: String, apiRequestType:String, postBody :Dictionary<String, Any>?, requestId: Double) {
        self.url = url
        self.apiRequestType = apiRequestType
        self.postBody = postBody
        self.requestId = requestId
    }
    
    // MARK: URL
    override func urlForRequest() -> String {
        return url
    }
    
    
    // MARK: HTTP method type
    override func requestType() -> Alamofire.HTTPMethod {
        return  Alamofire.HTTPMethod.init(rawValue: apiRequestType) ?? Alamofire.HTTPMethod.get
    }
    
    override func isJSONRequest() -> Bool {
        return true
    }
    
    // MARK: API parameters
    override func requestParameter() -> Dictionary<String, Any>? {
        return postBody
    }
    
    // MARK: Response parser
    override func parseAPIResponse(response: Dictionary<String, AnyObject>?) {
        
        guard let _  = response else {
            return
        }
        
        isSuccess = true
    }
    
   override func shouldAllowMultipleRequest() -> Bool {
        return false
    }
}
