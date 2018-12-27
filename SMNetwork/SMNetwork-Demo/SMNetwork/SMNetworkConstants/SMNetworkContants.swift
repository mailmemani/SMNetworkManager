//
//  SMNetworkContants.swift
//  SMNetwork
//
//  Created by Subramanian on 5/11/16.
//  Copyright © 2016 Subramanian. All rights reserved.
//

import Foundation


/// MARK : Database
internal struct Database {
    struct Entities {
        static let APICache = "APICache"
        static let PendingAPI = "PendingAPI"
    }
    
    struct APICacheFields {
        static let Key = "key"
        static let Value = "value"
        static let CreatedAt = "createdAt"
        static let ExpiresAt = "expiresAt"
    }
    
    struct PendingAPIFields {
        static let URL = "url"
        static let RequestType = "requestType"
        static let PostBody = "postBody"
        static let TimeStamp = "timeStamp"
    }
}
