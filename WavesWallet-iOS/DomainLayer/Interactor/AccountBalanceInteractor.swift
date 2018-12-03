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
    func balances(isNeedUpdate: Bool) -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func balances(by wallet: DomainLayer.DTO.SignedWallet, isNeedUpdate: Bool) -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
}

final class AccountBalanceInteractor: AccountBalanceInteractorProtocol {
    
    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let balanceRepositoryLocal: AccountBalanceRepositoryProtocol = FactoryRepositories.instance.accountBalanceRepositoryLocal
    private let balanceRepositoryRemote: AccountBalanceRepositoryProtocol = FactoryRepositories.instance.accountBalanceRepositoryRemote
    private let environmentRepository: EnvironmentRepositoryProtocol = FactoryRepositories.instance.environmentRepository

    private let assetsInteractor: AssetsInteractorProtocol = FactoryInteractors.instance.assetsInteractor
    private let leasingInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

    private let disposeBag: DisposeBag = DisposeBag()

    func balances(isNeedUpdate: Bool) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {

        return Observable.never()
//        return authorizationInteractor
//            .authorizedWallet()
//            .flatMap({ [weak self] wallet -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
//                guard let owner = self else { return Observable.never() }
//                return owner.balances(by: wallet, isNeedUpdate: isNeedUpdate)
//            })
    }
    
    func balances(by wallet: DomainLayer.DTO.SignedWallet, isNeedUpdate: Bool) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {

        return Observable.never()
//        return self.balanceRepositoryLocal
//            .balances(by: wallet)
//            .flatMap(weak: self) { owner, balances -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
//
//                let now = Date()
//                let isNeedForceUpdate = balances.count == 0 || balances.first { (now.timeIntervalSinceNow - $0.modified.timeIntervalSinceNow) > Constants.durationInseconds } != nil || isNeedUpdate
//
//                if isNeedForceUpdate {
//                    info("From Remote", type: AssetsInteractor.self)
//                } else {
//                    info("From BD", type: AssetsInteractor.self)
//                }
//                guard isNeedForceUpdate == true else { return Observable.just(balances) }
//
//                return owner.remoteBalances(by: wallet, localBalance: balances, isNeedUpdate: isNeedForceUpdate)
//            }
//            .share()
//            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
    }
}

// MARK: Privet methods

private extension AccountBalanceInteractor {

    private func remoteBalances(by wallet: DomainLayer.DTO.SignedWallet,
                                localBalance: [DomainLayer.DTO.SmartAssetBalance],
                                isNeedUpdate: Bool) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {

        return Observable.never()
//        let walletAddress = wallet.address
//        let balances = balanceRepositoryRemote.balances(by: wallet)
//        let activeTransactions = leasingInteractor.activeLeasingTransactionsSync(by: wallet.address)
//            .flatMap { (txs) -> Observable<[DomainLayer.DTO.SmartTransaction]> in
//
//                switch txs {
//                case .remote(let model):
//                    return Observable.just(model)
//
//                case .local(_, let error):
//                    return Observable.error(error)
//
//                case .error(let error):
//                    return Observable.error(error)
//
//                }
//            }
//
//        let environment = environmentRepository.accountEnvironment(accountAddress: wallet.address)
//
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

    func initialSettings(for balances: [DomainLayer.DTO.SmartAssetBalance]) -> [DomainLayer.DTO.SmartAssetBalance] {

        let generalBalances = Environments
            .current
            .generalAssetIds

        var newBalances = balances
            .filter { $0.settings == nil }
            .sorted { assetOne, assetTwo -> Bool in

                let isGeneralOne = assetOne.asset?.isGeneral ?? false
                let isGeneralTwo = assetTwo.asset?.isGeneral ?? false

                if isGeneralOne == true && isGeneralTwo == true {
                    let indexOne = generalBalances
                        .enumerated()
                        .first(where: { $0.element.assetId == assetOne.assetId })
                        .map { $0.offset }

                    let indexTwo = generalBalances
                        .enumerated()
                        .first(where: { $0.element.assetId == assetTwo.assetId })
                        .map { $0.offset }

                    if let indexOne = indexOne, let indexTwo = indexTwo {
                        return indexOne < indexTwo
                    }
                    return false
                }

                if isGeneralOne {
                    return true
                }
                return false
            }

        let oldBalances = balances
            .filter { $0.settings != nil }
            .sorted { $0.settings!.sortLevel < $1.settings!.sortLevel }

        let lastSortLevel = oldBalances.last?.settings?.sortLevel ?? 0

        for (index, balance) in newBalances.enumerated() {

            let assetId = balance.assetId
            let sortLevel = lastSortLevel + Float(index)
            let isFavorite: Bool = balance.asset?.isWaves ?? false

            var newBalance = balance
            newBalance.settings = DomainLayer.DTO.SmartAssetBalance.Settings(assetId: assetId,
                                                                        sortLevel: sortLevel,
                                                                        isHidden: false,
                                                                        isFavorite: isFavorite)
            newBalances[index] = newBalance
        }

        var newList = newBalances
        newList.append(contentsOf: oldBalances)
        newList = newList.sorted { $0.settings!.sortLevel < $1.settings!.sortLevel }

        return newList
    }
}

// MARK: Mapper

private extension DomainLayer.DTO.SmartAssetBalance {

    init(info: Environment.AssetInfo) {
        self.assetId = info.assetId
        self.totalBalance = 0
        self.leasedBalance = 0
        self.inOrderBalance = 0
        self.settings = nil
        self.asset = nil
        self.modified = Date()
    }
}
