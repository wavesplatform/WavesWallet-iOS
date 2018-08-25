//
//  DexMyOrdersInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexMyOrdersInteractor: DexMyOrdersInteractorProtocol {
    
    func myOrders() -> Observable<([DexMyOrders.DTO.Order])> {
        return Observable.empty()
    }
 
    func deleteOrder(order: DexMyOrders.DTO.Order) {
        
    }
}
