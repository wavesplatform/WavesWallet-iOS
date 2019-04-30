//
//  AccountBalanceInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import RxSwift
import RxSwiftExt
import WavesSDKExtension
import WavesSDKCrypto

fileprivate enum Constants {
    static let durationInseconds: Double = 0
}

enum AccountBalanceInteractorError: Error {
    case fail
}

protocol AccountBalanceInteractorProtocol {
    func balances() -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func balance(by assetId: String,
                 wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.SmartAssetBalance>
    func balance(by assetId: String) -> Observable<DomainLayer.DTO.SmartAssetBalance>
}

final class AccountBalanceInteractor: AccountBalanceInteractorProtocol {
    
    private let authorizationInteractor: AuthorizationInteractorProtocol
    private let balanceRepositoryRemote: AccountBalanceRepositoryProtocol
    private let environmentRepository: EnvironmentRepositoryProtocol

    private let assetsInteractor: AssetsInteractorProtocol
    private let assetsBalanceSettings: AssetsBalanceSettingsInteractorProtocol
    private let leasingInteractor: TransactionsInteractorProtocol
    private let assetsBalanceSettingsRepository: AssetsBalanceSettingsRepositoryProtocol

    private let disposeBag: DisposeBag = DisposeBag()

    init(authorizationInteractor: AuthorizationInteractorProtocol,
         balanceRepositoryRemote: AccountBalanceRepositoryProtocol,
         environmentRepository: EnvironmentRepositoryProtocol,
         assetsInteractor: AssetsInteractorProtocol,
         assetsBalanceSettings: AssetsBalanceSettingsInteractorProtocol,
         transactionsInteractor: TransactionsInteractorProtocol,
         assetsBalanceSettingsRepository: AssetsBalanceSettingsRepositoryProtocol) {

        self.authorizationInteractor = authorizationInteractor
        self.balanceRepositoryRemote = balanceRepositoryRemote
        self.environmentRepository = environmentRepository
        self.assetsInteractor = assetsInteractor
        self.assetsBalanceSettings = assetsBalanceSettings
        self.leasingInteractor = transactionsInteractor
        self.assetsBalanceSettingsRepository = assetsBalanceSettingsRepository
    }

    func balances() -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return
            authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.never() }
                return self.balances(by: wallet)
            })
    }
    
    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return self
            .remoteBalances(by: wallet)
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }

    func balance(by assetId: String) -> Observable<DomainLayer.DTO.SmartAssetBalance> {
        return
            authorizationInteractor
                .authorizedWallet()
                .flatMap({ [weak self] wallet -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                    guard let self = self else { return Observable.never() }
                    return self.balance(by: assetId,
                                         wallet: wallet)
                })
    }

    func balance(by assetId: String,
                 wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.SmartAssetBalance> {
        return self
            .remoteBalance(by: wallet,
                           assetId: assetId)
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }
}

// MARK: Privet methods

private extension AccountBalanceInteractor {

