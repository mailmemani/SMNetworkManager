//
//  APIBase.swift
//  APIManager-Alamofire
//
//  Created by Subramanian on 2/8/16.
//  Copyright © 2016 Subramanian. All rights reserved.
//

import Foundation
import Alamofire

open class APIBase  {

    public init() {
        
    }
    // MARK: URL
    open func urlForRequest() -> String {
        return ""
    }
    
    // MARK: HTTP method type
    open func requestType() -> Alamofire.HTTPMethod {
        return Alamofire.HTTPMethod.get
    }
    
    // MARK: API parameters
    open func requestParameter() -> [String : Any]?{
        return nil
    }
    
    // MARK: Response parser
    open func parseAPIResponse(response: Dictionary<String, AnyObject>?) {
        
    }
    
    // MARK: Is Multipart Request
    open func isMultipartRequest() -> Bool {
        return false
    }
    
    // MARK: MultipartData
    open func multipartData(multipartData : MultipartFormData?) {
        
    }
    
    // MARK: Object Mapper Logic
    open func enableCacheControl() -> Bool {
        return false
    }
    
    // MARK: Object Mapper Logic
    open func cacheKey() -> String? {
        return nil
    }
    
    // Add custom headers
    open func customHTTPHeaders() -> Alamofire.HTTPHeaders? {
        return nil
    }
    
    // Load response from local file
    open func loadResponseFromLocalFile() -> String? {
        return nil
    }
    
    // Enable true if it is JSON request (application/json)
    open func isJSONRequest() -> Bool {
        return false
    }

    // Enable true if you want to store api details if there is no network. And the data will
    // be sync back to server once network reachable
    open func shouldSyncOnceNetworkReachable() -> Bool {
        return false
    }
    
    // MARK: It will help to avoid same request going multiple time.
    open func shouldAllowMultipleRequest() -> Bool {
        return false
    }
    
    //MARK: Response Header
    open func responseHeader(header: [AnyHashable : Any]) {
        
    }
}
