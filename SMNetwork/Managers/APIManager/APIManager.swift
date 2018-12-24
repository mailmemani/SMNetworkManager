//
//  APIManager.swift
//  APIManager-Alamofire
//
//  Created by Subramanian on 2/8/16.
//  Copyright © 2016 Subramanian. All rights reserved.
//

import Foundation
import Alamofire

typealias ResponseHandler = (AnyObject?, NSError?, Bool?) -> Void

class APIManager {
    
    // Class Stored Properties
    static let sharedInstance = APIManager()
    
    // To avoid multiple api call, we are tracking request by using unique api cache key
    var requestInProgressStack = Set<String>()

    static let sharedSessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = TimeInterval(APIConfig.timeoutInterval)
        return SessionManager(configuration: configuration)
    }()
    
    // Avoid initialization
    fileprivate init() {
      
    }
    
    static let rootKey = "Root";
    static let expireKey = "Expires"
    static let defaultExpirySecond = 2
    
    var sessionManager: Alamofire.SessionManager!
    
    // MARK : Initialize API Request
    func initiateRequest(_ apiObject: APIBase,
                         apiRequestCompletionHandler:@escaping ResponseHandler) {
        
        // Check is the api request can call multiple time
        if apiObject.shouldAllowMultipleRequest() == false {
            
            // If not allowed then check the api is already in progress
            guard isRequestInProgress(apiObject: apiObject) == false else {
                // If the api request is alreay in progress then no need to make duplicate api request
                return
            }
        }
        
        let isLoadedFromLocalFile = loadFromLocalIfExist(apiObject: apiObject, apiRequestCompletionHandler: apiRequestCompletionHandler)
        
        if isLoadedFromLocalFile == true {
            return
        }
        
        var urlString = apiObject.urlForRequest()
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        if apiObject.isMultipartRequest() == true  {
            var urlString = apiObject.urlForRequest()
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            APIManager.sharedSessionManager.upload(multipartFormData: { (multipartFormData) -> Void in
                apiObject.multipartData(multipartData: multipartFormData)
            }, to: urlString,
               encodingCompletion: { (encodingResult) -> Void in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseData(){  [unowned self] response in
                        if let data = response.result.value {
                            self.serializeAPIResponse(apiObject, response: data as Data?, apiRequestCompletionHandler: apiRequestCompletionHandler, serializerCompletionHandler: nil)
                            // Clear api request key from the pending stack
                            self.removeRequestFromPendingStack(apiObject: apiObject)
                        } else {
                            apiRequestCompletionHandler(nil,nil,ConnectionManager.sharedInstance.isReachable)
                            // Clear api request key from the pending stack
                            self.removeRequestFromPendingStack(apiObject: apiObject)
                        }
                    }
                case .failure(_):
                    let error = NSError(domain: apiObject.urlForRequest(), code: 404, userInfo: nil)
                    apiRequestCompletionHandler(nil,error,ConnectionManager.sharedInstance.isReachable)
                    // Clear api request key from the pending stack
                    self.removeRequestFromPendingStack(apiObject: apiObject)
                }
                
            })
        } else {
            
            var urlString = apiObject.urlForRequest()
            
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

            let request = APIManager.sharedSessionManager.request(urlString, method: apiObject.requestType(), parameters: apiObject.requestParameter(), encoding: ((apiObject.isJSONRequest() == true) ? JSONEncoding.default : URLEncoding.default), headers: apiObject.customHTTPHeaders())
            
            self.requestCompleted(request, apiObject: apiObject,apiRequestCompletionHandler: apiRequestCompletionHandler)
        }
    }
    
    
    //MARK: Get response from local file
    func loadFromLocalIfExist(apiObject: APIBase, apiRequestCompletionHandler:@escaping ResponseHandler) -> Bool {
        if let filePath = apiObject.loadResponseFromLocalFile() {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                serializeAPIResponse(apiObject, response: data, apiRequestCompletionHandler: apiRequestCompletionHandler, serializerCompletionHandler: nil)
                return true
            } catch let _ as NSError {
                // Error : Initiate server request
            }
        }
        return false
    }
    
    // MARK : Check the reqeust already initiated and waiting to complete.
    func isRequestInProgress(apiObject : APIBase) -> Bool {
        var inProgress = false
        
        let apiUniqueKey = apiObject.cacheKey() ?? APICache.generateUniqueKey(apiObject: apiObject)
        if requestInProgressStack.contains(apiUniqueKey) {
            inProgress = true
        } else {
            requestInProgressStack.insert(apiUniqueKey)
        }
        
        return inProgress
    }
    
    
    // MARK : Remove the request id from the stack
    func removeRequestFromPendingStack(apiObject : APIBase) {
        let apiUniqueKey = apiObject.cacheKey() ?? APICache.generateUniqueKey(apiObject: apiObject)
        requestInProgressStack.remove(apiUniqueKey)
    }
    
    
    // MARK: Request Completion Logic
    func requestCompleted(_ request: DataRequest?,
                          apiObject: APIBase,
                          apiRequestCompletionHandler:@escaping ResponseHandler) {
        if let request = request {
            
            // Mannual parsing
            request.responseData { [unowned self] response in

                if let data = response.result.value {
                    Logger.log(message:request.response?.allHeaderFields.description ?? "NaN")
                    
                    if let header = request.response?.allHeaderFields {
                        apiObject.responseHeader(header: header);
                    }
                    
                    self.serializeAPIResponse(apiObject, response: data as Data?, apiRequestCompletionHandler: apiRequestCompletionHandler) {
                        [unowned self, request, apiObject] responseDictionary in
                        self.cacheResponse(request, apiObject: apiObject, resposneDictionary: responseDictionary)
                    }
                } else if let error = response.error {
                    print(error.localizedDescription)
                    apiRequestCompletionHandler(nil,error as NSError, ConnectionManager.sharedInstance.isReachable)
                } else {
                    apiRequestCompletionHandler(nil,nil, ConnectionManager.sharedInstance.isReachable)
                }
                // Clear api request key from the pending stack
                self.removeRequestFromPendingStack(apiObject: apiObject)
            }
        } else {
            let error = NSError(domain: apiObject.urlForRequest(), code: 404, userInfo: nil)
            apiRequestCompletionHandler(nil,error, ConnectionManager.sharedInstance.isReachable)
            // Clear api request key from the pending stack
            removeRequestFromPendingStack(apiObject: apiObject)
        }
    }
    
    
    // MARK: Cache API Response
    func cacheResponse(_ requestObject: DataRequest, apiObject: APIBase, resposneDictionary: Dictionary<String, AnyObject>) {
        guard apiObject.enableCacheControl() == true else {
            return
        }
        requestObject.response { responseStruct in
            if let _ = responseStruct.data {
                // Cache Control
                let ttl = responseStruct.response?.allHeaderFields[APIManager.expireKey] as? String
                    ?? self.addCurrentDate()
                    let resposneData = NSKeyedArchiver.archivedData(withRootObject: resposneDictionary)
                    APICache.saveResponse(uniqueKey: apiObject.cacheKey(), apiObject: apiObject, cacheData: resposneData as NSData, ttl: ttl)
            }
        }
    }
    
    func addCurrentDate() -> String {
        //add 24 hours
        let expiryDate =  NSCalendar.current.date(byAdding: Calendar.Component.second, value: APIManager.defaultExpirySecond, to: Date())
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = APICache.expiryDateFormat
        let expiryDateString = dateFormater.string(from: expiryDate!)
        return expiryDateString
    }
    
    // MARK: Response serializer
    func serializeAPIResponse(_ apiObject: APIBase, response: Data?, apiRequestCompletionHandler:ResponseHandler, serializerCompletionHandler: ((Dictionary<String, AnyObject>) -> Void)?) {
        if let data = response {
            Logger.log(message:String.init(data: data, encoding: .utf8) ?? "NaN")
            do {
                // Check if it is Dictionary
                if let jsonDictionary = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject> {
                    apiObject.parseAPIResponse(response: jsonDictionary)
                    apiRequestCompletionHandler(jsonDictionary as AnyObject?, nil, ConnectionManager.sharedInstance.isReachable)
                    if let _ = serializerCompletionHandler {
                        serializerCompletionHandler!(jsonDictionary)
                    }
                } else if let jsonArray = try JSONSerialization.jsonObject(with: data as Data, options:
                    JSONSerialization.ReadingOptions.mutableContainers) as? Array<AnyObject> {
                    // Check if it is Array of Dictionary/String
                    let jsonDictionary = [APIManager.rootKey : jsonArray]
                    apiObject.parseAPIResponse(response: jsonDictionary as Dictionary<String, AnyObject>?)
                    apiRequestCompletionHandler(jsonDictionary as AnyObject?, nil, ConnectionManager.sharedInstance.isReachable)
                    if let _ = serializerCompletionHandler {
                        serializerCompletionHandler!(jsonDictionary as Dictionary<String, AnyObject>)
                    }
                } else {
                    apiRequestCompletionHandler(nil, nil, ConnectionManager.sharedInstance.isReachable)
                }
                
            } catch let error as NSError {
                if error.code == 3840 {
                    //Empty page
                    apiRequestCompletionHandler(nil, nil, ConnectionManager.sharedInstance.isReachable)
                } else {
                    apiRequestCompletionHandler(nil, error, ConnectionManager.sharedInstance.isReachable)
                }
            }
        }
    }
}
