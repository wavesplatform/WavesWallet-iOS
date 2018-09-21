//
//  AccountBalanceRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RxSwift

final class AccountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol {

    private let assetsProvider: MoyaProvider<Node.Service.Assets> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let addressesProvider: MoyaProvider<Node.Service.Addresses> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let matcherBalanceProvider: MoyaProvider<Matcher.Service.Balance> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    func balances(by accountAddress: String, privateKey: PrivateKeyAccount) -> Observable<[DomainLayer.DTO.AssetBalance]> {

        let assetsBalance = self.assetsBalance(by: accountAddress)
        let accountBalance = self.accountBalance(by: accountAddress)
        let matcherBalances = self.matcherBalances(by: accountAddress, privateKey: privateKey)
        
        return Observable
            .zip(assetsBalance,
                 accountBalance,
                 matcherBalances)
            .map { DomainLayer.DTO.AssetBalance.map(assets: $0.0,
                                                    account: $0.1,
                                                    matcherBalances: $0.2) }
    }

    func balance(by id: String) -> Observable<DomainLayer.DTO.AssetBalance> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveBalances(_ balances: [DomainLayer.DTO.AssetBalance]) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveBalance(_ balance: DomainLayer.DTO.AssetBalance) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    var listenerOfUpdatedBalances: Observable<[DomainLayer.DTO.AssetBalance]> = {
        assertVarDontSupported()
        return Observable.never()
    }()
}

private extension AccountBalanceRepositoryRemote {

    func matcherBalances(by accountAddress: String, privateKey: PrivateKeyAccount) -> Observable<[String: Int64]> {
        return self.matcherBalanceProvider
            .rx
            .request(.getReservedBalances(privateKey), callbackQueue: DispatchQueue.global(qos: .background))
            .map([String: Int64].self)
            .asObservable()
            .catchErrorJustReturn([String: Int64]())
    }

    func assetsBalance(by accountAddress: String) -> Observable<Node.DTO.AccountAssetsBalance> {
        return self.assetsProvider
            .rx
            .request(.getAssetsBalance(accountId: accountAddress), callbackQueue: DispatchQueue.global(qos: .background))
            .map(Node.DTO.AccountAssetsBalance.self)
            .asObservable()
    }

    func accountBalance(by accountAddress: String) -> Observable<Node.DTO.AccountBalance> {
        return self.addressesProvider
            .rx
            .request(.getAccountBalance(id: accountAddress), callbackQueue: DispatchQueue.global(qos: .background))
            .map(Node.DTO.AccountBalance.self)
            .asObservable()
    }
}

private extension DomainLayer.DTO.AssetBalance {

    init(accountBalance: Node.DTO.AccountBalance, inOrderBalance: Int64) {
        self.assetId = Environments.Constants.wavesAssetId
        self.balance = accountBalance.balance
        self.leasedBalance = 0
        self.inOrderBalance = inOrderBalance
        self.settings = nil
        self.asset = nil
        self.modified = Date()
    }

    init(model: Node.DTO.AssetBalance, inOrderBalance: Int64) {
        self.assetId = model.assetId
        self.balance = model.balance
        self.leasedBalance = 0
        self.inOrderBalance = inOrderBalance
        self.settings = nil
        self.asset = nil
        self.modified = Date()
    }

    static func map(assets: Node.DTO.AccountAssetsBalance,
                    account: Node.DTO.AccountBalance,
                    matcherBalances: [String: Int64]) -> [DomainLayer.DTO.AssetBalance] {

        let assetsBalance = assets.balances.map { DomainLayer.DTO.AssetBalance(model: $0, inOrderBalance: matcherBalances[$0.assetId] ?? 0) }
        let accountBalance = DomainLayer.DTO.AssetBalance(accountBalance: account,
                                                          inOrderBalance: matcherBalances[Environments.Constants.wavesAssetId] ?? 0)

        var list = [DomainLayer.DTO.AssetBalance]()
        list.append(contentsOf: assetsBalance)
        list.append(accountBalance)

        return list
    }
}
