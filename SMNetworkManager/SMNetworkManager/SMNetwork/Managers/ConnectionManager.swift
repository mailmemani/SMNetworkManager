//
//  ConnectionManager.swift
//  
//
//  Created by Subramanian on 26/7/18.
//  Copyright © 2018 Subramanian. All rights reserved.
//

import Foundation
import Alamofire

typealias NetworkMonitorBlock =  ((Bool) -> Void)
let NetworkReachableObserver = "NetworkReachableObserver"

class ConnectionManager  {
    /// Singleton Property
    static let sharedInstance = ConnectionManager()
    
    // MARK: - Variables
    /// HostServer Url
    fileprivate let hostUrl:String = "www.google.com"
    fileprivate var reachability: NetworkReachabilityManager?
    fileprivate var networkChangeMonitorBlockslist: [NetworkMonitorBlock] = []
    
    /// Network stats
    var isReachable:Bool = false
    var isListenerAdded:Bool = false;
    var isReachableOnEthernetOrWiFi: Bool = false
    
    // MARK: - Functions
    fileprivate init() {
        
    }
    
    // MARK: Track Internet Connection Status
    internal func listenNetworkConnectionStatus() {
        self.isConnectionAvailable()
        if let networkManager = reachability {
            isReachable = networkManager.isReachable
            isReachableOnEthernetOrWiFi = networkManager.isReachableOnEthernetOrWiFi
        }
    }
    
    fileprivate func isConnectionAvailable() {
        guard !isListenerAdded else {
            /// If listener already added then no need to add again.
            return
        }
        
        if let reachabilityManager = NetworkReachabilityManager(host: hostUrl) {
            weak var weakSelf = self
            reachability = reachabilityManager
            reachability?.listener =  { [unowned self](status: NetworkReachabilityManager.NetworkReachabilityStatus) -> Void in
                weakSelf?.isReachableOnEthernetOrWiFi = reachabilityManager.isReachableOnEthernetOrWiFi

                if status == NetworkReachabilityManager.NetworkReachabilityStatus.notReachable || status == NetworkReachabilityManager.NetworkReachabilityStatus.unknown {
                    weakSelf?.isReachable = false
                    NSLog("%@","Network Unreachable")
                } else {
                    weakSelf?.isReachable = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkReachableObserver), object: nil)
                    NSLog("%@","Network Reachable")
                }
                for monitorBlock in self.networkChangeMonitorBlockslist {
                    monitorBlock(self.isReachable)
                }
            }
            
            // Notify when network switch happened.
            reachability?.startListening()
            self.isListenerAdded = true
        }
    }
    
    func registerForNextworkMonitor(_ completionBlock: @escaping NetworkMonitorBlock) {
        networkChangeMonitorBlockslist.append(completionBlock)
    }
    
}
