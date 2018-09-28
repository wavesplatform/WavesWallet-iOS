//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private struct Leasing {
    let balance: DomainLayer.DTO.AssetBalance
    let transaction: [DomainLayer.DTO.LeaseTransaction]
    let walletAddress: String
}

final class WalletInteractor: WalletInteractorProtocol {

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
    private let accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol = FactoryRepositories.instance.accountBalanceRepositoryLocal

    private let leasingInteractor: LeasingInteractorProtocol = FactoryInteractors.instance.leasingInteractor

    private let refreshAssetsSubject: PublishSubject<[WalletTypes.DTO.Asset]> = PublishSubject<[WalletTypes.DTO.Asset]>()
    private let refreshLeasingSubject: PublishSubject<WalletTypes.DTO.Leasing> = PublishSubject<WalletTypes.DTO.Leasing>()

    private let disposeBag: DisposeBag = DisposeBag()

    func assets() -> AsyncObservable<[WalletTypes.DTO.Asset]> {

        let listener = accountBalanceRepositoryLocal.listenerOfUpdatedBalances.subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .throttle(1, scheduler: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))

        return Observable.merge(assets(isNeedUpdate: false),
                                refreshAssetsSubject.asObserver(),
                                mapAssets(listener))
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func leasing() -> AsyncObservable<WalletTypes.DTO.Leasing> {

        return Observable.merge(leasing(isNeedUpdate: false),
                                refreshLeasingSubject.asObserver())
    }

    func refreshAssets() {
        assets(isNeedUpdate: true)
            .take(1)
            .subscribe(weak: self, onNext: { owner, balances in
                owner.refreshAssetsSubject.onNext(balances)
            })
            .disposed(by: disposeBag)
    }

    func refreshLeasing() {
        leasing(isNeedUpdate: true)
            .take(1)            
            .subscribe(weak: self, onNext: { owner, leasing in
                owner.refreshLeasingSubject.onNext(leasing)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Assistants

fileprivate extension WalletInteractor {

    func mapAssets(_ observable: AsyncObservable<[DomainLayer.DTO.AssetBalance]>) -> AsyncObservable<[WalletTypes.DTO.Asset]> {
        return observable.map { $0.filter { $0.asset != nil || $0.settings != nil } }
            .map {
                $0.map { balance -> WalletTypes.DTO.Asset in
                    WalletTypes.DTO.Asset.map(from: balance)
                }
            }
    }

    func assets(isNeedUpdate: Bool) -> AsyncObservable<[WalletTypes.DTO.Asset]> {

        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> AsyncObservable<[WalletTypes.DTO.Asset]> in
                guard let owner = self else { return Observable.never() }
                return owner.mapAssets(owner.accountBalanceInteractor.balances(by: wallet, isNeedUpdate: isNeedUpdate))
            })
    }

    func leasing(isNeedUpdate: Bool) -> AsyncObservable<WalletTypes.DTO.Leasing> {

        let collection = authorizationInteractor
            .authorizedWallet()
            .flatMap(weak: self) { owner, wallet -> AsyncObservable<Leasing> in
                
                let transactions = owner.leasingInteractor.activeLeasingTransactions(by: wallet.wallet.address,
                                                                                     isNeedUpdate: isNeedUpdate)
                let balance = owner.accountBalanceInteractor
                    .balances(by: wallet,
                              isNeedUpdate: isNeedUpdate)
                    .map { $0.first { $0.asset?.isWaves == true } }
                    .flatMap { balance -> Observable<DomainLayer.DTO.AssetBalance> in
                        guard let balance = balance else { return Observable.empty() }
                        return Observable.just(balance)
                    }
                return Observable.zip(transactions, balance)
                    .map { transactions, balance -> Leasing in
                        Leasing(balance: balance,
                                transaction: transactions,
                                walletAddress: wallet.wallet.address)
                    }
            }


        return collection
            .map { leasing -> WalletTypes.DTO.Leasing in

                let precision = leasing.balance.asset!.precision
                let inTransactions = leasing.transaction.filter { $0.sender != leasing.walletAddress }
                let myTransactions = leasing.transaction.filter { $0.sender == leasing.walletAddress }

                let leaseAmount: Int64 = myTransactions
                    .reduce(0) { $0 + $1.amount }
                let leaseInAmount: Int64 = inTransactions
                    .reduce(0) { $0 + $1.amount }

                let transaction: [WalletTypes.DTO.Leasing.Transaction] = myTransactions
                    .map { .init(id: $0.id,
                                 balance: .init($0.amount,
                                                precision)) }

                let balance = leasing.balance
                let totalMoney: Money = .init(balance.balance,
                                              precision)
                let avaliableMoney: Money = .init(balance.balance - balance.inOrderBalance,
                                                  precision)
                let leasedMoney: Money = .init(leaseAmount,
                                               precision)
                let leasedInMoney: Money = .init(leaseInAmount,
                                                 precision)

                let leasingBalance: WalletTypes
                    .DTO
                    .Leasing
                    .Balance = .init(totalMoney: totalMoney,
                                     avaliableMoney: avaliableMoney,
                                     leasedMoney: leasedMoney,
                                     leasedInMoney: leasedInMoney)

                return WalletTypes.DTO.Leasing(balance: leasingBalance,
                                               transactions: transaction)
            }
    }
}

// MARK: Mappers

fileprivate extension WalletTypes.DTO.Asset {

    static func map(from balance: DomainLayer.DTO.AssetBalance) -> WalletTypes.DTO.Asset {

        let asset = balance.asset!
        let settings = balance.settings!

        let id = balance.assetId
        let name = asset.name
        let balanceToken = Money(balance.avaliableBalance, Int(asset.precision))
        let level = settings.sortLevel
        // TODO: Fiat money
        let fiatBalance = Money(100, 1)

        return WalletTypes.DTO.Asset(id: id,
                                     name: name,
                                     issuer: asset.sender,
                                     description: asset.description,
                                     issueDate: asset.timestamp,
                                     balance: balanceToken,
                                     fiatBalance: fiatBalance,
                                     isReusable: asset.isReusable,
                                     isMyWavesToken: asset.isMyWavesToken,
                                     isWavesToken: asset.isWavesToken,
                                     isWaves: asset.isWaves,
                                     isHidden: settings.isHidden,
                                     isFavorite: settings.isFavorite,
                                     isSpam: asset.isSpam,
                                     isFiat: asset.isFiat,
                                     isGateway: asset.isGateway,                                     
                                     sortLevel: level)
    }
}
