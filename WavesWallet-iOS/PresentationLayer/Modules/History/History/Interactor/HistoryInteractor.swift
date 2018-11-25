//
//  HistoryInteractor.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

fileprivate enum Constants {
    static let limitTransactions = 10000
}

protocol HistoryInteractorProtocol {
    func transactions(input: HistoryModuleInput) -> Observable<Sync<[DomainLayer.DTO.SmartTransaction]>>
}

final class HistoryInteractor: HistoryInteractorProtocol {

    private let transactionsInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

    func transactions(input: HistoryModuleInput) -> Observable<Sync<[DomainLayer.DTO.SmartTransaction]>> {

        var specifications: TransactionsSpecifications! = nil

        switch input.type {
        case .all:
            specifications = TransactionsSpecifications.init(page: .init(offset: 0, limit: Constants.limitTransactions),
                                               assets: [],
                                               senders: [],
                                               types: TransactionType.all)
        case .asset(let id):
            specifications = TransactionsSpecifications.init(page: .init(offset: 0, limit: Constants.limitTransactions),
                                               assets: [id],
                                               senders: [],
                                               types: TransactionType.all)
        case .leasing:
            specifications = TransactionsSpecifications.init(page: .init(offset: 0, limit: Constants.limitTransactions),
                                               assets: [],
                                               senders: [],
                                               types: [.lease, .leaseCancel])
        }

        return loadingTransactions(specifications: specifications)
    }

    private func loadingTransactions(specifications: TransactionsSpecifications) -> Observable<Sync<[DomainLayer.DTO.SmartTransaction]>> {

        //TODO: Rmove
        guard let accountAddress = WalletManager.currentWallet?.address else { return Observable.never() }

        return transactionsInteractor
            .transactionsSync(by: accountAddress, specifications: specifications)
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .share()
    }
}
