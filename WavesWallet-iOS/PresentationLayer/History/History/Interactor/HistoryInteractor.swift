//
//  HistoryInteractor.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol HistoryInteractorProtocol {
    func transactions(input: HistoryModuleInput) -> AsyncObservable<[GeneralTypes.DTO.Transaction]>
    func refreshTransactions()
}

final class HistoryInteractorMock: HistoryInteractorProtocol {
    
    private let refreshTransactionsSubject: PublishSubject<[GeneralTypes.DTO.Transaction]> = PublishSubject<[GeneralTypes.DTO.Transaction]>()
    private let transactionsInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

    private var specifications: TransactionsSpecifications?

    private let disposeBag: DisposeBag = DisposeBag()

    func transactions(input: HistoryModuleInput) -> Observable<[GeneralTypes.DTO.Transaction]> {

        var specifications: TransactionsSpecifications! = nil

        switch input.type {
        case .all:
            specifications = TransactionsSpecifications.init(page: .init(offset: 0, limit: 1000),
                                               assets: [],
                                               senders: [],
                                               types: TransactionType.all)
        case .asset(let id):
            specifications = TransactionsSpecifications.init(page: .init(offset: 0, limit: 1000),
                                               assets: [id],
                                               senders: [],
                                               types: TransactionType.all)
        case .leasing:
            specifications = TransactionsSpecifications.init(page: .init(offset: 0, limit: 1000),
                                               assets: [],
                                               senders: [],
                                               types: [.lease, .leaseCancel])
        }

        self.specifications = specifications

        let transactions =  loadingTransactions(specifications: specifications)
        return Observable.merge(transactions, refreshTransactionsSubject.asObserver())
    }
    
    func refreshTransactions() {

        guard let specifications = specifications else { return }
        let transactions =  loadingTransactions(specifications: specifications)
        transactions
            .take(1)
            .subscribe(onNext: { [weak self] txs in
                guard let owner = self else { return }
                owner.refreshTransactionsSubject.onNext(txs)
        })
        .disposed(by: disposeBag)
    }

    private func loadingTransactions(specifications: TransactionsSpecifications) -> Observable<[GeneralTypes.DTO.Transaction]> {

        guard let accountAddress = WalletManager.currentWallet?.address else { return Observable.never() }
        let asset = GeneralTypes.DTO.Transaction.init(id: "", kind: .data(.init()), date: Date())

        return transactionsInteractor
            .transactions(by: accountAddress, specifications: specifications)
            .sweetDebug("Gop")
            .map { txs in txs.map { _ in asset } }
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }
}
