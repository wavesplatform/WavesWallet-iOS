//
//  StartLeasingInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class StartLeasingInteractorMock: StartLeasingInteractorProtocol {
    
    func createOrder(order: StartLeasing.DTO.Order) -> Observable<(Response<Bool>)> {
        
        
        return Observable.create({ (subscribe) -> Disposable in

            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                subscribe.onNext(Response<Bool>(output: true, error: nil))
            })
            return Disposables.create()
        })
    }
}
