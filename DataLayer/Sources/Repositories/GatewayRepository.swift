//
//  GatewayRepository.swift
//  InternalDataLayer
//
//  Created by Pavel Gubin on 22.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

final class GatewayRepository: GatewayRepositoryProtocol {
    
    private let environmentRepository: EnvironmentRepositoryProtocols

    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }
    
    func withdrawProcess(by address: String, assetId: String) -> Observable<Bool> {
        return Observable.empty()
    }
}
