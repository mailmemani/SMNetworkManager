//
//  APIKeys.swift
//  APIManager-Alamofire
//
//  Created by Subramanian on 26/7/18.
//  Copyright © 2018 Subramanian. All rights reserved.
//


import Foundation

let API_Environment_Key = "isProductionEnvironment"

struct APIConfig {
    
    
    // Config
    static let isProduction: Bool = Bundle.main.infoDictionary?[API_Environment_Key] as? Bool ?? true
    
    static let ProductionURL: String = ""
    static let StagingURL: String = ""
    
    static let ImageProductionURL: String = ""
    static let ImageStagingURL: String = ""
    
    static var BaseURL: String {
        if isProduction  {
            return ProductionURL
        } else {
            return StagingURL
        }
    }
    
    static var ImageBaseURL: String {
        if isProduction  {
            return ImageProductionURL
        } else {
            return ImageStagingURL
        }
    }
    
    static let  timeoutInterval = 20.0 // In Seconds
    static let timeOutErrorCode = -1001
    
}


