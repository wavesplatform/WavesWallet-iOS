//
//  LeasingTransactionRemote.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

final class LeasingTransactionRepositoryRemote: LeasingTransactionRepositoryProtocol {

    private let leasingProvider: MoyaProvider<Node.Service.Leasing> = .nodeMoyaProvider()
    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Observable<[DomainLayer.DTO.LeaseTransaction]> in

                guard let owner = self else { return Observable.never() }
                return owner
                    .leasingProvider
                    .rx
                    .request(.init(kind: .getActive(accountAddress: accountAddress),
                                   environment: environment),
                            callbackQueue: DispatchQueue.global(qos: .background))
                    .map([Node.DTO.LeaseTransaction].self)
                    .map { $0.map { DomainLayer.DTO.LeaseTransaction(transaction: $0, status: .activeNow, environment: environment) } }
                    .asObservable()
            }

    }

    func saveLeasingTransactions(_ transactions:[DomainLayer.DTO.LeaseTransaction], by accountAddress: String) -> Observable<Bool> {
        assert(true, "Method don't supported")
        return Observable.never()
    }
    
    func saveLeasingTransaction(_ transaction: DomainLayer.DTO.LeaseTransaction, by accountAddress: String) -> Observable<Bool> {
        assert(true, "Method don't supported")
        return Observable.never()
    }
}
