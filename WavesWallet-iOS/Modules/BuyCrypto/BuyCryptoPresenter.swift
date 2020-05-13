// 
//  BuyCryptoPresenter.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import RxSwift

final class BuyCryptoPresenter: BuyCryptoPresentable {}

// MARK: - IOTransformer

extension BuyCryptoPresenter: IOTransformer {
    func transform(_ input: BuyCryptoInteractorOutput) -> BuyCryptoPresenterOutput {
        return BuyCryptoPresenterOutput()
    }
}
