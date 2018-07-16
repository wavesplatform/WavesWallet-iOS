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
    func assets() -> AsyncObservable<WalletTypes.DTO.Asset>
}

final class WalletInteractor: WalletInteractorProtocol {

    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = AccountBalanceInteractor()

    func assets() -> AsyncObservable<WalletTypes.DTO.Asset> {
        return Observable.never()
    }
}
