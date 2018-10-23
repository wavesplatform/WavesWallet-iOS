//
//  LeasingInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import RxSwift
import RxSwiftExt

fileprivate enum Constants {
    static let durationInseconds: Double =  15
}

protocol LeasingInteractorProtocol {
    func activeLeasingTransactions(by accountAddress: String, isNeedUpdate: Bool) -> AsyncObservable<[DomainLayer.DTO.LeaseTransaction]>
}

final class LeasingInteractor: LeasingInteractorProtocol {

    private let leasingTransactionLocal: LeasingTransactionRepositoryProtocol = FactoryRepositories.instance.leasingRepositoryLocal
    private let leasingTransactionRemote: LeasingTransactionRepositoryProtocol = FactoryRepositories.instance.leasingRepositoryRemote

    func activeLeasingTransactions(by accountAddress: String, isNeedUpdate: Bool = false) -> AsyncObservable<[DomainLayer.DTO.LeaseTransaction]> {

            let local = leasingTransactionLocal.activeLeasingTransactions(by: accountAddress)
            return local.flatMap(weak: self) { owner, transactions -> Observable<[DomainLayer.DTO.LeaseTransaction]> in

                let now = Date()
                let isNeedForceUpdate = transactions.count == 0 || transactions.first { (now.timeIntervalSinceNow - $0.modified.timeIntervalSinceNow) > Constants.durationInseconds }  != nil || isNeedUpdate

                if isNeedForceUpdate {
                    info("From Remote", type: LeasingInteractor.self)
                } else {
                    info("From BD", type: LeasingInteractor.self)
                }

                guard isNeedForceUpdate == true else { return Observable.just(transactions) }

                return owner
                    .leasingTransactionRemote
                    .activeLeasingTransactions(by: accountAddress)
                    .flatMap(weak: self, selector: { owner, transactions -> Observable<[DomainLayer.DTO.LeaseTransaction]> in
                        return owner
                            .leasingTransactionLocal
                            .saveLeasingTransactions(transactions, by: accountAddress)
                            .map({ _ -> [DomainLayer.DTO.LeaseTransaction] in
                                return transactions
                            })
                    })
                }
                .share()
                .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
        }
}
