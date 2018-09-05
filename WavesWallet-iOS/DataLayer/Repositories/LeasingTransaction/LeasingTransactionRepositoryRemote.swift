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

    private let leasingProvider: MoyaProvider<Node.Service.Leasing> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    func activeLeasingTransactions(by accountAddress: String) -> AsyncObservable<[DomainLayer.DTO.LeasingTransaction]> {
        return leasingProvider
            .rx
            .request(.getActive(accountAddress: accountAddress), callbackQueue: DispatchQueue.global(qos: .background))
            .map([Node.DTO.LeasingTransaction].self)
            .map { $0.map { DomainLayer.DTO.LeasingTransaction(transaction: $0) } }
            .asObservable()
    }

    func saveLeasingTransactions(_ transactions:[DomainLayer.DTO.LeasingTransaction]) -> Observable<Bool> {
        assert(true, "Method don't supported")
        return Observable.never()
    }
    
    func saveLeasingTransaction(_ transaction: DomainLayer.DTO.LeasingTransaction) -> Observable<Bool> {
        assert(true, "Method don't supported")
        return Observable.never()
    }
}
