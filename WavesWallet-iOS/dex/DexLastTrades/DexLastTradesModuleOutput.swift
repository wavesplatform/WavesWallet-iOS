//
//  DexLastTradesModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexLastTradesModuleOutput: AnyObject {
    func didCreateOrder(_ trade: DexLastTrades.DTO.SellBuyTrade, amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset)
    func didCreateOrderSellEmpty(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset)
    func didCreateOrderBuyEmpty(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset)
}
