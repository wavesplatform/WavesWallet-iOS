//
//  ServerEnvironmentRepositoryImp.swift
//  DataLayer
//
//  Created by rprokofev on 12.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

public final class ServerEnvironmentRepositoryImp: ServerEnvironmentRepository {
    
    private let serverTimestampRepository: ServerTimestampRepository
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(serverTimestampRepository: ServerTimestampRepository,
         environmentRepository: EnvironmentRepositoryProtocol) {
        
        self.serverTimestampRepository = serverTimestampRepository
        self.environmentRepository = environmentRepository
    }
    
    public func serverEnvironment() -> Observable<ServerEnvironment> {
        
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
