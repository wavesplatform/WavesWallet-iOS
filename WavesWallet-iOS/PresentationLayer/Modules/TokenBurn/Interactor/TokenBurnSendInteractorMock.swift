//
//  TokenBurnLoadingInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class TokenBurnSendInteractorMock: TokenBurnSendInteractorProtocol {
    
    func burnAsset(asset: DomainLayer.DTO.AssetBalance, fee: Money, quiantity: Money) -> Observable<TokenBurnTypes.TransactionStatus> {
        return Observable.create({ (subscribe) -> Disposable in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                subscribe.onNext(TokenBurnTypes.TransactionStatus.success)
            })
            return Disposables.create()
        })
    }
}
