//
//  DexCreateOrderInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer
import Extensions

protocol DexCreateOrderInteractorProtocol {
    
    func createOrder(order: DexCreateOrder.DTO.Order) -> Observable<ResponseType<DexCreateOrder.DTO.Output>>

    func getFee(amountAsset: String, priceAsset: String, feeAssetId: String) -> Observable<DexCreateOrder.DTO.FeeSettings>    
    // DexCreateOrder.Error
    func isValidOrder(order: DexCreateOrder.DTO.Order) -> Observable<Bool>
}
