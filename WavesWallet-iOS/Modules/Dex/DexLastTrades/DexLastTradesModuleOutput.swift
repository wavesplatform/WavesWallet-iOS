//
//  DexLastTradesModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Extensions
import DomainLayer

protocol DexLastTradesModuleOutput: AnyObject {
    func didCreateOrder(_ trade: DexLastTrades.DTO.SellBuyTrade,
                        amountAsset: DomainLayer.DTO.Dex.Asset,
                        priceAsset: DomainLayer.DTO.Dex.Asset,
                        availableAmountAssetBalance: Money,
                        availablePriceAssetBalance: Money,
                        availableBalances: [DomainLayer.DTO.SmartAssetBalance],
                        scriptedAssets: [DomainLayer.DTO.Asset])
    
    func didCreateEmptyOrder(amountAsset: DomainLayer.DTO.Dex.Asset,
                             priceAsset: DomainLayer.DTO.Dex.Asset,
                             orderType: DomainLayer.DTO.Dex.OrderType,
                             availableAmountAssetBalance: Money,
                             availablePriceAssetBalance: Money,
                             availableBalances: [DomainLayer.DTO.SmartAssetBalance],
                             scriptedAssets: [DomainLayer.DTO.Asset])
    
}
