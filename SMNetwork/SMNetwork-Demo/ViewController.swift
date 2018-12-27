//
//  ViewController.swift
//  SMNetwork
//
//  Created by subramanian on 27/12/18.
//  Copyright © 2018 Subramanian. All rights reserved.
//

import UIKit
import SMNetwork
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let countryAPI = CountryAPI()
        
        //Show busy view here.
        SMNetworkManager.sharedInstance.makeAPIRequest(apiObject: countryAPI) { [weak self] (reponse, error, isNetworkReachable) in
            
            guard let _ = self else {
                return
            }
            DispatchQueue.main.async {
                //Hide busy view
                if let error = error {
                    if error.code == APIConfig.timeOutErrorCode {
                        // Show timeour error message here.
                    }
                    else { // Handle any other error message here. }
                        return
                    }
                    
                    if let _ = countryAPI.errorMessage {
                        // Show server error message here.
                        return
                    }
                    
                    // Handle UI / Other logics here.
                }
            }
        }
        
    }
}



// ***************************************************************************************

// Country API CLASS
// ***************************************************************************************

class CountryAPI: APIBase {
    
    var errorMessage: String?
    
    override init() {
        super.init()
    }
    
    // MARK: URL
    override func urlForRequest() -> String {
        let urlString = APIConfig.BaseURL + APIConfig.APICountry
        return urlString
    }
    
    // MARK: HTTP method type
    override func requestType() -> Alamofire.HTTPMethod {
        return Alamofire.HTTPMethod.get   // Default is get only
    }
    
    override func isJSONRequest() -> Bool {
        return true
    }
    
    // MARK: Response parser
    override func parseAPIResponse(response: Dictionary<String, AnyObject>?) {
        
        print("\(String(describing: response))")
        
        guard response != nil else {
            return
        }
        
        // Parse api response and store the model here. Which can be accessed from where the api request made.
    }
}

