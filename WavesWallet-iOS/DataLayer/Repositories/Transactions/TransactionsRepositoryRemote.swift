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

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        return transactions
            .rx
            .request(.list(accountAddress: accountAddress,
                           limit: min(Constants.maxLimit, offset + limit)))
            .map(Node.DTO.TransactionContainers.self)
            .map { $0.anyTransactions() }
            .asObservable()        
    }

    func transactions(by accountAddress: String, assetId: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }
}