    private func assetBalances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.AssetBalance]> {

        let balances = balanceRepositoryRemote.balances(by: wallet)
        let environment = environmentRepository.accountEnvironment(accountAddress: wallet.address)

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

        return balanceRepositoryRemote.balance(by: assetId, wallet: wallet)
    }

    private func modifyBalances(by wallet: DomainLayer.DTO.SignedWallet,
                                balances: [DomainLayer.DTO.AssetBalance]) -> Observable<[DomainLayer.DTO.AssetBalance]> {

        let activeTransactions = leasingInteractor
            .activeLeasingTransactionsSync(by: wallet.address)
            .flatMap { (txs) -> Observable<[DomainLayer.DTO.SmartTransaction]> in

                switch txs {
                case .remote(let model):
                    return Observable.just(model)

                case .local(_, let error):
                    return Observable.error(error)

                case .error(let error):
                    return Observable.error(error)

                }
            }
            .map { (txs) -> [DomainLayer.DTO.SmartTransaction.Leasing] in
                return txs.map({ (tx) -> DomainLayer.DTO.SmartTransaction.Leasing? in
                    if case .startedLeasing(let txLease) = tx.kind, tx.sender.isMyAccount == true {
                        return txLease
                    } else {
                        return nil
                    }
                })
                .compactMap { $0 }
            }

        return activeTransactions
            .flatMapLatest { (leasing) -> Observable<[DomainLayer.DTO.AssetBalance]> in
                let amount = leasing.reduce(into: Int64(0), { $0 = $0 + $1.balance.money.amount })
                let newBalances = balances.mutate(transform: { (balance) in
                    if balance.assetId == WavesSDKCryptoConstants.wavesAssetId {
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

    func removeOldsBalanceSettings(by wallet: DomainLayer.DTO.SignedWallet,
                                   balances: [DomainLayer.DTO.SmartAssetBalance]) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return assetsBalanceSettingsRepository
            .removeBalancesSettting(actualIds: balances.map {$0.assetId}, accountAddress: wallet.address)
            .flatMap({ (success) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                return Observable.just(balances)
            })
    }
    
    private func prepareMappingBalancesToSmartBalances(by wallet: DomainLayer.DTO.SignedWallet,
                                                       balances: [DomainLayer.DTO.AssetBalance]) -> Observable<MappingQuery> {

        let assetsIDs = balances.reduce(into: Set<String>()) { (result, assetBalance) in
            result.insert(assetBalance.assetId)
        }

        let assets = assetsInteractor
            .assetsSync(by: Array(assetsIDs), accountAddress: wallet.address)
            .flatMap { (assets) -> Observable<[DomainLayer.DTO.Asset]> in

                switch assets {
                case .remote(let model):
                    return Observable.just(model)

                case .local(_, let error):
                    return Observable.error(error)

                case .error(let error):
                    return Observable.error(error)

                }
        }

        return assets
            .flatMapLatest({ [weak self] (assets) -> Observable<MappingQuery> in

                guard let self = self else { return Observable.never() }

                let settings = self.assetsBalanceSettings
                    .settings(by: wallet.address, assets: assets)
                    .map { (balances) -> [String: DomainLayer.DTO.AssetBalanceSettings] in
                        return balances.reduce(into: [String: DomainLayer.DTO.AssetBalanceSettings](), { $0[$1.assetId] = $1 })
                }

                let mapAssets = assets.reduce(into: [String: DomainLayer.DTO.Asset](), { $0[$1.id] = $1 })

                return settings.map { MappingQuery(balances: balances,
                                                   assets: mapAssets,
                                                   settings: $0) }
            })
    }

    private func mappingBalancesToSmartBalances(by wallet: DomainLayer.DTO.SignedWallet,
                                                query: MappingQuery) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {

        let newBalances = query.balances.map { (balance) -> DomainLayer.DTO.SmartAssetBalance? in

            guard let settings = query.settings[balance.assetId] else {
                SweetLogger.error("Balance settings not found \(balance.assetId)")
                return nil
            }

            guard var asset = query.assets[balance.assetId] else {
                return nil
            }

            //TODO: Remove line when fixing bug 
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
                return [balance]
            }

        return remoteBalances(by: wallet, assetBalances: assetBalance)
            .flatMap({ (balances) -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                guard let first = balances.first else {
                    return Observable.error(AccountBalanceInteractorError.fail)
                }

                return Observable.just(first)
            })
    }

    private func remoteBalances(by wallet: DomainLayer.DTO.SignedWallet,
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
            .flatMap({ [weak self] (balances) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.empty()}
                return self.removeOldsBalanceSettings(by: wallet, balances: balances)
            })
            .flatMap({ [weak self] (balances) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.empty() }
                return self.trackFromZeroBalancesToAnalytic(assets: balances,
                                                            accountAddress: wallet.address)
            })
            .flatMap({ [weak self] (balances) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.empty() }
                return self.cleanWalletList(assets: balances, accountAddress: wallet.address)
            })
    }
    
    func trackFromZeroBalancesToAnalytic(assets: [DomainLayer.DTO.SmartAssetBalance], accountAddress: String) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return Observable.create({ (subscribe) -> Disposable in
            
            let generalAssets = assets.filter { $0.asset.isGeneral }
            AnalyticAssetManager.trackFromZeroBalances(assets: generalAssets,
                                                       accountAddress: accountAddress)
            
            subscribe.onNext(assets)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func cleanWalletList(assets: [DomainLayer.DTO.SmartAssetBalance], accountAddress: String) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {

        let generalAssets = assets.filter { $0.asset.isGeneral }
        let isNewWallet = assets.count == generalAssets.count
        
        if isNewWallet && CleanerWalletManager.isCleanWallet(by: accountAddress) == false {
            CleanerWalletManager.setCleanWallet(accountAddress: accountAddress)
        }
        
        if CleanerWalletManager.isCleanWallet(by: accountAddress) {
            return Observable.just(assets)
        }

        var newAssets: [DomainLayer.DTO.SmartAssetBalance] = []
        var hiddenAssets: [DomainLayer.DTO.SmartAssetBalance] = []
        
        for smartAsset in assets {
            
            if smartAsset.asset.isGeneral &&
                smartAsset.settings.isFavorite == false &&
                smartAsset.asset.isWaves == false &&
                smartAsset.availableBalance == 0 {
                
                var newAsset = smartAsset
                newAsset.settings = newAsset.settings.mutate {
                    $0.isHidden = true
                    $0.isFavorite = false
                }
                hiddenAssets.append(newAsset)
                
                continue
            }
            
            
            if smartAsset.asset.isWavesToken &&
                smartAsset.settings.isFavorite == false &&
                smartAsset.asset.isMyWavesToken == false &&
                smartAsset.asset.isSpam == false {
                
                var newAsset = smartAsset
                newAsset.settings = newAsset.settings.mutate {
                    $0.isHidden = true
                    $0.isFavorite = false
                }
                
                hiddenAssets.append(newAsset)
                continue
            }
            newAssets.append(smartAsset)
        }
        
        let generalHiddenAssets = hiddenAssets.filter { $0.asset.isGeneral }
        let otherHiddenAssets = hiddenAssets.filter { $0.asset.isGeneral == false }
        
        newAssets.append(contentsOf: generalHiddenAssets)
        newAssets.append(contentsOf: otherHiddenAssets)
        
        for index in 0..<newAssets.count {
            var asset = newAssets[index]
            asset.settings = asset.settings.mutate {
                $0.sortLevel = Float(index)
            }
            newAssets[index] = asset
        }
        
        let newSettings = newAssets.map { $0.settings }
        
        return assetsBalanceSettingsRepository.saveSettings(by: accountAddress, settings: newSettings)
            .flatMap({ (success) -> Observable<[DomainLayer.DTO.SmartAssetBalance]>  in
                
                return CleanerWalletManager.rx.setCleanWallet(accountAddress: accountAddress)
                    .flatMap({ (success) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                        
                        return Observable.just(newAssets)
                    })
            })

    }
}

// MARK: Mapper

private extension DomainLayer.DTO.AssetBalance {

    init(info: Environment.AssetInfo) {
        self.assetId = info.assetId
        self.totalBalance = 0
        self.leasedBalance = 0
        self.inOrderBalance = 0
        self.modified = Date()
        self.sponsorBalance = 0
        self.minSponsoredAssetFee = 0
    }
}
