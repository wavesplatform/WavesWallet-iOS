//
//  TokenBurnInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtension
import WavesSDKCrypto

protocol TokenBurnInteractorProtocol {
    func getWavesBalance() -> Observable<Money>
    func getFee(assetID: String) -> Observable<Money>
}

final class TokenBurnInteractor: TokenBurnInteractorProtocol {

    private let account = FactoryInteractors.instance.accountBalance
    private let auth = FactoryInteractors.instance.authorization
    private let transactionInteractor = FactoryInteractors.instance.transactions

    func getWavesBalance() -> Observable<Money> {
        return account.balances().flatMap({ (balances) -> Observable<Money> in

            if let wavesBalance = balances.first(where: {$0.assetId == WavesSDKCryptoConstants.wavesAssetId }) {
                return Observable.just(Money(wavesBalance.availableBalance, wavesBalance.asset.precision))
            }
            return Observable.empty()
        })
    }
    
    func getFee(assetID: String) -> Observable<Money> {
        return auth.authorizedWallet().flatMap { [weak self] (wallet) -> Observable<Money>  in
            guard let self = self else { return Observable.empty() }
            return self.transactionInteractor.calculateFee(by: .burn(assetID: assetID), accountAddress: wallet.address)
        }
    }

}
