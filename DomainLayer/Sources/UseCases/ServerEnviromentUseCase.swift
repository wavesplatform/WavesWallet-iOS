//
//  ServerEnviromentUseCase.swift
//  DomainLayer
//
//  Created by rprokofev on 22.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public struct ServerEnvironment: Hashable {
    
    public let kind: WalletEnvironment.Kind
    public let servers: WalletEnvironment.Servers
    // Нужна для синхранизации времени между клиентом и сервером
    public private(set) var timestampServerDiff: Int64
    
    public var aliasScheme: String
    
    public init(kind: WalletEnvironment.Kind,
                servers: WalletEnvironment.Servers,
                timestampServerDiff: Int64,
                aliasScheme: String) {
        self.kind = kind
        self.servers = servers
        self.timestampServerDiff = timestampServerDiff
        self.aliasScheme = aliasScheme
    }
}

public protocol ServerEnvironmentUseCase {
    func serverEnviroment() -> Observable<ServerEnvironment>
}

public final class ServerEnvironmentUseCaseImp: ServerEnvironmentUseCase {
    
    private let serverTimestampRepository: ServerTimestampRepository
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(serverTimestampRepository: ServerTimestampRepository,
         environmentRepository: EnvironmentRepositoryProtocol) {
        
        self.serverTimestampRepository = serverTimestampRepository
        self.environmentRepository = environmentRepository  
    }
    
    public func serverEnviroment() -> Observable<ServerEnvironment> {
        
        let walletEnvironment = self.environmentRepository.walletEnvironment()
        
        return walletEnvironment
            .flatMap { walletEnvironment -> Observable<ServerEnvironment> in
                
                let environmentKind = self.environmentRepository.environmentKind
                
                let serverEnvironment = ServerEnvironment(kind: environmentKind,
                                                          servers: walletEnvironment.servers,
                                                          timestampServerDiff: 0,
                                                          aliasScheme: walletEnvironment.aliasScheme)
                
                return self
                    .serverTimestampRepository
                    .timestampServerDiff(serverEnvironment: serverEnvironment)
                    .map { ServerEnvironment(kind: environmentKind,
                                             servers: walletEnvironment.servers,
                                             timestampServerDiff: $0,
                                             aliasScheme: walletEnvironment.aliasScheme)
                    }
        }
    }
}
