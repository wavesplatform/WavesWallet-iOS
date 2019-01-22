//
//  TokenBurnLoadingInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class TokenBurnSendInteractor: TokenBurnSendInteractorProtocol {

    private let transactions = FactoryInteractors.instance.transactions
    private let authorization = FactoryInteractors.instance.authorization

    func burnAsset(asset: DomainLayer.DTO.SmartAssetBalance, fee: Money, quiantity: Money) -> Observable<TokenBurnTypes.TransactionStatus> {

        return authorization
            .authorizedWallet()
            .flatMap { [weak self] (wallet) -> Observable<TokenBurnTypes.TransactionStatus> in
                guard let owner = self else { return Observable.never() }

                return owner.transactions
                    .send(by: .burn(BurnTransactionSender.init(assetID: asset.assetId,
                                                               quantity: quiantity.amount,
                                                               fee: fee.amount)),
                          wallet: wallet)
                    .map { _ in TokenBurnTypes.TransactionStatus.success }
            }
    }
}
