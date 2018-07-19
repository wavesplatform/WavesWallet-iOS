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
    func activeLeasingTransactions(by accountAddress: String) -> AsyncObservable<DomainLayer.DTO.Leasing>
}

final class LeasingInteractor: LeasingInteractorProtocol {
    private let assetsProvider: MoyaProvider<Node.Service.Leasing> = .init(plugins: [NetworkLoggerPlugin(verbose: true)])
    private let assetBalance: AccountBalanceInteractorProtocol = AccountBalanceInteractor()
    private let realm = try! Realm()

    func activeLeasingTransactions(by accountAddress: String) -> AsyncObservable<DomainLayer.DTO.Leasing> {
        let transactions = assetsProvider
            .rx
            .request(.getActive(accountAddress: accountAddress))
            .map([Node.DTO.LeasingTransaction].self)
            .asObservable()
            .map { $0.map { LeasingTransaction(model: $0) } }

        let balance = assetBalance
            .balances(by: accountAddress)
            .map { $0.first { $0.assetId == Environments.Constants.wavesAssetId } }
            .flatMap { balance -> Observable<AssetBalance> in
                guard let balance = balance else { return Observable.empty() }
                return Observable.just(balance)
            }

        return Observable
            .zip(transactions, balance)
            .map({ transactions, balance -> DomainLayer.DTO.Leasing in
                return DomainLayer.DTO.Leasing(balance: balance,
                                                transaction: transactions)
            })
    }
}
