//
//  TransactionsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private struct Constants {
    static let durationInseconds: Double =  15
}

protocol TransactionsInteractorProtocol {
    func transactions(by accountAddress: String) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]>
}

final class TransactionsInteractor: TransactionsInteractorProtocol {

    private var transactionsRepositoryLocal: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryLocal
    private var transactionsRepositoryRemote: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryRemote

    func transactions(by accountAddress: String) -> AsyncObservable<[DomainLayer.DTO.AnyTransaction]> {


        return transactionsRepositoryRemote.transactions(by: accountAddress,
                                                  offset: 0,
                                                  limit: 10000)
            .flatMap(weak: self) { owner, transactions -> Observable<[DomainLayer.DTO.AnyTransaction]> in
                return owner.transactionsRepositoryLocal.saveTransactions(transactions).map { _ in transactions }
            }.flatMap(weak: self, selector: { owner, transaction -> Observable<[DomainLayer.DTO.AnyTransaction]> in
                return owner.transactionsRepositoryLocal.transactions(by: accountAddress,
                                                                      specifications: TransactionsSpecifications(page: .init(offset: 0,
                                                                                                                             limit: 10000),
                                                                                                                 assets: ["WAVES"],
                                                                                                                 senders: [],
                                                                                                                 types: [.transfer]))
            })
    }
}
