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
import WavesSDKExtension
import WavesSDK
import Base58

private struct SponsoredAssetDetail {
    let minSponsoredAssetFee: Int64?
    let sponsoredBalance: Int64
}

final class AccountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol {
    
    private let applicationEnviroment: Observable<ApplicationEnviroment>
    
    init(applicationEnviroment: Observable<ApplicationEnviroment>) {
        self.applicationEnviroment = applicationEnviroment
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

        if assetId == WavesSDKCryptoConstants.wavesAssetId {
            let accountBalance = self.accountBalance(by: wallet.address)

            return Observable
                .zip(accountBalance,
                     matcherBalances)
                .map({ (accountBalance, matcher) -> DomainLayer.DTO.AssetBalance in
                    let inOrderBalance = matcher[WavesSDKCryptoConstants.wavesAssetId] ?? 0
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
                    let inOrderBalance = matcher[WavesSDKCryptoConstants.wavesAssetId] ?? 0
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

    func matcherBalances(by walletAddress: String,
                         wallet: DomainLayer.DTO.SignedWallet) -> Observable<[String: Int64]> {

        return applicationEnviroment
            .flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<[String: Int64]> in
                
                guard let self = self else { return Observable.never() }

                let signature = TimestampSignature(signedWallet: wallet,
                                                   environment: applicationEnviroment.walletEnviroment)
                
                return applicationEnviroment
                    .services
                    .matcherServices
                    .balanceMatcherService
                    .reservedBalances(query: .init(senderPublicKey: wallet.publicKey.getPublicKeyStr(),
                                                   signature: Base58.encode(signature.signature()),
                                                   timestamp: signature.timestamp))
            })
    }

    func assetBalance(by walletAddress: String,
                      assetId: String) -> Observable<NodeService.DTO.AddressAssetBalance> {

        return applicationEnviroment
            .flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<NodeService.DTO.AddressAssetBalance> in
                
                guard let self = self else { return Observable.never() }
                
                return applicationEnviroment
                    .services
                    .nodeServices
                    .assetsNodeService
                    .assetBalance(address: walletAddress,
                                  assetId: assetId)
            })
    }

    //TODO: https://wavesplatform.atlassian.net/browse/NODE-1488
    func sponsorBalance(assetId: String, walletAddress: String) -> Observable<SponsoredAssetDetail> {
        return assetDetail(assetId: assetId,
                           walletAddress: walletAddress)
            .flatMap { [weak self] (detail) -> Observable<SponsoredAssetDetail> in

                guard let self = self else { return Observable.never() }
                
                return self.balance(for: detail.issuer,
                                     myWalletAddress: walletAddress)
                    .map({ (balance) -> SponsoredAssetDetail in
                        return SponsoredAssetDetail(minSponsoredAssetFee: detail.minSponsoredAssetFee,
                                                    sponsoredBalance: balance.balance)
                    })
            }
    }

    func assetDetail(assetId: String, walletAddress: String) -> Observable<NodeService.DTO.AssetDetail> {

        return applicationEnviroment
            .flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<NodeService.DTO.AssetDetail> in
                
                guard let self = self else { return Observable.never() }
                
                return applicationEnviroment
                    .services
                    .nodeServices
                    .assetsNodeService
                    .assetDetails(assetId: assetId)
            })
    }

    func balance(for walletAddress: String, myWalletAddress: String) -> Observable<NodeService.DTO.AddressBalance> {

        return applicationEnviroment
            .flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<NodeService.DTO.AddressBalance> in

                guard let self = self else { return Observable.never() }
                
                return applicationEnviroment
                    .services
                    .nodeServices
                    .addressesNodeService
                    .addressBalance(address: walletAddress)
            })
    }

    func assetsBalance(by walletAddress: String) -> Observable<NodeService.DTO.AddressAssetsBalance> {

        return applicationEnviroment
            .flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<NodeService.DTO.AddressAssetsBalance> in
                
                guard let self = self else { return Observable.never() }
                
                return applicationEnviroment
                    .services
                    .nodeServices
                    .assetsNodeService
                    .assetsBalances(address: walletAddress)
                
            })
    }

    func accountBalance(by walletAddress: String) -> Observable<NodeService.DTO.AddressBalance> {

        return applicationEnviroment
            .flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<NodeService.DTO.AddressBalance> in
                
                guard let self = self else { return Observable.never() }
                
                return applicationEnviroment
                    .services
                    .nodeServices
                    .addressesNodeService
                    .addressBalance(address: walletAddress)
            })
    }
}

private extension DomainLayer.DTO.AssetBalance {

    init(accountBalance: NodeService.DTO.AddressBalance, inOrderBalance: Int64) {
        self.assetId = WavesSDKCryptoConstants.wavesAssetId
        self.totalBalance = accountBalance.balance
        self.leasedBalance = 0
        self.inOrderBalance = inOrderBalance
        self.modified = Date()
        self.sponsorBalance = 0
        self.minSponsoredAssetFee = 0
    }

    init(model: NodeService.DTO.AssetBalance, inOrderBalance: Int64) {
        self.assetId = model.assetId
        self.totalBalance = model.balance
        self.leasedBalance = 0
        self.inOrderBalance = inOrderBalance
        self.sponsorBalance = model.sponsorBalance ?? 0
        self.modified = Date()
        self.minSponsoredAssetFee = model.minSponsoredAssetFee ?? 0
    }

    init(model: NodeService.DTO.AddressAssetBalance, inOrderBalance: Int64, sponsoredAssetDetail: SponsoredAssetDetail) {
        self.assetId = model.assetId
        self.totalBalance = model.balance
        self.leasedBalance = 0
        self.inOrderBalance = inOrderBalance
        self.sponsorBalance = sponsoredAssetDetail.sponsoredBalance
        self.modified = Date()
        self.minSponsoredAssetFee = sponsoredAssetDetail.minSponsoredAssetFee ?? 0
    }

    static func map(assets: NodeService.DTO.AddressAssetsBalance,
                    account: NodeService.DTO.AddressBalance,
                    matcherBalances: [String: Int64]) -> [DomainLayer.DTO.AssetBalance] {

        let assetsBalance = assets.balances.map { DomainLayer.DTO.AssetBalance(model: $0, inOrderBalance: matcherBalances[$0.assetId] ?? 0) }
        let accountBalance = DomainLayer.DTO.AssetBalance(accountBalance: account,
                                                          inOrderBalance: matcherBalances[WavesSDKCryptoConstants.wavesAssetId] ?? 0)

        var list = [DomainLayer.DTO.AssetBalance]()
        list.append(contentsOf: assetsBalance)
        list.append(accountBalance)

        return list
    }
}
