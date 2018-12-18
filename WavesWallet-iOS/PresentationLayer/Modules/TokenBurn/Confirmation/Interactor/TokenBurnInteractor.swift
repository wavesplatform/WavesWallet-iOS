//
//  TokenBurnInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol TokenBurnInteractorProtocol {
    func getWavesBalance() -> Observable<Money>
}

final class TokenBurnInteractor: TokenBurnInteractorProtocol {

    private let account = FactoryInteractors.instance.accountBalance
    
    func getWavesBalance() -> Observable<Money> {
        return account.balances().flatMap({ (balances) -> Observable<Money> in

            if let wavesBalance = balances.first(where: {$0.assetId == GlobalConstants.wavesAssetId }) {
                return Observable.just(Money(wavesBalance.avaliableBalance, wavesBalance.asset.precision))
            }
            return Observable.empty()
        })
    }
}
