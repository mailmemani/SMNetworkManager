//
//  APIConfig+Extension.swift
//  SMNetwork-Demo
//
//  Created by subramanian on 27/12/18.
//  Copyright © 2018 Subramanian. All rights reserved.
//

import Foundation
import SMNetwork


extension APIConfig {

    static func configServerDetails() {
        APIConfig.isProduction = true

        APIConfig.ProductionURL = "https://api.printful.com/"
        APIConfig.StagingURL = "https://api.printful.com/"

        APIConfig.ImageProductionURL = ""
        APIConfig.ImageStagingURL = ""
    }

    // APIs
    static let APICountry = "countries"
}
