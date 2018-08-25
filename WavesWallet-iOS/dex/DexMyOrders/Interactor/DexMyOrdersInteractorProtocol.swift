//
//  DexMyOrdersInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexMyOrdersInteractorProtocol {
    
    func myOrders() -> Observable<([DexMyOrders.DTO.Order])>
    func deleteOrder(order: DexMyOrders.DTO.Order)
}
