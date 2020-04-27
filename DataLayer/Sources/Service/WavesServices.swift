//
//  WavesServices.swift
//  DataLayer
//
//  Created by rprokofev on 22.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK

final class WavesSDKServicesImp: WavesSDKServices {
    private var internalServerEnvironment: ServerEnvironment?

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
            objc_sync_exit(self)
        }

        objc_sync_enter(self)

        if serverEnvironment == environment {
            return WavesSDK.shared.services
        }

        serverEnvironment = environment

        let server: Enviroment.Server = .custom(node: environment.servers.nodeUrl,
                                                matcher: environment.servers.matcherUrl,
                                                data: environment.servers.dataUrl,
                                                scheme: environment.kind.chainId)

        if WavesSDK.isInitialized() {
            var enviromentService = WavesSDK.shared.enviroment
            enviromentService.server = server
            enviromentService.timestampServerDiff = environment.timestampServerDiff
            WavesSDK.shared.enviroment = enviromentService

            serverEnvironment = environment

            return WavesSDK.shared.services
        }

        let servicesPlugins = WavesSDK.ServicesPlugins(data: [SentryNetworkLoggerPlugin(),
                                                              CachePolicyPlugin()],
                                                       node: [NodePlugin(),
                                                              SentryNetworkLoggerPlugin(),
                                                              CachePolicyPlugin()],
                                                       matcher: [SentryNetworkLoggerPlugin(),
                                                                 CachePolicyPlugin()])

        serverEnvironment = environment

        let wavesSDKEnviroment = Enviroment(server: server,
                                            timestampServerDiff: environment.timestampServerDiff)

        WavesSDK.initialization(servicesPlugins: servicesPlugins,
                                enviroment: wavesSDKEnviroment)

        return WavesSDK.shared.services
    }
}
