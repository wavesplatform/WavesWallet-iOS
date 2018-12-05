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

fileprivate enum Constants {
    static let durationInseconds: Double = 0
}

protocol AccountBalanceInteractorProtocol {
    func balances() -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
}

final class AccountBalanceInteractor: AccountBalanceInteractorProtocol {
    
    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let balanceRepositoryLocal: AccountBalanceRepositoryProtocol = FactoryRepositories.instance.accountBalanceRepositoryLocal
    private let balanceRepositoryRemote: AccountBalanceRepositoryProtocol = FactoryRepositories.instance.accountBalanceRepositoryRemote
    private let environmentRepository: EnvironmentRepositoryProtocol = FactoryRepositories.instance.environmentRepository

    private let assetsInteractor: AssetsInteractorProtocol = FactoryInteractors.instance.assetsInteractor
    private let assetsBalanceSettings: AssetsBalanceSettingsInteractorProtocol = FactoryInteractors.instance.assetsBalanceSettings
    private let leasingInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

    private let disposeBag: DisposeBag = DisposeBag()

    func balances() -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return
            authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let owner = self else { return Observable.never() }
                return owner.balances(by: wallet)
            })
    }
    
    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return self
            .remoteBalances(by: wallet)
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
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
                    .generalAssetIds
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

    private func modifyBalances(by wallet: DomainLayer.DTO.SignedWallet, balances: [DomainLayer.DTO.AssetBalance]) -> Observable<[DomainLayer.DTO.AssetBalance]> {

        let activeTransactions = leasingInteractor.activeLeasingTransactionsSync(by: wallet.address)
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
                    if balance.assetId == GlobalConstants.wavesAssetId {
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

                guard let owner = self else { return Observable.never() }

                let settings = owner.assetsBalanceSettings
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
                return nil
            }

            guard let asset = query.assets[balance.assetId] else {
                return nil
            }

            return DomainLayer.DTO.SmartAssetBalance(assetId: balance.assetId,
                                                    totalBalance: balance.totalBalance,
                                                    leasedBalance: balance.leasedBalance,
                                                    inOrderBalance: balance.inOrderBalance,
                                                    settings: settings,
                                                    asset: asset,
                                                    modified: balance.modified)
        }
        .compactMap { $0 }
        .sorted(by: { $0.settings.sortLevel < $1.settings.sortLevel })

        return Observable.just(newBalances)
    }

    private func remoteBalances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {

        return assetBalances(by: wallet)
            .flatMapLatest { [weak self] balances -> Observable<[DomainLayer.DTO.AssetBalance]> in
                guard let owner = self else { return Observable.never() }
                return owner.modifyBalances(by: wallet, balances: balances)
            }
            .flatMapLatest { [weak self] balances -> Observable<MappingQuery> in
                guard let owner = self else { return Observable.never() }
                return owner.prepareMappingBalancesToSmartBalances(by: wallet, balances: balances)
            }
            .flatMap { [weak self] query -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let owner = self else { return Observable.never() }
                return owner.mappingBalancesToSmartBalances(by: wallet, query: query)
            }
    }
        

//        let environment = environmentRepository.accountEnvironment(accountAddress: wallet.address)

