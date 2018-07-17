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
}

final class WalletInteractor: WalletInteractorProtocol {
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = AccountBalanceInteractor()

    func assets() -> AsyncObservable<[WalletTypes.DTO.Asset]> {
        guard let wallet = WalletManager.currentWallet else { return Observable.empty() }
    
        return accountBalanceInteractor
            .balanceBy(accountId: wallet.address)
            .map { $0.filter { $0.asset != nil } }
            .map {
                $0.map { balance -> WalletTypes.DTO.Asset in
                    WalletTypes.DTO.Asset.mapFrom(balance: balance)
                }
            }
    }
}

fileprivate extension WalletTypes.DTO.Asset {
//    let id: String
//    let name: String
//    let balance: Money
//    let fiatBalance: Money
//    //        let king: Kind
//    let state: State
//    let level: Float
//    enum State: Hashable {
//        case none
//        case general
//        case favorite
//        case hidden
//        case spam
//    }
    static func mapFrom(balance: AssetBalance) -> WalletTypes.DTO.Asset {
        let asset = balance.asset!
        let id = balance.assetId
        let name = asset.name
        let balanceToken = Money(balance.balance, Int(asset.precision))
        let level = balance.level
        let fiatBalance = Money(100, 1)
        var state: WalletTypes.DTO.Asset.State!
        if balance.isGeneral {
            state = .general
        }
        if balance.isFavorite {
            state = .favorite
        }
        if balance.isHidden {
            state = .hidden
        }
        if asset.isSpam {
            state = .spam
        }
        return WalletTypes.DTO.Asset(id: id,
                                     name: name,
                                     balance: balanceToken,
                                     fiatBalance: fiatBalance,
                                     state: state,
                                     level: level)
    }
}
