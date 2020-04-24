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
    
    // Уберем singleton когда вытащим все сервисы из Repository
    public static let shared: WavesSDKServices = WavesSDKServicesImp()
    
    init() {
        print("WavesSDKServicesImp")
    }
    
    func wavesServices(environment: ServerEnvironment) -> WavesServicesProtocol {
        
        if self.serverEnvironment == environment {
            return WavesSDK.shared.services
        }
        
        self.serverEnvironment = environment
        
        defer {
            objc_sync_exit(self)
        }
        
        objc_sync_enter(self)
        
        let server: Enviroment.Server = .custom(node: environment.servers.nodeUrl,
                                                matcher: environment.servers.matcherUrl,
                                                data: environment.servers.dataUrl,
                                                scheme: environment.kind.chainId)
        
        if WavesSDK.isInitialized()  {
            var enviromentService = WavesSDK.shared.enviroment
            enviromentService.server = server
            enviromentService.timestampServerDiff = environment.timestampServerDiff
            WavesSDK.shared.enviroment = enviromentService
            
            print("WavesSDK isInitialized")
            self.serverEnvironment = environment
            
            return WavesSDK.shared.services
        }
        
        let  servicesPlugins = WavesSDK.ServicesPlugins(data: [SentryNetworkLoggerPlugin(),
                                                               CachePolicyPlugin()],
                                                        node: [NodePlugin(),
                                                               SentryNetworkLoggerPlugin(),
                                                               CachePolicyPlugin()],
                                                        matcher: [SentryNetworkLoggerPlugin(),
                                                                  CachePolicyPlugin()])
        
        self.serverEnvironment = environment
        
        
        let wavesSDKEnviroment = Enviroment(server: server,
                                            timestampServerDiff: environment.timestampServerDiff)
        
        WavesSDK.initialization(servicesPlugins: servicesPlugins,
                                enviroment: wavesSDKEnviroment)
        
        print("WavesSDK initialization")
        
        return WavesSDK.shared.services
    }
}
