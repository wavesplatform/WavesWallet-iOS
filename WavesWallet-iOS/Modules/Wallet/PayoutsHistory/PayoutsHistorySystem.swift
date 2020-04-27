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
    private let authUseCase: AuthorizationUseCaseProtocol
    private let assetUseCase: AssetsUseCaseProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentUseCase
    
    private let disposeBag = DisposeBag()
    
    init(massTransferRepository: MassTransferRepositoryProtocol,
         enviroment: DevelopmentConfigsRepositoryProtocol,
         authUseCase: AuthorizationUseCaseProtocol,
         assetUseCase: AssetsUseCaseProtocol,
         serverEnvironmentUseCase: ServerEnvironmentUseCase) {
        self.enviroment = enviroment
        self.massTransferRepository = massTransferRepository
        self.authUseCase = authUseCase
        self.assetUseCase = assetUseCase
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }
    
    override func internalFeedbacks() -> [(Driver<PayoutsHistoryState>) -> Signal<PayoutsHistoryEvents>] {
        [performLoading, loadMore]
    }
    
    override func initialState() -> PayoutsHistoryState! {
        let coreState = PayoutsHistoryState.Core(state: .isLoading, massTransferTrait: nil)
        let uiState = PayoutsHistoryState.UI(state: .isLoading, viewModels: [], canLoadMore: false)
        
        return PayoutsHistoryState(ui: uiState, core: coreState)
    }
    
    override func reduce(event: PayoutsHistoryEvents, state: inout PayoutsHistoryState) {
        switch event {
        case .performInitialLoading:
            if case .loadingError = state.core.state, case .loadingError = state.ui.state {
                let newCoreState = PayoutsHistoryState.Core(state: .isLoading, massTransferTrait: nil)
                let newUIState = PayoutsHistoryState.UI(state: .isLoading, viewModels: [], canLoadMore: false)
                
                state.core = newCoreState
                state.ui = newUIState
            }
            
        case .loadMore:
            if case .dataLoaded = state.core.state,
                case .dataLoaded = state.ui.state,
                state.core.massTransferTrait?.massTransferTransactions.lastCursor != nil {
                let newCoreState = PayoutsHistoryState.Core(state: .loadingMore, massTransferTrait: state.core.massTransferTrait)
                state.core = newCoreState
                
                let newUIState = PayoutsHistoryState.UI(state: .loadingMore, viewModels: state.ui.viewModels, canLoadMore: false)
                state.ui = newUIState
            }
            
        case .pullToRefresh:
            if case .dataLoaded = state.core.state, case .dataLoaded = state.ui.state {
                let newCoreState = PayoutsHistoryState.Core(state: .isLoading, massTransferTrait: nil)
                state.core = newCoreState
                
                let newUIState = PayoutsHistoryState.UI(state: .isLoading, viewModels: [], canLoadMore: false)
                state.ui = newUIState // наверное нужно завести другое состояние
            }
            
        case .loadingError(let error):
            if case .isLoading = state.core.state, case .isLoading = state.ui.state {
                let newCoreState = PayoutsHistoryState.Core(state: .loadingError(error), massTransferTrait: nil)
                let newUIState = PayoutsHistoryState.UI(state: .loadingError(error.localizedDescription),
                                                        viewModels: [],
                                                        canLoadMore: false)
                
                state.core = newCoreState
                state.ui = newUIState
            } else if case .loadingMore = state.core.state, case .loadingMore = state.core.state {
                let newCoreState = PayoutsHistoryState.Core(state: .dataLoaded, massTransferTrait: state.core.massTransferTrait)
                
                let canLoadMore = state.core.massTransferTrait?.massTransferTransactions.lastCursor != nil
                let newUIState = PayoutsHistoryState.UI(state: .dataLoaded,
                                                        viewModels: state.ui.viewModels,
                                                        canLoadMore: canLoadMore)
                
                state.core = newCoreState
                state.ui = newUIState
            }
            
        case .dataLoaded(let massTransfersTrait):
            if case .isLoading = state.core.state, case .isLoading = state.ui.state {
                let newCoreState = PayoutsHistoryState.Core(state: .dataLoaded, massTransferTrait: massTransfersTrait)
                state.core = newCoreState
                
                let viewModels = prepareTransactionViewModels(massTransfersTrait: massTransfersTrait)
                
                let canLoadMore = massTransfersTrait.massTransferTransactions.lastCursor != nil
                let newUIState = PayoutsHistoryState.UI(state: .dataLoaded, viewModels: viewModels, canLoadMore: canLoadMore)
                state.ui = newUIState
            }
            
        case .loadedMore(let massTransferTrait):
            
            if case .loadingMore = state.core.state, case .loadingMore = state.ui.state {
                let newMassTransferTrait = state.core.massTransferTrait?.copy(massTransferTrait: massTransferTrait)
                let newCoreState = PayoutsHistoryState.Core(state: .dataLoaded, massTransferTrait: newMassTransferTrait)
                state.core = newCoreState
                
                let loadedMoreVMs = prepareTransactionViewModels(massTransfersTrait: massTransferTrait)
                let canLoadMore = massTransferTrait.massTransferTransactions.lastCursor != nil
                
                let newUIState = PayoutsHistoryState.UI(state: .dataLoaded,
                                                        viewModels: state.ui.viewModels + loadedMoreVMs,
                                                        canLoadMore: canLoadMore)
                state.ui = newUIState
            }
        }
    }
    
    private func prepareTransactionViewModels(massTransfersTrait: PayoutsHistoryState.MassTransferTrait) -> [PayoutTransactionVM] {
        massTransfersTrait
            .massTransferTransactions
            .transactions
            .map { transaction -> PayoutTransactionVM in
                let iconAsset = massTransfersTrait.assetLogo
                let amount = transaction.transfers
                    .filter { $0.recipient == massTransfersTrait.walletAddress }
                    .reduce(0) { $0 + $1.amount }
                
                let money = Money(value: Decimal(amount), massTransfersTrait.precision ?? 0)
                let currency = DomainLayer.DTO.Balance.Currency(title: "", ticker: massTransfersTrait.assetTicker)
                
                let balance = DomainLayer.DTO.Balance(currency: currency, money: money)
                let transactionValue = BalanceLabel.Model(balance: balance, sign: .plus, style: .medium)
                
                let dateFormatter = DateFormatter.uiSharedFormatter(key: "PayoutsHistorySystem",
                                                                    style: .pretty(transaction.timestamp))
                
                let dateText = dateFormatter.string(from: transaction.timestamp)
                
                return PayoutTransactionVM(title: Localizable.Waves.Payoutshistory.profit,
                                           iconAsset: iconAsset,
                                           transactionValue: transactionValue,
                                           dateText: dateText)
            }
    }
}

