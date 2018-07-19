//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol WalletInteractorProtocol {
    func assets() -> AsyncObservable<[WalletTypes.DTO.Asset]>
    func leasing() -> AsyncObservable<WalletTypes.DTO.Leasing>
}

final class WalletInteractor: WalletInteractorProtocol {
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = AccountBalanceInteractor()
    private let leasingInteractor: LeasingInteractorProtocol = LeasingInteractor()

    func assets() -> AsyncObservable<[WalletTypes.DTO.Asset]> {
        guard let wallet = WalletManager.currentWallet else { return Observable.empty() }

        return accountBalanceInteractor
            .balances(by: wallet.address)
            .map { $0.filter { $0.asset != nil } }
            .map {
                $0.map { balance -> WalletTypes.DTO.Asset in
                    WalletTypes.DTO.Asset.map(from: balance)
                }
            }
    }

    func leasing() -> AsyncObservable<WalletTypes.DTO.Leasing> {
        guard let wallet = WalletManager.currentWallet else { return Observable.empty() }

        return leasingInteractor
            .activeLeasingTransactions(by: wallet.address)
            .map { leasing -> WalletTypes.DTO.Leasing in

                let precision = leasing.balance.asset!.precision
                var transactions: [WalletTypes.DTO.Leasing.Transaction] = [WalletTypes.DTO.Leasing.Transaction]()
                var leasedAmount: Int64 = 0
                var leasedInAmount: Int64 = 0
                leasing
                    .transaction
                    .forEach { transaction in
                        let money = Money(transaction.amount,
                                          precision)
                        transactions.append(.init(id: transaction.id, balance: money))
                        let isMyTransaction = transaction.sender == wallet.address

                        if isMyTransaction {
                            leasedAmount += transaction.amount
                        } else {
                            leasedInAmount += transaction.amount
                        }
                    }

                let totalMoney = Money(leasing.balance.balance,
                                       precision)
                let avaliableMoney = Money(leasing.balance.balance,
                                           precision)
                let leasedMoney = Money(leasedAmount,
                                        precision)
                let leasedInMoney = Money(leasedInAmount,
                                          precision)

                let balance: WalletTypes.DTO.Leasing.Balance = .init(totalMoney: totalMoney,
                                                                     avaliableMoney: avaliableMoney,
                                                                     leasedMoney: leasedMoney,
                                                                     leasedInMoney: leasedInMoney)
                return WalletTypes.DTO.Leasing(balance: balance,
                                               transactions: transactions)
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
        let balanceToken = Money(balance.balance, Int(asset.precision))
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
                                     kind: state,
                                     sortLevel: level)
    }
}
