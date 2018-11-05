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

    private let assetsProvider: MoyaProvider<Node.Service.Assets> = .nodeMoyaProvider()
    private let addressesProvider: MoyaProvider<Node.Service.Addresses> = .nodeMoyaProvider()
    private let matcherBalanceProvider: MoyaProvider<Matcher.Service.Balance> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.AssetBalance]> {

        let walletAddress = wallet.wallet.address
        let assetsBalance = self.assetsBalance(by: walletAddress)
        let accountBalance = self.accountBalance(by: walletAddress)
        let matcherBalances = self.matcherBalances(by: walletAddress, wallet: wallet)
        
        return Observable
            .zip(assetsBalance,
                 accountBalance,
                 matcherBalances)
            .map { DomainLayer.DTO.AssetBalance.map(assets: $0.0,
                                                    account: $0.1,
                                                    matcherBalances: $0.2) }
    }

    func balance(by id: String, accountAddress: String) -> Observable<DomainLayer.DTO.AssetBalance> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func balances(by accountAddress: String, specification: AccountBalanceSpecifications) -> Observable<[DomainLayer.DTO.AssetBalance]> {
        assertMethodDontSupported()
        return Observable.never()
    }


    func saveBalances(_ balances: [DomainLayer.DTO.AssetBalance], accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveBalance(_ balance: DomainLayer.DTO.AssetBalance, accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func listenerOfUpdatedBalances(by accountAddress: String) -> Observable<[DomainLayer.DTO.AssetBalance]> {
        assertMethodDontSupported()
        return Observable.never()
    }
}

private extension AccountBalanceRepositoryRemote {

    func matcherBalances(by walletAddress: String, wallet: DomainLayer.DTO.SignedWallet) -> Observable<[String: Int64]> {

        let signature = TimestampSignature(signedWallet: wallet)

        return environmentRepository
            .accountEnvironment(accountAddress: wallet.wallet.address)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }

                return owner
                    .matcherBalanceProvider
                    .rx
                    .request(.init(kind: .getReservedBalances(signature),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map([String: Int64].self)
            .asObservable()
            .catchErrorJustReturn([String: Int64]())
    }

    func assetsBalance(by walletAddress: String) -> Observable<Node.DTO.AccountAssetsBalance> {

        return environmentRepository
            .accountEnvironment(accountAddress: walletAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .assetsProvider
                    .rx
                    .request(.init(kind: .getAssetsBalance(walletAddress: walletAddress),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map(Node.DTO.AccountAssetsBalance.self)
            .asObservable()
    }

    func accountBalance(by walletAddress: String) -> Observable<Node.DTO.AccountBalance> {

        return environmentRepository
            .accountEnvironment(accountAddress: walletAddress)
            .flatMap { [weak self] environment -> Single<Response> in
                guard let owner = self else { return Single.never() }
                return owner
                    .addressesProvider
                    .rx
                    .request(.init(kind: .getAccountBalance(id: walletAddress),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .background))
            }
            .map(Node.DTO.AccountBalance.self)
            .asObservable()
    }
}

private extension DomainLayer.DTO.AssetBalance {

    init(accountBalance: Node.DTO.AccountBalance, inOrderBalance: Int64) {
        self.assetId = GlobalConstants.wavesAssetId
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
                                                          inOrderBalance: matcherBalances[GlobalConstants.wavesAssetId] ?? 0)

        var list = [DomainLayer.DTO.AssetBalance]()
        list.append(contentsOf: assetsBalance)
        list.append(accountBalance)

        return list
    }
}
