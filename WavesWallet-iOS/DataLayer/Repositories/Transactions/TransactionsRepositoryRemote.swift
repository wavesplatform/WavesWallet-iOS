//
//  TransactionsRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

fileprivate enum Constants {
    static let maxLimit: Int = 10000
}

final class TransactionsRepositoryRemote: TransactionsRepositoryProtocol {

    private let transactions: MoyaProvider<Node.Service.Transaction> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let leasingProvider: MoyaProvider<Node.Service.Leasing> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        return environmentRepository
            .environment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }

                let limit = min(Constants.maxLimit, offset + limit)

                return owner
                    .transactions
                    .rx
                    .request(.init(kind: .list(accountAddress: accountAddress,
                                               limit: limit),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map(Node.DTO.TransactionContainers.self)
            .map { $0.anyTransactions() }
            .asObservable()        
    }

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> {

        return environmentRepository
            .environment(accountAddress: accountAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .leasingProvider
                    .rx
                    .request(.init(kind: .getActive(accountAddress: accountAddress),
                                   environment: environment),
                                   callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map([Node.DTO.LeaseTransaction].self)
            .map { $0.map { DomainLayer.DTO.LeaseTransaction(transaction: $0) } }
            .asObservable()
    }


    func transactions(by accountAddress: String,
                      specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    var isHasTransactions: Observable<Bool> {
        assertVarDontSupported()
        return Observable.never()
    }

    func isHasTransaction(by id: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by ids: [String]) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }
}
