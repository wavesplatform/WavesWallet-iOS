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
    let balance: DomainLayer.DTO.SmartAssetBalance
    let transaction: [DomainLayer.DTO.SmartTransaction]
    let walletAddress: String
}

final class WalletInteractor: WalletInteractorProtocol {

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
    private let accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol = FactoryRepositories.instance.accountBalanceRepositoryLocal

    private let leasingInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

//    private let refreshAssetsSubject: PublishSubject<[WalletTypes.DTO.Asset]> = PublishSubject<[WalletTypes.DTO.Asset]>()
//    private let refreshLeasingSubject: PublishSubject<WalletTypes.DTO.Leasing> = PublishSubject<WalletTypes.DTO.Leasing>()

    private let disposeBag: DisposeBag = DisposeBag()

    func assets() -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {

        return assets(isNeedUpdate: true)
    }

    func leasing() -> Observable<WalletTypes.DTO.Leasing> {

        return Observable.merge(leasing(isNeedUpdate: true))
    }
}

// MARK: Assistants

fileprivate extension WalletInteractor {

    func mapAssets(_ observable: Observable<[DomainLayer.DTO.SmartAssetBalance]>) -> Observable<[WalletTypes.DTO.Asset]> {
        return observable
            .map { $0.filter { $0.asset != nil || $0.settings != nil } }
            .map {
                $0.map { balance -> WalletTypes.DTO.Asset in
                    WalletTypes.DTO.Asset.map(from: balance)
                }
            }
    }

    func assets(isNeedUpdate: Bool) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {

        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let owner = self else { return Observable.never() }
                return owner.accountBalanceInteractor.balances(by: wallet, isNeedUpdate: isNeedUpdate)
            })
    }

    func leasing(isNeedUpdate: Bool) -> Observable<WalletTypes.DTO.Leasing> {

        let collection = authorizationInteractor
            .authorizedWallet()
            .flatMap(weak: self) { owner, wallet -> Observable<Leasing> in
                
                let transactions = owner.leasingInteractor.activeLeasingTransactionsSync(by: wallet.address)
                    .flatMap { (txs) -> Observable<[DomainLayer.DTO.SmartTransaction]> in
                        return Observable.just(txs.resultIngoreError ?? [])
                    }

                let balance = owner.accountBalanceInteractor
                    .balances(by: wallet,
                              isNeedUpdate: isNeedUpdate)
                    .map { $0.first { $0.asset.isWaves == true } }
                    .flatMap { balance -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                        guard let balance = balance else { return Observable.empty() }
                        return Observable.just(balance)
                    }
                return Observable.zip(transactions, balance)
                    .map { transactions, balance -> Leasing in
                        Leasing(balance: balance,
                                transaction: transactions,
                                walletAddress: wallet.address)
                    }
            }


        return collection
            .map { leasing -> WalletTypes.DTO.Leasing in

                let precision = leasing.balance.asset.precision

                let incomingLeasingTxs = leasing.transaction.map { tx -> DomainLayer.DTO.SmartTransaction.Leasing? in
                    if case .incomingLeasing(let leasing) = tx.kind {
                        return leasing
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }

                let startedLeasingTxsBase = leasing.transaction.map { tx -> DomainLayer.DTO.SmartTransaction? in
                    if case .startedLeasing = tx.kind {
                        return tx
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }

                let startedLeasingTxs = startedLeasingTxsBase.map { tx -> DomainLayer.DTO.SmartTransaction.Leasing? in
                    if case .startedLeasing(let leasing) = tx.kind {
                        return leasing
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }

                let leaseAmount: Int64 = startedLeasingTxs
                    .reduce(0) { $0 + $1.balance.money.amount }
                let leaseInAmount: Int64 = incomingLeasingTxs
                    .reduce(0) { $0 + $1.balance.money.amount }

                let balance = leasing.balance
                let totalMoney: Money = .init(balance.totalBalance,
                                              precision)
                let avaliableMoney: Money = .init(balance.avaliableBalance,
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
                                               transactions: startedLeasingTxsBase)
            }
    }
}

// MARK: Mappers

fileprivate extension WalletTypes.DTO.Asset {

    static func map(from balance: DomainLayer.DTO.SmartAssetBalance) -> WalletTypes.DTO.Asset {

        let asset = balance.asset
        let settings = balance.settings

        let id = balance.assetId
        let name = asset.displayName
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
                                     sortLevel: level,
                                     icon: asset.icon,
                                     assetBalance: balance)
    }
}
