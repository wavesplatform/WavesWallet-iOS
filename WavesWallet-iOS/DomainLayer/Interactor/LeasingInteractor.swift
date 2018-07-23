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

protocol LeasingInteractorProtocol {
    func activeLeasingTransactions(by accountAddress: String) -> AsyncObservable<[LeasingTransaction]>
}

final class LeasingInteractor: LeasingInteractorProtocol {
    private let leasingProvider: MoyaProvider<Node.Service.Leasing> = .init(plugins: [NetworkLoggerPlugin(verbose: true)])
    private let realm = try! Realm()

    func activeLeasingTransactions(by accountAddress: String) -> AsyncObservable<[LeasingTransaction]> {
        // TODO: DB Implementation
        return leasingProvider
            .rx
            .request(.getActive(accountAddress: accountAddress))
            .map([Node.DTO.LeasingTransaction].self)
            .asObservable()
            .map { $0.map { LeasingTransaction(model: $0) } }
    }
}
