//
//  DexOrderBookRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexOrderBookRepositoryProtocol {
    
    func orderBook(wallet: DomainLayer.DTO.SignedWallet, amountAsset: String, priceAsset: String) -> Observable<DomainLayer.DTO.Dex.OrderBook>
    
    func markets(wallet: DomainLayer.DTO.SignedWallet, isEnableSpam: Bool) -> Observable<[DomainLayer.DTO.Dex.SmartPair]>

    func myOrders(wallet: DomainLayer.DTO.SignedWallet, amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset) -> Observable<[DomainLayer.DTO.Dex.MyOrder]>

    func cancelOrder(wallet: DomainLayer.DTO.SignedWallet, orderId: String, amountAsset: String, priceAsset: String) -> Observable<Bool>

    func createOrder(wallet: DomainLayer.DTO.SignedWallet, order: DomainLayer.Query.Dex.CreateOrder) -> Observable<Bool>
}
