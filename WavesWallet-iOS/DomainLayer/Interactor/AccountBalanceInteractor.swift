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

protocol AccountBalanceInteractorProtocol {
    func balances(by accountId: String) -> Observable<[AssetBalance]>
    func update(balance: AssetBalance) -> Observable<Void>
}

final class AccountBalanceInteractor: AccountBalanceInteractorProtocol {
    private let assetsInteractor: AssetsInteractorProtocol = AssetsInteractor()
    private let assetsProvider: MoyaProvider<Node.Service.Assets> = .init()
    private let addressesProvider: MoyaProvider<Node.Service.Addresses> = .init()
    private let orderBookProvider: MoyaProvider<Matcher.Service.OrderBook> = .init(plugins: [NetworkLoggerPlugin(verbose: true)])
    private let realm = try! Realm()

    func balances(by accountAddress: String) -> Observable<[AssetBalance]> {
        guard let wallet = WalletManager.currentWallet else { return Observable.empty() }

        let assetsBalance = assetsProvider
            .rx
            .request(.getAssetsBalance(accountId: accountAddress))
            .map(Node.DTO.AccountAssetsBalance.self)
            .asObservable()

        let accountBalance = addressesProvider
            .rx
            .request(.getAccountBalance(id: accountAddress))
            .map(Node.DTO.AccountBalance.self)
            .asObservable()

        WalletManager.getPrivateKey()
            .flatMap { self.orderBookProvider
                .rx
                .request(.getOrderHistory($0, isActiveOnly: true)) }
            .subscribe(onNext: { response in

                let res = String(data: response.data, encoding: .utf8)
                print("response \(res)")
            }, onError: { error in
                print("error \(error)")
            })
//
//            .subscribe(onNext: { response in
//
//                print("response \(response)")
//
//                let res = String(data: response.data, encoding: .utf8)
//                print("response \(res)")
//            }) { error in
//                print("error \(error)")
//            }

        let list = Observable
            .zip(assetsBalance, accountBalance)
            .map { assets, account -> [AssetBalance] in

                let assetsBalance = assets.balances.map { AssetBalance(model: $0) }
                let accountBalance = AssetBalance(model: account)

                var list = [AssetBalance]()
                list.append(contentsOf: assetsBalance)
                list.append(accountBalance)

                return list
            }
            .map { balances -> [AssetBalance] in

                let generalBalances = Environments.current.generalAssetIds.map { AssetBalance(model: $0) }
                var newList = balances
                for generalBalance in generalBalances {
                    if balances.contains(where: { $0.assetId == generalBalance.assetId }) == false {
                        newList.append(generalBalance)
                    }
                }
                return newList
            }
            .flatMap(weak: self, selector: { weak, balances -> Observable<[AssetBalance]> in
                let ids = balances.map { $0.assetId }

                return weak.assetsInteractor
                    .assetsBy(ids: ids, accountAddress: accountAddress)
                    .map { (assets) -> [AssetBalance] in
                        balances.forEach { $0.setAssetFrom(list: assets) }
                        return balances
                    }
            })
            .do(weak: self, onNext: { (weak, balances) in

                let ids = balances.map { $0.assetId }

                try? weak.realm.write {
                    let removeBalances = weak.realm
                        .objects(AssetBalance.self)
                        .filter(NSPredicate(format: "NOT (assetId IN %@)", ids))

                    let removeSettings = removeBalances
                        .toArray()
                        .map { $0.settings }
                        .compactMap { $0 }

                    weak.realm.delete(removeBalances)
                    weak.realm.delete(removeSettings)
                    weak.sort(balances: balances)
                    weak.realm.add(balances, update: true)
                }
            })

        return list
    }

    func update(balance: AssetBalance) -> Observable<Void> {
        try? self.realm.write {
            realm.add(balance, update: true)
        }

        return Observable.just(())
    }
}

extension AccountBalanceInteractor {
    func sort(balances: [AssetBalance]) {
//        var settings = try? realm
//            .objects(AssetBalanceSettings.self)
//            .elements
//            .toArray()
        ////            .sorted(by: $0.sortLevel > $1.sortLevel)

        let generalBalances = Environments
            .current
            .generalAssetIds

        let sort = balances.sorted { assetOne, assetTwo -> Bool in

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

        sort.enumerated().forEach { balance in
            print("sort name \(balance.element.asset!.name) \(balance.element.asset!.isGeneral) \(balance.element.asset!.id)")
            let settings = AssetBalanceSettings()
            settings.assetId = balance.element.assetId
            settings.sortLevel = Float(balance.offset)

            if balance.element.assetId == Environments.Constants.wavesAssetId {
                settings.isFavorite = true
            }
            balance.element.settings = settings
        }
    }
}

fileprivate extension AssetBalance {
    fileprivate func setAssetFrom(list: [Asset]) {
        self.asset = list.first { $0.id == self.assetId }
    }
}

fileprivate extension AssetBalance {
    convenience init(model: Environment.AssetInfo) {
        self.init()
        self.assetId = model.assetId
    }

    convenience init(model: Node.DTO.AccountBalance) {
        self.init()
        self.balance = model.balance
        self.assetId = Environments.Constants.wavesAssetId
    }

    convenience init(model: Node.DTO.AssetBalance) {
        self.init()
        self.assetId = model.assetId
        self.balance = model.balance
    }
}
