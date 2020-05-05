//
//  DexOrderBookRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public protocol DexOrderBookRepositoryProtocol {
    
    func orderBook(serverEnvironment: ServerEnvironment,
                   amountAsset: String,
                   priceAsset: String) -> Observable<DomainLayer.DTO.Dex.OrderBook>
    
    func markets(serverEnvironment: ServerEnvironment,
                 wallet: DomainLayer.DTO.SignedWallet,
                 pairs: [DomainLayer.DTO.Dex.Pair]) -> Observable<[DomainLayer.DTO.Dex.SmartPair]>
    
    func myOrders(serverEnvironment: ServerEnvironment,
                  wallet: DomainLayer.DTO.SignedWallet,
                  amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset) -> Observable<[DomainLayer.DTO.Dex.MyOrder]>
    
    func allMyOrders(serverEnvironment: ServerEnvironment,
                     wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.Dex.MyOrder]>
    
    func cancelOrder(serverEnvironment: ServerEnvironment,
                     wallet: DomainLayer.DTO.SignedWallet, orderId: String, amountAsset: String, priceAsset: String) -> Observable<Bool>
    
    func cancelAllOrders(serverEnvironment: ServerEnvironment,
                         wallet: DomainLayer.DTO.SignedWallet) -> Observable<Bool>
    
    func createOrder(serverEnvironment: ServerEnvironment,
                     wallet: DomainLayer.DTO.SignedWallet,
                     order: DomainLayer.Query.Dex.CreateOrder, type: DomainLayer.Query.Dex.CreateOrderType) -> Observable<Bool>
    
    func orderSettingsFee(serverEnvironment: ServerEnvironment) -> Observable<DomainLayer.DTO.Dex.SettingsOrderFee>
}
