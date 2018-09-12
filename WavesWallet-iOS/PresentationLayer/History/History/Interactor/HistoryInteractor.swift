//
//  HistoryInteractor.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private enum Constants {
    static let limitTransactions = 10000
}

protocol HistoryInteractorProtocol {
    func transactions(input: HistoryModuleInput) -> AsyncObservable<[DomainLayer.DTO.SmartTransaction]>
    func refreshTransactions()
}

final class HistoryInteractor: HistoryInteractorProtocol {
    
    private let refreshTransactionsSubject: PublishSubject<[DomainLayer.DTO.SmartTransaction]> = PublishSubject<[DomainLayer.DTO.SmartTransaction]>()
    private let transactionsInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

    private var specifications: TransactionsSpecifications?

    private let disposeBag: DisposeBag = DisposeBag()

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
    
    func refreshTransactions() {

        guard let specifications = specifications else { return }
        let transactions = loadingTransactions(specifications: specifications)
        transactions
            .take(1)
            .subscribe(onNext: { [weak self] txs in
                guard let owner = self else { return }
                owner.refreshTransactionsSubject.onNext(txs)
        })
        .disposed(by: disposeBag)
    }

    private func loadingTransactions(specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.SmartTransaction]> {

        guard let accountAddress = WalletManager.currentWallet?.address else { return Observable.never() }

        return transactionsInteractor
            .transactions(by: accountAddress, specifications: specifications)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }
}
