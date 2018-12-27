//
//  APIKeys.swift
//  APIManager-Alamofire
//
//  Created by Subramanian on 26/7/18.
//  Copyright © 2018 Subramanian. All rights reserved.
//


import Foundation

public let API_Environment_Key = "isProductionEnvironment"

public struct APIConfig {
    
    
    // Config
    public static var isProduction: Bool = Bundle.main.infoDictionary?[API_Environment_Key] as? Bool ?? true
    
    public static var ProductionURL: String = ""
    public static var StagingURL: String = ""
    
    public static var ImageProductionURL: String = ""
    public static var ImageStagingURL: String = ""
    
    public static var BaseURL: String {
        if isProduction  {
            return ProductionURL
        } else {
            return StagingURL
        }
    }
    
    public static var ImageBaseURL: String {
        if isProduction  {
            return ImageProductionURL
        } else {
            return ImageStagingURL
        }
    }
    
    public static var  timeoutInterval = 20.0 // In Seconds
    public static var timeOutErrorCode = -1001
    
}


