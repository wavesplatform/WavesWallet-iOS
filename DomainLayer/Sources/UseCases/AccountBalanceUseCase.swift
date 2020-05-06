//
//  AccountBalanceInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import RxSwift
import WavesSDK
import WavesSDKExtensions

fileprivate enum Constants {
    static let durationInseconds: Double = 0
}

final class AccountBalanceUseCase: AccountBalanceUseCaseProtocol {
    
    private let authorizationInteractor: AuthorizationUseCaseProtocol
    private let balanceRepositoryRemote: AccountBalanceRepositoryProtocol
    private let environmentRepository: EnvironmentRepositoryProtocol

    private let assetsInteractor: AssetsUseCaseProtocol
    private let assetsBalanceSettings: AssetsBalanceSettingsUseCaseProtocol
    private let leasingInteractor: TransactionsUseCaseProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentUseCase

    private let disposeBag: DisposeBag = DisposeBag()

    init(authorizationInteractor: AuthorizationUseCaseProtocol,
         balanceRepositoryRemote: AccountBalanceRepositoryProtocol,
         environmentRepository: EnvironmentRepositoryProtocol,
         assetsInteractor: AssetsUseCaseProtocol,
         assetsBalanceSettings: AssetsBalanceSettingsUseCaseProtocol,
         transactionsInteractor: TransactionsUseCaseProtocol,
         serverEnvironmentUseCase: ServerEnvironmentUseCase) {
        
        self.authorizationInteractor = authorizationInteractor
        self.balanceRepositoryRemote = balanceRepositoryRemote
        self.environmentRepository = environmentRepository
        self.assetsInteractor = assetsInteractor
        self.assetsBalanceSettings = assetsBalanceSettings
        self.leasingInteractor = transactionsInteractor        
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }

    func balances() -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return
            authorizationInteractor
                .authorizedWallet()
                .flatMap { [weak self] wallet -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                    guard let self = self else { return Observable.never() }
                    return self.balances(by: wallet)
                }
    }

    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return remoteBalances(by: wallet)
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }

    func balance(by assetId: String) -> Observable<DomainLayer.DTO.SmartAssetBalance> {
        return
            authorizationInteractor
                .authorizedWallet()
                .flatMap { [weak self] wallet -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                    guard let self = self else { return Observable.never() }
                    return self.balance(by: assetId,
                                        wallet: wallet)
                }
    }

    func balance(by assetId: String,
                 wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.SmartAssetBalance> {
        return remoteBalance(by: wallet,
                             assetId: assetId)
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }
}

// MARK: Privet methods

