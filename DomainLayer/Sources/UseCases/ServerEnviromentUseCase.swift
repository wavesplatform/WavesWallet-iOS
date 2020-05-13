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

public protocol ServerEnvironmentRepository {
    func serverEnvironment() -> Observable<ServerEnvironment>
}
