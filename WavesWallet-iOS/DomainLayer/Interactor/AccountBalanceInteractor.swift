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

    func balanceBy(accountId: String) -> Observable<[AssetBalance]>
    func update(balance: AssetBalance) -> Observable<Void>
}

final class AccountBalanceInteractor: AccountBalanceInteractorProtocol {
    private let assetsInteractor: AssetsInteractorProtocol = AssetsInteractor()
    private let assetsProvider: MoyaProvider<Node.Service.Assets> = MoyaProvider<Node.Service.Assets>()
    private let addressesProvider: MoyaProvider<Node.Service.Addresses> = MoyaProvider<Node.Service.Addresses>()
    private let realm = try! Realm()

    func balanceBy(accountId: String) -> Observable<[AssetBalance]> {
        let assetsBalance = assetsProvider
            .rx
            .request(.getAssetsBalance(accountId: accountId))
            .map(Node.Model.AccountAssetsBalance.self).asObservable()

        let accountBalance = addressesProvider
            .rx
            .request(.getAccountBalance(id: accountId))
            .map(Node.Model.AccountBalance.self).asObservable()

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
                    guard balances.contains(where: { $0.assetId == generalBalance.assetId }) == false else { continue }
                    newList.append(generalBalance)
                }
                return newList
            }
            .flatMap(weak: self, selector: { weak, balances -> Observable<[AssetBalance]> in
                let ids = balances.map { $0.assetId }

                return weak.assetsInteractor
                    .assetsBy(ids: ids)
                    .map { (assets) -> [AssetBalance] in
                        balances.forEach { $0.setAssetFrom(list: assets) }
                        return balances
                    }
            })
            .do(weak: self, onNext: { weak, balances in
                try? weak.realm.write {
                    weak.realm.add(balances, update: true)
                }
            })

        return list.delay(10, scheduler: MainScheduler.asyncInstance)
    }

    func update(balance: AssetBalance) -> Observable<Void> {

        try? realm.write {
            realm.add(balance, update: true)
        }
        
        return Observable.just(())
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

    convenience init(model: Node.Model.AccountBalance) {
        self.init()
        self.balance = model.balance
        self.assetId = Environments.Constants.wavesAssetId
    }

    convenience init(model: Node.Model.AssetBalance) {
        self.init()
        self.assetId = model.assetId
        self.balance = model.balance
    }
}
