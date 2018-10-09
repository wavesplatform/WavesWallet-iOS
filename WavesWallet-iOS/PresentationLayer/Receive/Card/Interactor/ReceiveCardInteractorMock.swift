//
//  ReceiveCardInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class ReceiveCardInteractorMock: ReceiveCardInteractorProtocol {
 
    private let disposeBag = DisposeBag()
    
    private func getWavesBalance() -> Observable<DomainLayer.DTO.AssetBalance> {
    
        let accountBalance = FactoryInteractors.instance.accountBalance
        return accountBalance.balances(isNeedUpdate: true)
            .flatMap({ balances -> Observable<DomainLayer.DTO.AssetBalance> in
                
                guard let wavesAsset = balances.first(where: {$0.asset?.wavesId == Environments.Constants.wavesAssetId}) else {
                    return Observable.empty()
                }
                return Observable.just(wavesAsset)
        })
    }
    
    func getInfo() -> Observable<Responce<ReceiveCard.DTO.Info>> {
        return Observable.create({(subscribe) -> Disposable in
            
            self.getWavesBalance().subscribe(onNext: { (assetBalance) in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    
                    let minimum = Money(10000, 2)
                    let maximum = Money(50000, 2)
                    
                    let info = ReceiveCard.DTO.Info(asset: assetBalance, minimumAmount: minimum, maximumAmount: maximum)
                    
                    subscribe.onNext(Responce(output: info, error: nil))
                })
                
            }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        })
    }
}
