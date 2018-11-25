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
    func transactions(input: HistoryModuleInput) -> Observable<[DomainLayer.DTO.SmartTransaction]>
}

final class HistoryInteractor: HistoryInteractorProtocol {
    
    private let refreshTransactionsSubject: PublishSubject<[DomainLayer.DTO.SmartTransaction]> = PublishSubject<[DomainLayer.DTO.SmartTransaction]>()
    private let transactionsInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

    private var specifications: TransactionsSpecifications?

    private let disposeBag: DisposeBag = DisposeBag()
    private let replay: PublishSubject<Bool> = PublishSubject<Bool>()

    func transactions(input: HistoryModuleInput) -> Observable<[DomainLayer.DTO.SmartTransaction]> {

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

        self.specifications = specifications

        let transactions = loadingTransactions(specifications: specifications)
        return Observable.merge(transactions, refreshTransactionsSubject.asObserver())
    }

    private func loadingTransactions(specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.SmartTransaction]> {

        //TODO: Rmove
        guard let accountAddress = WalletManager.currentWallet?.address else { return Observable.never() }

        return transactionsInteractor
            .transactionsSync(by: accountAddress, specifications: specifications).map({ (sync) -> [DomainLayer.DTO.SmartTransaction] in
                return sync.resultIngoreError ?? []
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }
}
