//
//  WavesServices.swift
//  DataLayer
//
//  Created by rprokofev on 22.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import DomainLayer

// Зачем нужен mutex?
// Так как обращение к WavesServices могут происходить с разных потоках и wavesdk может проинициализировано несколько раз =/


protocol WavesSDKServices {
    func wavesServices(environment: ServerEnvironment) -> WavesServicesProtocol
}

final class WavesSDKServicesImp: WavesSDKServices {
    
    private var internalServerEnvironment: ServerEnvironment? = nil
    
    private var serverEnvironment: ServerEnvironment? {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return internalServerEnvironment
        }
        
        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            internalServerEnvironment = newValue
        }
    }
    
    func wavesServices(environment: ServerEnvironment) -> WavesServicesProtocol {
        
        defer {
            self.serverEnvironment = environment
            objc_sync_exit(self)
        }
        
        objc_sync_enter(self)
        
        let server: Enviroment.Server = .custom(node: environment.servers.nodeUrl,
                                                matcher: environment.servers.matcherUrl,
                                                data: environment.servers.dataUrl,
                                                scheme: environment.kind.chainId)
        
        if WavesSDK.isInitialized() && self.serverEnvironment != environment {
            var enviromentService = WavesSDK.shared.enviroment
            enviromentService.server = server
            enviromentService.timestampServerDiff = environment.timestampServerDiff
            WavesSDK.shared.enviroment = enviromentService
            
            return WavesSDK.shared.services
        }
        
        let  servicesPlugins = WavesSDK.ServicesPlugins(data: [SentryNetworkLoggerPlugin(),
                                                               CachePolicyPlugin()],
                                                        node: [NodePlugin(),
                                                               SentryNetworkLoggerPlugin(),
                                                               CachePolicyPlugin()],
                                                        matcher: [SentryNetworkLoggerPlugin(),
                                                                  CachePolicyPlugin()])
        
        let wavesSDKEnviroment = Enviroment(server: server,
                                            timestampServerDiff: environment.timestampServerDiff)
        
        WavesSDK.initialization(servicesPlugins: servicesPlugins,
                                enviroment: wavesSDKEnviroment)
        
        return WavesSDK.shared.services
    }
}
