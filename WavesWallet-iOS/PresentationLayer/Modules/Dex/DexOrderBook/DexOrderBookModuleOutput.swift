//
//  DexOrderBookModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexOrderBookModuleOutput: AnyObject {
    
    func didCreateOrder(_ bidAsk: DexOrderBook.DTO.BidAsk, amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset,
                        ask: Money?, bid: Money?, last: Money?,
                        availableAmountAssetBalance: Money,
                        availablePriceAssetBalance: Money,
                        availableWavesBalance: Money,
                        inputMaxAmount: Bool,
                        scriptedAssets: [DomainLayer.DTO.Asset])

    func didCreateEmptyOrder(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset,
                             orderType: DomainLayer.DTO.Dex.OrderType,
                             ask: Money?, bid: Money?, last: Money?,
                             availableAmountAssetBalance: Money,
                             availablePriceAssetBalance: Money,
                             availableWavesBalance: Money,
                             scriptedAssets: [DomainLayer.DTO.Asset])
}
