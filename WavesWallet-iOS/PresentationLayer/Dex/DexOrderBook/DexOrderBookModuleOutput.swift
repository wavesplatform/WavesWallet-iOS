//
//  DexOrderBookModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexOrderBookModuleOutput: AnyObject {
    
    func didCreateOrder(_ bidAsk: DexOrderBook.DTO.BidAsk, amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset,
                        ask: Money?, bid: Money?, last: Money?,
                        availableAmountAssetBalance: Money, availablePriceAssetBalance: Money)

    func didCreateEmptyOrder(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset,
                             orderType: Dex.DTO.OrderType,
                             ask: Money?, bid: Money?, last: Money?,
                             availableAmountAssetBalance: Money, availablePriceAssetBalance: Money)
}
