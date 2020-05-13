//
//  HistoryInteractor.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK

fileprivate enum Constants {
    static let limitTransactions = 10000
}

protocol HistoryInteractorProtocol {
    func transactions(input: HistoryModuleInput) -> Observable<Sync<[SmartTransaction]>>
}

final class HistoryInteractor: HistoryInteractorProtocol {
    private let transactionsInteractor: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions
    private let authorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization

    func transactions(input: HistoryModuleInput) -> Observable<Sync<[SmartTransaction]>> {
        var specifications: TransactionsSpecifications!

        switch input.type {
        case .all:
            specifications = TransactionsSpecifications(page: .init(offset: 0, limit: Constants.limitTransactions),
                                                        assets: [],
                                                        senders: [],
                                                        types: TransactionType.all)
        case let .asset(id):
            specifications = TransactionsSpecifications(page: .init(offset: 0, limit: Constants.limitTransactions),
                                                        assets: [id],
                                                        senders: [],
                                                        types: TransactionType.all)
        case .leasing:
            specifications = TransactionsSpecifications(page: .init(offset: 0, limit: Constants.limitTransactions),
                                                        assets: [],
                                                        senders: [],
                                                        types: [.createLease, .cancelLease])
        }

        return loadingTransactions(specifications: specifications)
    }

    private func loadingTransactions(specifications: TransactionsSpecifications)
        -> SyncObservable<[SmartTransaction]> {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap { [weak self] (wallet) -> SyncObservable<[SmartTransaction]> in
                guard let self = self else { return Observable.never() }

                return self
                    .transactionsInteractor
                    .transactionsSync(by: wallet.address, specifications: specifications)
            }
    }
}
