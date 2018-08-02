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
    func balances() -> Observable<[AssetBalance]>
    func updateBalances()
}

final class AccountBalanceInteractor: AccountBalanceInteractorProtocol {
    
    private let assetsInteractor: AssetsInteractorProtocol = AssetsInteractor()
    private let assetsProvider: MoyaProvider<Node.Service.Assets> = .init()
    private let addressesProvider: MoyaProvider<Node.Service.Addresses> = .init()
    private let matcherBalanceProvider: MoyaProvider<Matcher.Service.Balance> = .init()
    private let leasingInteractor: LeasingInteractorProtocol = LeasingInteractor()
    private let disposeBag: DisposeBag = DisposeBag()

    func balances() -> Observable<[AssetBalance]> {

        guard let accountAddress = WalletManager.currentWallet?.address else { return Observable.empty() }

        return remoteBalances(by: accountAddress)
            .do(onNext: { balances in
                let realm = try! Realm()
                self.save(balances: balances, to: realm)
            })
            .observeOn(MainScheduler.asyncInstance)
            .flatMap { balances -> Observable<[AssetBalance]> in
                let realm = try! Realm()
                return Observable
                    .collection(from: realm.objects(AssetBalance.self))
                    .map { $0.toArray() }
                    .debug("BD")
            }
    }

    func updateBalances() {

        guard let accountAddress = WalletManager.currentWallet?.address else { return }

        remoteBalances(by: accountAddress)
            .do(onNext: { [weak self] balances in

                let realm = try! Realm()
                self?.save(balances: balances, to: realm)
            })
            .debug("Refresh")
            .subscribe()
            .disposed(by: disposeBag)
    }
}

fileprivate extension AccountBalanceInteractor {
    func matcherBalances(by accountAddress: String) -> Observable<[String: Int64]> {
        return WalletManager
            .getPrivateKey()
            .flatMap(weak: self, selector: { (owner, privateKey) -> Observable<[String: Int64]> in
                owner.matcherBalanceProvider
                    .rx
                    .request(.getReservedBalances(privateKey))                       
                    .map([String: Int64].self)
                    .asObservable()
                    .catchErrorJustReturn([String: Int64]())
            })
            .catchErrorJustReturn([String: Int64]())
    }

    func assetsBalance(by accountAddress: String) -> Observable<Node.DTO.AccountAssetsBalance> {
        return self.assetsProvider
            .rx
            .request(.getAssetsBalance(accountId: accountAddress))
            .map(Node.DTO.AccountAssetsBalance.self)
            .asObservable()
    }

    func accountBalance(by accountAddress: String) -> Observable<Node.DTO.AccountBalance> {
        return self.addressesProvider
            .rx
            .request(.getAccountBalance(id: accountAddress))
            .map(Node.DTO.AccountBalance.self)
            .asObservable()
    }
}

private extension AccountBalanceInteractor {

    func save(balances: [AssetBalance], to realm: Realm) {
        let ids = balances.map { $0.assetId }
        try? realm.write {
            let removeBalances = realm
                .objects(AssetBalance.self)
                .filter(NSPredicate(format: "NOT (assetId IN %@)", ids))

            let removeSettings = removeBalances
                .toArray()
                .map { $0.settings }
                .compactMap { $0 }

            realm.delete(removeBalances)
            realm.delete(removeSettings)

            balances.forEach({ balance in
                balance.settings = realm.object(ofType: AssetBalanceSettings.self,
                                                forPrimaryKey: balance.assetId)
            })
            setupSettings(balances: balances)
            realm.add(balances, update: true)
        }
    }

    func remoteBalances(by accountAddress: String) -> Observable<[AssetBalance]> {

        let assetsBalance = self.assetsBalance(by: accountAddress)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
        let accountBalance = self.accountBalance(by: accountAddress)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
        let leasingTransactions = leasingInteractor.activeLeasingTransactions(by: accountAddress)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
        let matcherBalances = self.matcherBalances(by: accountAddress)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))

        let list = Observable
            .zip(assetsBalance, accountBalance, leasingTransactions, matcherBalances)
            .map { AssetBalance.mapToAssetBalances(from: $0.0,
                                                   account: $0.1,
                                                   leasingTransactions: $0.2,
                                                   matcherBalances: $0.3) }
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
        return list.do(onNext: { (_) in
            print("Remote onNext")
        })
    }

    func setupSettings(balances: [AssetBalance]) {

        let generalBalances = Environments
            .current
            .generalAssetIds

        let newBalances = balances.filter { $0.settings == nil }

        let sort = newBalances.sorted { assetOne, assetTwo -> Bool in

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
            .sorted(by: { $0.settings.sortLevel < $1.settings.sortLevel })

        let lastSortLevel = oldBalances.last?.settings.sortLevel ?? 0

        sort.enumerated().forEach { balance in
            
            let settings = AssetBalanceSettings()
            settings.assetId = balance.element.assetId
            settings.sortLevel = lastSortLevel + Float(balance.offset)

            if balance.element.assetId == Environments.Constants.wavesAssetId {
                settings.isFavorite = true
            }
            balance.element.settings = settings
        }
    }
}

private extension AssetBalance {
    func setAssetFrom(list: [Asset]) {
        self.asset = list.first { $0.id == self.assetId }
    }
}

private extension AssetBalance {
    convenience init(model: Environment.AssetInfo) {
        self.init()
        self.assetId = model.assetId
    }

    convenience init(accountBalance: Node.DTO.AccountBalance, transactions: [LeasingTransaction]) {
        self.init()
        self.balance = accountBalance.balance
        self.leasedBalance = transactions
            .filter { $0.sender == accountBalance.address }
            .reduce(0) { $0 + $1.amount }
        self.assetId = Environments.Constants.wavesAssetId
    }

    convenience init(model: Node.DTO.AssetBalance) {
        self.init()
        self.assetId = model.assetId
        self.balance = model.balance
    }

    class func mapToAssetBalances(from assets: Node.DTO.AccountAssetsBalance,
                                  account: Node.DTO.AccountBalance,
                                  leasingTransactions: [LeasingTransaction],
                                  matcherBalances: [String: Int64]) -> [AssetBalance] {
        let assetsBalance = assets.balances.map { AssetBalance(model: $0) }
        let accountBalance = AssetBalance(accountBalance: account,
                                          transactions: leasingTransactions)

        var list = [AssetBalance]()
        list.append(contentsOf: assetsBalance)
        list.append(accountBalance)

        list.forEach { asset in
            guard let balance = matcherBalances[asset.assetId] else { return }
            asset.reserveBalance = balance
        }

        return list
    }
}