extension PayoutsHistorySystem {
    private typealias MassTransferTuple = (DataService.Response<[DataService.DTO.MassTransferTransaction]>,
                                           [DomainLayer.DTO.Asset],
                                           DataService.Query.MassTransferDataQuery)
    
    var performLoading: Feedback {
        react(request: { moduleState -> Bool? in
            switch moduleState.core.state {
            case .isLoading: return true
            default: return nil
            }
        }, effects: { [weak self] _ -> Signal<Event> in
            guard let self = self else { return Signal.never() }
            return self.obtainMassTransfer(lastCursor: nil)
                .map { PayoutsHistoryEvents.dataLoaded($0) }
                .asSignal(onErrorRecover: { error -> Signal<PayoutsHistoryEvents> in Signal.just(.loadingError(error)) })
        })
    }
    
    var loadMore: Feedback {
        react(request: { moduleState -> String? in
            switch moduleState.core.state {
            case .loadingMore: return moduleState.core.massTransferTrait?.massTransferTransactions.lastCursor
            default: return nil
            }
        }, effects: { cursor -> Signal<Event> in
            self.obtainMassTransfer(lastCursor: cursor)
                .map { PayoutsHistoryEvents.loadedMore($0) }
                .asSignal(onErrorRecover: { error -> Signal<PayoutsHistoryEvents> in Signal.just(.loadingError(error)) })
        })
    }
    
    private func obtainMassTransfer(lastCursor: String?) -> Observable<PayoutsHistoryState.MassTransferTrait> {
        let authorizedWallet = authUseCase.authorizedWallet()
        
        return enviroment
            .developmentConfigs()
            .withLatestFrom(authorizedWallet, resultSelector: { ($0, $1) })
            .map { config, signedWallet -> DataService.Query.MassTransferDataQuery in
                if let staking = config.staking.first {
                    let query = DataService.Query.MassTransferDataQuery(sender: staking.addressByPayoutsAnnualPercent,
                                                                        timeStart: nil,
                                                                        timeEnd: nil,
                                                                        recipient: signedWallet.wallet.address,
                                                                        assetId: staking.neutrinoAssetId,
                                                                        after: lastCursor,
                                                                        limit: 15)
                    
                    return query
                } else {
                    let query = DataService.Query.MassTransferDataQuery(sender: "",
                                                                        timeStart: nil,
                                                                        timeEnd: nil,
                                                                        recipient: "",
                                                                        assetId: "",
                                                                        after: lastCursor,
                                                                        limit: 15)
                    return query
                }
            }
            .flatMap { [weak self] query -> Observable<MassTransferTuple> in
                guard let self = self else { return Observable.never() }
                
                let queryCache = Observable.just(query)
                let massTransferTransactions = self
                    .serverEnvironmentUseCase
                    .serverEnvironment()
                    .flatMap { [weak self] serverEnvironment -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> in
                        guard let self = self else { return Observable.never() }
                        
                        return self
                            .massTransferRepository
                            .obtainPayoutsHistory(serverEnvironment: serverEnvironment,
                                                  query: query)
                    }
                    
                
                let id = query.assetId ?? ""
                let accountAddress = query.recipient
                let asset = self.assetUseCase.assets(by: [id], accountAddress: accountAddress)
                
                return Observable.zip(massTransferTransactions, asset, queryCache)
            }
            .map { transactions, assets, query -> PayoutsHistoryState.MassTransferTrait in
                let isLastPage = transactions.isLastPage ?? true // дефолтное значение true чтоб не зацикливать загрузку если что
                let lastCursor = transactions.lastCursor
                let transactions = transactions.data
                let massTransferTransactions = PayoutsHistoryState.Core.MassTransferTransactions(isLastPage: isLastPage,
                                                                                                 lastCursor: lastCursor,
                                                                                                 transactions: transactions)
                
                return PayoutsHistoryState.MassTransferTrait(massTransferTransactions: massTransferTransactions,
                                                             walletAddress: query.recipient,
                                                             assetLogo: assets.first?.iconLogo,
                                                             precision: assets.first?.precision,
                                                             assetTicker: assets.first?.ticker)
            }
    }
}
