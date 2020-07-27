//
//  AccountBalanceRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import Moya
import RxSwift
import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions

private struct SponsoredAssetDetail {
    let minSponsoredAssetFee: Int64?
    let sponsoredBalance: Int64
}

final class AccountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol {
    private let wavesSDKServices: WavesSDKServices

    init(wavesSDKServices: WavesSDKServices) {
        self.wavesSDKServices = wavesSDKServices
    }

    func balances(by serverEnviroment: ServerEnvironment, wallet: SignedWallet) -> Observable<[AssetBalance]> {
        let walletAddress = wallet.address
        let assetsBalance = self.assetsBalance(by: serverEnviroment,
                                               walletAddress: walletAddress)

        let accountBalance = self.accountBalance(by: serverEnviroment,
                                                 walletAddress: walletAddress)

        let matcherBalances = self.matcherBalances(by: serverEnviroment,
                                                   wallet: wallet)

        return Observable
            .zip(assetsBalance, accountBalance, matcherBalances)
            .map { AssetBalance.map(assets: $0.0, account: $0.1, matcherBalances: $0.2) }
    }

    func balance(by serverEnviroment: ServerEnvironment, assetId: String, wallet: SignedWallet) -> Observable<AssetBalance> {
        let matcherBalances = self.matcherBalances(by: serverEnviroment,
                                                   wallet: wallet).catchError { (error) -> Observable<[String: Int64]> in

            Observable.error(error)
        }

        if assetId == WavesSDKConstants.wavesAssetId {
            let accountBalance = self.accountBalance(by: serverEnviroment,
                                                     walletAddress: wallet.address)

            return Observable
                .zip(accountBalance,
                     matcherBalances)
                .map { accountBalance, matcher -> AssetBalance in
                    let inOrderBalance = matcher[WavesSDKConstants.wavesAssetId] ?? 0
                    return AssetBalance(accountBalance: accountBalance, inOrderBalance: inOrderBalance)
                }
        } else {
            let assetBalance = self.assetBalance(by: serverEnviroment,
                                                 walletAddress: wallet.address, assetId: assetId)

            let sponsorBalance = self.sponsorBalance(serverEnviroment: serverEnviroment,
                                                     assetId: assetId,
                                                     walletAddress: wallet.address)

            return Observable
                .zip(assetBalance,
                     matcherBalances,
                     sponsorBalance)
                .map { assetBalance, matcher, sponsorBalance -> AssetBalance in
                    let inOrderBalance = matcher[assetId] ?? 0
                    return AssetBalance(model: assetBalance,
                                        inOrderBalance: inOrderBalance,
                                        sponsoredAssetDetail: sponsorBalance)
                }
        }
    }

