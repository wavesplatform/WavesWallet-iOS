//
//  MassTransferRepositoryRemote.swift
//  DataLayer
//
//  Created by vvisotskiy on 10.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Foundation
import RxSwift
import WavesSDK

final class MassTransferRepositoryRemote: MassTransferRepositoryProtocol {
    private let environmentRepository: ExtensionsEnvironmentRepositoryProtocols
    
    init(environmentRepository: ExtensionsEnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }
    
    func obtainPayoutsHistory(query: DataService.Query.MassTransferDataQuery)
        -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> {
            environmentRepository
                .servicesEnvironment()
                .flatMap { app -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> in
                    app.wavesServices.dataServices.transactionsDataService.getMassTransferTransactions(query: query)
                }
    }
}
