//
//  DexCreateOrderInteractorProtocolMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexCreateOrderInteractorProtocolMock: DexCreateOrderInteractorProtocol {
    
    func getTotalBalance() -> Observable<(DexCreateOrder.DTO.Balance)> {
        return Observable.just(DexCreateOrder.DTO.Balance(totalMoney: Money(100, 0)))
    }
}
