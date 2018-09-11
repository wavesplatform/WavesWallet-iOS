//
//  DexLastTradesModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexLastTradesModuleOutput: AnyObject {
    func didCreateOrder(_ trade: DexLastTrades.DTO.SellBuyTrade, priceAsset: DexTraderContainer.DTO.Asset, amountAsset: DexTraderContainer.DTO.Asset)
    func didCreateOrderSellEmpty(priceAsset: DexTraderContainer.DTO.Asset, amountAsset: DexTraderContainer.DTO.Asset)
    func didCreateOrderBuyEmpty(priceAsset: DexTraderContainer.DTO.Asset, amountAsset: DexTraderContainer.DTO.Asset)
}
