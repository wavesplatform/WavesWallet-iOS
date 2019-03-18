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

private struct SponsoredAssetDetail {
    let minSponsoredAssetFee: Int64?
    let sponsoredBalance: Int64
}

final class AccountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol {

    private let assetsProvider: MoyaProvider<Node.Service.Assets> = .nodeMoyaProvider()
    private let addressesProvider: MoyaProvider<Node.Service.Addresses> = .nodeMoyaProvider()
    private let matcherBalanceProvider: MoyaProvider<Matcher.Service.Balance> = .nodeMoyaProvider()

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.AssetBalance]> {

        let walletAddress = wallet.address
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

    func balance(by assetId: String, wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.AssetBalance> {

        let matcherBalances = self.matcherBalances(by: wallet.address, wallet: wallet)

        if assetId == GlobalConstants.wavesAssetId {
            let accountBalance = self.accountBalance(by: wallet.address)

            return Observable
                .zip(accountBalance,
                     matcherBalances)
                .map({ (accountBalance, matcher) -> DomainLayer.DTO.AssetBalance in
                    let inOrderBalance = matcher[GlobalConstants.wavesAssetId] ?? 0
                    return DomainLayer.DTO.AssetBalance(accountBalance: accountBalance, inOrderBalance: inOrderBalance)
                })
        } else {
            let assetBalance = self.assetBalance(by: wallet.address, assetId: assetId)
            let sponsorBalance = self.sponsorBalance(assetId: assetId, walletAddress: wallet.address)

            return Observable
                .zip(assetBalance,
                     matcherBalances,
                     sponsorBalance)
                .map({ (assetBalance, matcher, sponsorBalance) -> DomainLayer.DTO.AssetBalance in
                    let inOrderBalance = matcher[GlobalConstants.wavesAssetId] ?? 0
                    return DomainLayer.DTO.AssetBalance(model: assetBalance,
                                                        inOrderBalance: inOrderBalance,
                                                        sponsoredAssetDetail: sponsorBalance)
                })
        }
    }

    func deleteBalances(_ balances:[DomainLayer.DTO.AssetBalance], accountAddress: String) -> Observable<Bool> {
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

        return environmentRepository
            .accountEnvironment(accountAddress: wallet.address)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }

                let signature = TimestampSignature(signedWallet: wallet,
                                                   environment: environment)

                return owner
                    .matcherBalanceProvider
                    .rx
                    .request(.init(kind: .getReservedBalances(signature),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map([String: Int64].self)
    }

    func assetBalance(by walletAddress: String,
                      assetId: String) -> Observable<Node.DTO.AccountAssetBalance> {

        return environmentRepository
            .accountEnvironment(accountAddress: walletAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .assetsProvider
                    .rx
                    .request(.init(kind: .getAssetsBalance(address: walletAddress, assetId: assetId),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map(Node.DTO.AccountAssetBalance.self)
            .asObservable()
    }

    //TODO: https://wavesplatform.atlassian.net/browse/NODE-1488
    
    func sponsorBalance(assetId: String, walletAddress: String) -> Observable<SponsoredAssetDetail> {
        return assetDetail(assetId: assetId,
                           walletAddress: walletAddress)
            .flatMap { [weak self] (detail) -> Observable<SponsoredAssetDetail> in

                guard let owner = self else { return Observable.never() }
                
                return owner.balance(for: detail.issuer,
                                     myWalletAddress: walletAddress)
                    .map({ (balance) -> SponsoredAssetDetail in
                        return SponsoredAssetDetail(minSponsoredAssetFee: detail.minSponsoredAssetFee,
                                                    sponsoredBalance: balance.balance)
                    })
            }
    }

    func assetDetail(assetId: String, walletAddress: String) -> Observable<Node.DTO.AssetDetail> {

        return environmentRepository
            .accountEnvironment(accountAddress: walletAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .assetsProvider
                    .rx
                    .request(.init(kind: .details(assetId: assetId),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map(Node.DTO.AssetDetail.self)
            .asObservable()
    }

    func balance(for walletAddress: String, myWalletAddress: String) -> Observable<Node.DTO.AccountBalance> {

        return environmentRepository
            .accountEnvironment(accountAddress: myWalletAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .addressesProvider
                    .rx
                    .request(.init(kind: .getAccountBalance(id: walletAddress),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map(Node.DTO.AccountBalance.self)
            .asObservable()
    }

    func assetsBalance(by walletAddress: String) -> Observable<Node.DTO.AccountAssetsBalance> {

        return environmentRepository
            .accountEnvironment(accountAddress: walletAddress)
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .assetsProvider
                    .rx
                    .request(.init(kind: .getAssetsBalances(walletAddress: walletAddress),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
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
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map(Node.DTO.AccountBalance.self)
    }
}

private extension DomainLayer.DTO.AssetBalance {

    init(accountBalance: Node.DTO.AccountBalance, inOrderBalance: Int64) {
        self.assetId = GlobalConstants.wavesAssetId
        self.totalBalance = accountBalance.balance
        self.leasedBalance = 0
        self.inOrderBalance = inOrderBalance
        self.modified = Date()
        self.sponsorBalance = 0
        self.minSponsoredAssetFee = 0
    }

    init(model: Node.DTO.AssetBalance, inOrderBalance: Int64) {
        self.assetId = model.assetId
        self.totalBalance = model.balance
        self.leasedBalance = 0
        self.inOrderBalance = inOrderBalance
        self.sponsorBalance = model.sponsorBalance ?? 0
        self.modified = Date()
        self.minSponsoredAssetFee = model.minSponsoredAssetFee ?? 0
    }

    init(model: Node.DTO.AccountAssetBalance, inOrderBalance: Int64, sponsoredAssetDetail: SponsoredAssetDetail) {
        self.assetId = model.assetId
        self.totalBalance = model.balance
        self.leasedBalance = 0
        self.inOrderBalance = inOrderBalance
        self.sponsorBalance = sponsoredAssetDetail.sponsoredBalance
        self.modified = Date()
        self.minSponsoredAssetFee = sponsoredAssetDetail.minSponsoredAssetFee ?? 0
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