    func deleteBalances(_: [AssetBalance], accountAddress _: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveBalances(_: [AssetBalance], accountAddress _: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveBalance(_: AssetBalance, accountAddress _: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func listenerOfUpdatedBalances(by _: String) -> Observable<[AssetBalance]> {
        assertMethodDontSupported()
        return Observable.never()
    }
}

private extension AccountBalanceRepositoryRemote {
    func matcherBalances(by serverEnviroment: ServerEnvironment,
                         wallet: SignedWallet) -> Observable<[String: Int64]> {
        let wavesServices = wavesSDKServices.wavesServices(environment: serverEnviroment)

        let signature = TimestampSignature(signedWallet: wallet, timestampServerDiff: serverEnviroment.timestampServerDiff)

        return wavesServices
            .matcherServices
            .balanceMatcherService
            .balanceReserved(query: .init(senderPublicKey: wallet.publicKey.getPublicKeyStr(),
                                          signature: Base58Encoder.encode(signature.signature()),
                                          timestamp: signature.timestamp))
    }

    func assetBalance(by serverEnviroment: ServerEnvironment,
                      walletAddress: String,
                      assetId: String) -> Observable<NodeService.DTO.AddressAssetBalance> {
        let wavesServices = wavesSDKServices.wavesServices(environment: serverEnviroment)

        return wavesServices
            .nodeServices
            .assetsNodeService
            .assetBalance(address: walletAddress,
                          assetId: assetId)
    }

    // TODO: https://wavesplatform.atlassian.net/browse/NODE-1488

    func sponsorBalance(serverEnviroment: ServerEnvironment,
                        assetId: String,
                        walletAddress _: String) -> Observable<SponsoredAssetDetail> {
        return assetDetail(serverEnviroment: serverEnviroment, assetId: assetId)
            .flatMap { [weak self] detail -> Observable<SponsoredAssetDetail> in

                guard let self = self else { return Observable.never() }

                return self.balance(for: serverEnviroment, walletAddress: detail.issuer)
                    .map { balance -> SponsoredAssetDetail in
                        SponsoredAssetDetail(minSponsoredAssetFee: detail.minSponsoredAssetFee, sponsoredBalance: balance.balance)
                    }
            }
    }

    func assetDetail(serverEnviroment: ServerEnvironment,
                     assetId: String) -> Observable<NodeService.DTO.AssetDetail> {
        let wavesServices = wavesSDKServices.wavesServices(environment: serverEnviroment)

        return wavesServices
            .nodeServices
            .assetsNodeService
            .assetDetails(assetId: assetId)
    }

    func balance(for serverEnviroment: ServerEnvironment, walletAddress: String) -> Observable<NodeService.DTO.AddressBalance> {
        let wavesServices = wavesSDKServices.wavesServices(environment: serverEnviroment)

        return wavesServices
            .nodeServices
            .addressesNodeService
            .addressBalance(address: walletAddress)
    }

    func assetsBalance(by serverEnviroment: ServerEnvironment,
                       walletAddress: String) -> Observable<NodeService.DTO.AddressAssetsBalance> {
        let wavesServices = wavesSDKServices.wavesServices(environment: serverEnviroment)

        return wavesServices
            .nodeServices
            .assetsNodeService
            .assetsBalances(address: walletAddress)
    }

    func accountBalance(by serverEnviroment: ServerEnvironment,
                        walletAddress: String) -> Observable<NodeService.DTO.AddressBalance> {
        let wavesServices = wavesSDKServices.wavesServices(environment: serverEnviroment)

        return wavesServices
            .nodeServices
            .addressesNodeService
            .addressBalance(address: walletAddress)
    }
}

private extension AssetBalance {
    init(accountBalance: NodeService.DTO.AddressBalance, inOrderBalance: Int64) {
        self.init(assetId: WavesSDKConstants.wavesAssetId,
                  totalBalance: accountBalance.balance,
                  leasedBalance: 0,
                  inOrderBalance: inOrderBalance,
                  modified: Date(),
                  sponsorBalance: 0,
                  minSponsoredAssetFee: 0)
    }

    init(model: NodeService.DTO.AssetBalance, inOrderBalance: Int64) {
        self.init(assetId: model.assetId,
                  totalBalance: model.balance,
                  leasedBalance: 0,
                  inOrderBalance: inOrderBalance,
                  modified: Date(),
                  sponsorBalance: model.sponsorBalance ?? 0,
                  minSponsoredAssetFee: model.minSponsoredAssetFee ?? 0)
    }

    init(model: NodeService.DTO.AddressAssetBalance, inOrderBalance: Int64, sponsoredAssetDetail: SponsoredAssetDetail) {
        self.init(assetId: model.assetId,
                  totalBalance: model.balance,
                  leasedBalance: 0,
                  inOrderBalance: inOrderBalance,
                  modified: Date(),
                  sponsorBalance: sponsoredAssetDetail.sponsoredBalance,
                  minSponsoredAssetFee: sponsoredAssetDetail.minSponsoredAssetFee ?? 0)
    }

    static func map(assets: NodeService.DTO.AddressAssetsBalance,
                    account: NodeService.DTO.AddressBalance,
                    matcherBalances: [String: Int64]) -> [AssetBalance] {
        let assetsBalance = assets.balances.map {
            AssetBalance(model: $0, inOrderBalance: matcherBalances[$0.assetId] ?? 0)
        }
        let accountBalance = AssetBalance(accountBalance: account,
                                          inOrderBalance: matcherBalances[WavesSDKConstants.wavesAssetId] ?? 0)

        var list = [AssetBalance]()
        list.append(contentsOf: assetsBalance)
        list.append(accountBalance)

        return list
    }
}
