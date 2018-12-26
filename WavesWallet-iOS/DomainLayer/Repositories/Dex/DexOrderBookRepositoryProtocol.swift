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
    
    func orderBook(amountAsset: String, priceAsset: String) -> Observable<Matcher.DTO.OrderBook>
    
    func markets(isEnableSpam: Bool) -> Observable<[Matcher.DTO.Market]>

    func myOrders(amountAsset: String, priceAsset: String) -> Observable<[Matcher.DTO.Order]>

    func cancelOrder(amountAsset: String, priceAsset: String) -> Observable<Bool>
}
