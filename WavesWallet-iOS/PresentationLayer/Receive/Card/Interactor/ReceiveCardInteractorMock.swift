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
 
    func getInfo() -> Observable<Responce<ReceiveCard.DTO.Info>> {
        return Observable.create({ (subscribe) -> Disposable in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                let minimum = Money(10000, 2)
                let maximum = Money(50000, 2)
                
                let info = ReceiveCard.DTO.Info(minimumAmount: minimum, maximumAmount: maximum)
                
                subscribe.onNext(Responce(output: info, error: nil))
            })
            return Disposables.create()
        })
    }
}
