//
//  TokenBurnLoadingInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtension

final class TokenBurnSendInteractor: TokenBurnSendInteractorProtocol {

    private let transactions = FactoryInteractors.instance.transactions
    private let authorization = FactoryInteractors.instance.authorization

    func burnAsset(asset: DomainLayer.DTO.SmartAssetBalance, fee: Money, quiantity: Money) -> Observable<TokenBurnTypes.TransactionStatus> {

        return authorization
            .authorizedWallet()
            .flatMap { [weak self] (wallet) -> Observable<TokenBurnTypes.TransactionStatus> in
                guard let self = self else { return Observable.never() }

                return self.transactions
                    .send(by: .burn(BurnTransactionSender.init(assetID: asset.assetId,
                                                               quantity: quiantity.amount,
                                                               fee: fee.amount)),
                          wallet: wallet)
                    .map { _ in TokenBurnTypes.TransactionStatus.success }
            }
            .catchError( { Observable.just(TokenBurnTypes.TransactionStatus.error($0)) })
    }
    
    func getFee(assetID: String) -> Observable<Money> {
        return authorization.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<Money> in
            guard let self = self else { return Observable.empty() }
            return self.transactions.calculateFee(by: .burn(assetID: assetID), accountAddress: wallet.address)
        })
    }
}
