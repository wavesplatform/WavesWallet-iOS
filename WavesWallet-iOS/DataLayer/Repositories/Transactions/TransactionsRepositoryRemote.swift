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

private enum Constants {
    static let maxLimit: Int = 10000
}

final class TransactionsRepositoryRemote: TransactionsRepositoryProtocol {

    let transactions: MoyaProvider<Node.Service.Transaction> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

//    private let leasingProvider: MoyaProvider<Node.Service.Leasing> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
//
//    func activeLeasingTransactions(by accountAddress: String) -> AsyncObservable<[DomainLayer.DTO.LeaseTransaction]> {
//        return leasingProvider
//            .rx
//            .request(.getActive(accountAddress: accountAddress), callbackQueue: DispatchQueue.global(qos: .background))
//            .map([Node.DTO.LeaseTransaction].self)
//            .map { $0.map { DomainLayer.DTO.LeaseTransaction(transaction: $0) } }
//            .asObservable()
//    }
//
//    func saveLeasingTransactions(_ transactions:[DomainLayer.DTO.LeaseTransaction]) -> Observable<Bool> {
//        assert(true, "Method don't supported")
//        return Observable.never()
//    }
//
//    func saveLeasingTransaction(_ transaction: DomainLayer.DTO.LeaseTransaction) -> Observable<Bool> {
//        assert(true, "Method don't supported")
//        return Observable.never()
//    }

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        transactions
            .rx
            .request(.list(accountAddress: accountAddress,
                           limit: min(Constants.maxLimit, offset + limit)))
            .map(Node.DTO.TransactionContainers.self)

        return Observable.never()
    }

    func transactions(by accountAddress: String, assetId: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        return Observable.never()
    }
}
