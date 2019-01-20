//
//  DexCreateOrderInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexCreateOrderInteractorProtocol {
    func createOrder(order: DexCreateOrder.DTO.Order) -> Observable<ResponseType<DexCreateOrder.DTO.Output>>
}
