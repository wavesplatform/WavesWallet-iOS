//
//  PaymentHistorySystem.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import RxFeedback
import RxSwift
import WavesSDK

final class PayoutsHistorySystem: System<PayoutsHistoryState, PayoutsHistoryEvents> {
    private let enviroment: DevelopmentConfigsRepositoryProtocol
    private let massTransferRepository: MassTransferRepositoryProtocol
    
    init(massTransferRepository: MassTransferRepositoryProtocol, enviroment: DevelopmentConfigsRepositoryProtocol) {
        self.enviroment = enviroment
        self.massTransferRepository = massTransferRepository
    }
    
    override func internalFeedbacks() -> [(Driver<PayoutsHistoryState>) -> Signal<PayoutsHistoryEvents>] {
        [performLoading]
    }
    
    override func initialState() -> PayoutsHistoryState! {
        PayoutsHistoryState(ui: .showLoadingIndicator, core: .isLoading)
    }
    
    override func reduce(event: PayoutsHistoryEvents, state: inout PayoutsHistoryState) {
        switch event {
        case .performLoading:
            break
        case .pullToRefresh:
            break
        case .loadingError:
            break
        case .dataLoaded(let massTransfers):
            state.core = .dataLoaded(massTransfers)
            
            break
        }
    }
    
    var performLoading: Feedback {
        react(request: { state -> Bool? in
            switch state.core {
            case .isLoading: return true
            default: return false
            }
        }, effects: { [weak self] _ -> Signal<Event> in
            guard let self = self else { return Signal.never() }
            
            return self.enviroment
                .developmentConfigs()
                .map { _ -> DataService.Query.MassTransferDataQuery in
                    .init(sender: "", // config.neutrinoAssetId,
                          timeStart: nil,
                          timeEnd: nil,
                          recipient: "", // config.addressByPayoutsAnnualPercent,
                          assetId: "", // config.addressByCalculateProfit,
                          after: nil)
                }
                .flatMap { [weak self] query
                    -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> in
                    guard let self = self else { return Observable.never() }
                    
                    return self.massTransferRepository.obtainPayoutsHistory(query: query)
                }
                .map { payoutsHistoryResponse -> PayoutsHistoryEvents in .dataLoaded(payoutsHistoryResponse) }
                .asSignal(onErrorJustReturn: .loadingError)
        })
    }
}
