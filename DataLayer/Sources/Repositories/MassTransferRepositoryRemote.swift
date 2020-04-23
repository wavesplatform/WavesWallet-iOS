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
    
    private let wavesSDKServices: WavesSDKServices
    
    init(wavesSDKServices: WavesSDKServices) {
        self.wavesSDKServices = wavesSDKServices
    }
    
    func obtainPayoutsHistory(serverEnvironment: ServerEnvironment,
                              query: DataService.Query.MassTransferDataQuery) -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> {
                        
            return wavesSDKServices
                .wavesServices(environment: serverEnvironment)
                .dataServices.transactionsDataService.getMassTransferTransactions(query: query)
    }
}