//        return Observable.zip(balances, activeTransactions, environment)
//            .map { balances, transactions, environment -> [DomainLayer.DTO.SmartAssetBalance] in
//
//                let generalBalances = environment.generalAssetIds.map { DomainLayer.DTO.SmartAssetBalance(info: $0) }
//                var newBalances = balances
//                for generalBalance in generalBalances {
//                    if balances.contains(where: { $0.assetId == generalBalance.assetId }) == false {
//                        newBalances.append(generalBalance)
//                    }
//                }
//
//                //Change waves balance
//                if let wavesAssetBalance = newBalances
//                    .enumerated()
//                    .first(where: { $0.element.assetId == GlobalConstants.wavesAssetId }) {
//
//                    let leasedBalance: Int64 = transactions
//                        .filter { $0.sender.address == walletAddress }
//                        .reduce(into: 0, { result, tx in
//                            if case .startedLeasing(let txLease) = tx.kind {
//                                result = result + txLease.balance.money.amount
//                            }
//                        })
//
//                    let newWavesAssetBalance = wavesAssetBalance
//                        .element
//                        .mutate { balance in
//                            balance.leasedBalance = leasedBalance
//                        }
//
//                    newBalances[wavesAssetBalance.offset] = newWavesAssetBalance
//                }
//
//                return newBalances
//            }
//            .flatMap(weak: self) { owner, balances -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
//
//                let ids = balances.map { $0.assetId }
//                return owner
//                    .assetsInteractor
//                    .assets(by: ids, accountAddress: walletAddress, isNeedUpdated: isNeedUpdate)
//                    .flatMap(weak: owner) { (owner, assets) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
//                        let mapAssets = assets.reduce([String: DomainLayer.DTO.Asset]()) {
//                            var map = $0
//                            map[$1.id] = $1
//                            return map
//                        }
//
//                        let oldSettings = localBalance.reduce([String: DomainLayer.DTO.SmartAssetBalance.Settings]()) {
//                            var map = $0
//                            if let settings = $1.settings {
//                                map[settings.assetId] = settings
//                            }
//                            return map
//                        }
//
//                        var newBalances = balances
//                        for (index, balance) in newBalances.enumerated() {
//                            newBalances[index].asset = mapAssets[balance.assetId]
//                            newBalances[index].settings = oldSettings[balance.assetId]
//                        }
//                        newBalances = owner.initialSettings(for: newBalances)
//                        return owner
//                            .balanceRepositoryLocal
//                            .saveBalances(newBalances, accountAddress: walletAddress)
//                            .map { _ in newBalances }
//                    }
//            }
//            .flatMap(weak: self) { owner, balances -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
//                let map = balances.reduce(into: [String: DomainLayer.DTO.SmartAssetBalance](), { (result, balance) in
//                    result[balance.assetId] = balance
//                })
//
//                var deleteBalances = localBalance
//                deleteBalances.removeAll(where: { (balance) -> Bool in
//                    return map[balance.assetId] != nil
//                })
//
//                return owner
//                    .balanceRepositoryLocal
//                    .deleteBalances(deleteBalances, accountAddress: walletAddress)
//                    .map { _ in balances }
//            }
//            .flatMap(weak: self) { owner, balances -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
//                return Observable.merge(Observable.just(balances), owner.balanceRepositoryLocal.listenerOfUpdatedBalances(by: walletAddress))
//            }
    }
//
//    func initialSettings(for balances: [DomainLayer.DTO.SmartAssetBalance]) -> [DomainLayer.DTO.SmartAssetBalance] {
//
//        let generalBalances = Environments
//            .current
//            .generalAssetIds
//
//        var newBalances = balances
//            .sorted { assetOne, assetTwo -> Bool in
//
//                let isGeneralOne = assetOne.asset.isGeneral
//                let isGeneralTwo = assetTwo.asset.isGeneral
//
//                if isGeneralOne == true && isGeneralTwo == true {
//                    let indexOne = generalBalances
//                        .enumerated()
//                        .first(where: { $0.element.assetId == assetOne.assetId })
//                        .map { $0.offset }
//
//                    let indexTwo = generalBalances
//                        .enumerated()
//                        .first(where: { $0.element.assetId == assetTwo.assetId })
//                        .map { $0.offset }
//
//                    if let indexOne = indexOne, let indexTwo = indexTwo {
//                        return indexOne < indexTwo
//                    }
//                    return false
//                }
//
//                if isGeneralOne {
//                    return true
//                }
//                return false
//            }
//
//        let oldBalances = balances
//            .sorted { $0.settings.sortLevel < $1.settings.sortLevel }
//
//        let lastSortLevel = oldBalances.last?.settings.sortLevel ?? 0
//
//        for (index, balance) in newBalances.enumerated() {
//
//            let assetId = balance.assetId
//            let sortLevel = lastSortLevel + Float(index)
//            let isFavorite: Bool = balance.asset.isWaves
//
//            var newBalance = balance
//            newBalance.settings = DomainLayer.DTO.SmartAssetBalance.Settings(assetId: assetId,
//                                                                        sortLevel: sortLevel,
//                                                                        isHidden: false,
//                                                                        isFavorite: isFavorite)
//            newBalances[index] = newBalance
//        }
//
//        var newList = newBalances
//        newList.append(contentsOf: oldBalances)
//        newList = newList.sorted { $0.settings.sortLevel < $1.settings.sortLevel }
//
//        return newList
//    }
//}

// MARK: Mapper

private extension DomainLayer.DTO.AssetBalance {

    init(info: Environment.AssetInfo) {
        self.assetId = info.assetId
        self.totalBalance = 0
        self.leasedBalance = 0
        self.inOrderBalance = 0
        self.modified = Date()
    }
}
