//
//  DexCreateOrderInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer
import Extensions

protocol DexCreateOrderInteractorProtocol {
    
    func createOrder(order: DexCreateOrder.DTO.Order, type: DexCreateOrder.DTO.CreateOrderType) -> Observable<ResponseType<DexCreateOrder.DTO.Output>>

    func getFee(amountAsset: String, priceAsset: String, feeAssetId: String) -> Observable<DexCreateOrder.DTO.FeeSettings>    
    // DexCreateOrder.Error
    func isValidOrder(order: DexCreateOrder.DTO.Order) -> Observable<Bool>
    
    func calculateMarketOrderPrice(amountAsset: DomainLayer.DTO.Dex.Asset,
                                   priceAsset: DomainLayer.DTO.Dex.Asset,
                                   orderAmount: Money,
                                   type: DomainLayer.DTO.Dex.OrderType) -> Observable<DexCreateOrder.DTO.MarketOrder>
}