private extension AccountBalanceUseCase {
    private func assetBalances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.AssetBalance]> {
        
        let serverEnviroment = serverEnvironmentUseCase
            .serverEnvironment()
        
        let balances = serverEnviroment.flatMap({ [weak self] serverEnviroment -> Observable<[DomainLayer.DTO.AssetBalance]> in
            guard let self = self else { return Observable.never() }
            return self.balanceRepositoryRemote.balances(by: serverEnviroment, wallet: wallet)
        })

        let environment = environmentRepository
            .walletEnvironment()

        return Observable.zip(balances, environment)
            .map { (arg) -> [DomainLayer.DTO.AssetBalance] in
                let (balances, environment) = arg

                let generalBalances = environment
                    .generalAssets
                    .map { DomainLayer.DTO.AssetBalance(info: $0) }

                var newBalances = balances
                for generalBalance in generalBalances {
                    if balances.contains(where: { $0.assetId == generalBalance.assetId }) == false {
                        newBalances.append(generalBalance)
                    }
                }
                return newBalances
            }
    }

    private func assetBalance(by wallet: DomainLayer.DTO.SignedWallet,
                              assetId: String) -> Observable<DomainLayer.DTO.AssetBalance> {
        
        let serverEnviroment = serverEnvironmentUseCase
            .serverEnvironment()
        
        return serverEnviroment.flatMap({ [weak self] serverEnviroment -> Observable<DomainLayer.DTO.AssetBalance> in
            guard let self = self else { return Observable.never() }
            return self.balanceRepositoryRemote.balance(by: serverEnviroment,
                                                        assetId: assetId,
                                                        wallet: wallet)
        })
    }

    private func modifyBalances(by wallet: DomainLayer.DTO.SignedWallet,
                                balances: [DomainLayer.DTO.AssetBalance]) -> Observable<[DomainLayer.DTO.AssetBalance]> {
        let activeTransactions = leasingInteractor
            .activeLeasingTransactionsSync(by: wallet.address)
            .flatMap { txs -> Observable<[DomainLayer.DTO.SmartTransaction]> in

                switch txs {
                case let .remote(model):
                    return Observable.just(model)

                case let .local(_, error):
                    return Observable.error(error)

                case let .error(error):
                    return Observable.error(error)
                }
            }
            .map { (txs) -> [DomainLayer.DTO.SmartTransaction.Leasing] in
                txs.map { (tx) -> DomainLayer.DTO.SmartTransaction.Leasing? in
                    if case let .startedLeasing(txLease) = tx.kind, tx.sender.isMyAccount == true {
                        return txLease
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }
            }

        return activeTransactions
            .flatMapLatest { (leasing) -> Observable<[DomainLayer.DTO.AssetBalance]> in
                let amount = leasing.reduce(into: Int64(0)) { $0 = $0 + $1.balance.money.amount }
                let newBalances = balances.mutate(transform: { balance in
                    if balance.assetId == WavesSDKConstants.wavesAssetId {
                        balance.leasedBalance = amount
                    }
                })
                return Observable.just(newBalances)
            }
    }

    private struct MappingQuery {
        let balances: [DomainLayer.DTO.AssetBalance]
        let assets: [String: DomainLayer.DTO.Asset]
        let settings: [String: DomainLayer.DTO.AssetBalanceSettings]
    }


    private func prepareMappingBalancesToSmartBalances(by wallet: DomainLayer.DTO.SignedWallet,
                                                       balances: [DomainLayer.DTO.AssetBalance]) -> Observable<MappingQuery> {
        let assetsIDs = balances.reduce(into: Set<String>()) { result, assetBalance in
            result.insert(assetBalance.assetId)
        }

        let assets = assetsInteractor
            .assetsSync(by: Array(assetsIDs), accountAddress: wallet.address)
            .flatMap { (assets) -> Observable<[DomainLayer.DTO.Asset]> in

                switch assets {
                case let .remote(model):
                    return Observable.just(model)

                case let .local(_, error):
                    return Observable.error(error)

                case let .error(error):
                    return Observable.error(error)
                }
            }

        return assets
            .flatMapLatest { [weak self] (assets) -> Observable<MappingQuery> in

                guard let self = self else { return Observable.never() }

                let settings = self.assetsBalanceSettings
                    .settings(by: wallet.address, assets: assets)
                    .map { (balances) -> [String: DomainLayer.DTO.AssetBalanceSettings] in
                        balances.reduce(into: [String: DomainLayer.DTO.AssetBalanceSettings]()) { $0[$1.assetId] = $1 }
                    }

                let mapAssets = assets.reduce(into: [String: DomainLayer.DTO.Asset]()) { $0[$1.id] = $1 }

                return settings.map { MappingQuery(balances: balances,
                                                   assets: mapAssets,
                                                   settings: $0) }
            }
    }

    private func mappingBalancesToSmartBalances(by _: DomainLayer.DTO.SignedWallet,
                                                query: MappingQuery) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        let newBalances = query.balances.map { (balance) -> DomainLayer.DTO.SmartAssetBalance? in

            guard let settings = query.settings[balance.assetId] else {
                SweetLogger.error("Balance settings not found \(balance.assetId)")
                return nil
            }

            guard var asset = query.assets[balance.assetId] else {
                return nil
            }
            asset.minSponsoredFee = balance.minSponsoredAssetFee
            return DomainLayer.DTO.SmartAssetBalance(assetId: balance.assetId,
                                                     totalBalance: balance.totalBalance,
                                                     leasedBalance: balance.leasedBalance,
                                                     inOrderBalance: balance.inOrderBalance,
                                                     settings: settings,
                                                     asset: asset,
                                                     modified: balance.modified,
                                                     sponsorBalance: balance.sponsorBalance)
        }
        .compactMap { $0 }
        .sorted(by: { $0.settings.sortLevel < $1.settings.sortLevel })
        return Observable.just(newBalances)
    }

    private func remoteBalances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        let assetBalances = self.assetBalances(by: wallet)
        return remoteBalances(by: wallet, assetBalances: assetBalances)
    }

    private func remoteBalance(by wallet: DomainLayer.DTO.SignedWallet,
                               assetId: String) -> Observable<DomainLayer.DTO.SmartAssetBalance> {
        let assetBalance = self.assetBalance(by: wallet, assetId: assetId)
            .map { (balance) -> [DomainLayer.DTO.AssetBalance] in
                [balance]
            }

        return remoteBalances(by: wallet, assetBalances: assetBalance)
            .flatMap { (balances) -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                guard let first = balances.first else {
                    return Observable.error(AccountBalanceUseCaseError.fail)
                }

                return Observable.just(first)
            }
    }

    private func remoteBalances(
        by wallet: DomainLayer.DTO.SignedWallet,
        assetBalances: Observable<[DomainLayer.DTO.AssetBalance]>) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return assetBalances
            .flatMapLatest { [weak self] balances -> Observable<[DomainLayer.DTO.AssetBalance]> in
                guard let self = self else { return Observable.never() }
                return self.modifyBalances(by: wallet, balances: balances)
            }
            .flatMapLatest { [weak self] balances -> Observable<MappingQuery> in
                guard let self = self else { return Observable.never() }
                return self.prepareMappingBalancesToSmartBalances(by: wallet, balances: balances)
            }
            .flatMap { [weak self] query -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.never() }
                return self.mappingBalancesToSmartBalances(by: wallet, query: query)
            }
            .flatMap { [weak self] (balances) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.empty() }
                return self.trackFromZeroBalancesToAnalytic(assets: balances,
                                                            accountAddress: wallet.address)
            }
    }

    func trackFromZeroBalancesToAnalytic(assets: [DomainLayer.DTO.SmartAssetBalance],
                                         accountAddress: String) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return Observable.create { (subscribe) -> Disposable in

            let generalAssets = assets.filter { $0.asset.isGeneral }

            AnalyticAssetManager.trackFromZeroBalances(assets: generalAssets,
                                                       accountAddress: accountAddress)

            subscribe.onNext(assets)
            subscribe.onCompleted()
            return Disposables.create()
        }
    }
}

// MARK: Mapper

private extension DomainLayer.DTO.AssetBalance {
    init(info: WalletEnvironment.AssetInfo) {
        assetId = info.assetId
        totalBalance = 0
        leasedBalance = 0
        inOrderBalance = 0
        modified = Date()
        sponsorBalance = 0
        minSponsoredAssetFee = 0
    }
}
