//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class WalletInteractor: WalletInteractorProtocol {
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = AccountBalanceInteractor()
    private let leasingInteractor: LeasingInteractorProtocol = LeasingInteractor()

    func assets() -> AsyncObservable<[WalletTypes.DTO.Asset]> {

        return accountBalanceInteractor
            .balances()
            .map { $0.filter { $0.asset != nil } }
            .map {
                $0.map { balance -> WalletTypes.DTO.Asset in
                    WalletTypes.DTO.Asset.map(from: balance)
                }
            }
    }

    func leasing() -> AsyncObservable<WalletTypes.DTO.Leasing> {
        guard let wallet = WalletManager.currentWallet else { return Observable.empty() }

        return activeLeasingTransactions(by: wallet.address)
            .map { leasing -> WalletTypes.DTO.Leasing in

                let precision = leasing.balance.asset!.precision
                let inTransactions = leasing.transaction.filter { $0.sender != wallet.address }
                let myTransactions = leasing.transaction.filter { $0.sender == wallet.address }

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
                let avaliableMoney: Money = .init(balance.balance - balance.reserveBalance,
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


    func refreshAssets() {
        accountBalanceInteractor.updateBalances()
    }

    func refreshLeasing() {
        accountBalanceInteractor.updateBalances()
        leasingInteractor.updateActiveLeasingTransactions()
    }
}

fileprivate extension WalletInteractor {
    func activeLeasingTransactions(by accountAddress: String) -> AsyncObservable<DomainLayer.DTO.Leasing> {
        let transactions = leasingInteractor.activeLeasingTransactions(by: accountAddress)

        let balance = accountBalanceInteractor
            .balances()
            .map { $0.first { $0.assetId == Environments.Constants.wavesAssetId } }
            .flatMap { balance -> Observable<AssetBalance> in
                guard let balance = balance else { return Observable.empty() }
                return Observable.just(balance)
            }

        return Observable
            .zip(transactions, balance)
            .map { transactions, balance -> DomainLayer.DTO.Leasing in
                DomainLayer.DTO.Leasing(balance: balance,
                                        transaction: transactions)
            }
    }
}

fileprivate extension WalletTypes.DTO.Asset {
    static func map(from balance: AssetBalance) -> WalletTypes.DTO.Asset {
        // TODO: Remove !
        let asset = balance.asset!
        let settings = balance.settings!

        let id = balance.assetId
        let name = asset.name
        let balanceToken = Money(balance.avaliableBalance, Int(asset.precision))
        let level = settings.sortLevel
        // TODO: Fiat money
        let fiatBalance = Money(100, 1)
        var state: WalletTypes.DTO.Asset.Kind = .general

        if asset.isGeneral {
            state = .general
        }

        if settings.isHidden {
            state = .hidden
        }

        if asset.isSpam {
            state = .spam
        }

        return WalletTypes.DTO.Asset(id: id,
                                     name: name,
                                     balance: balanceToken,
                                     fiatBalance: fiatBalance,
                                     isMyAsset: asset.isMyAsset,
                                     isFavorite: settings.isFavorite,
                                     isFiat: asset.isFiat,
                                     isGateway: asset.isGateway,
                                     isWaves: asset.isWaves,
                                     kind: state,
                                     sortLevel: level)
    }
}
