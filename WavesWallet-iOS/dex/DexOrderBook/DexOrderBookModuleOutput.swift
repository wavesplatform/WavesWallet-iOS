//
//  DexOrderBookModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexOrderBookModuleOutput: AnyObject {
    func didCreateOrder(_ bidAsk: DexOrderBook.DTO.BidAsk, priceAsset: Dex.DTO.Asset, amountAsset: Dex.DTO.Asset)
    func didCreateOrderSellEmpty(priceAsset: Dex.DTO.Asset, amountAsset: Dex.DTO.Asset)
    func didCreateOrderBuyEmpty(priceAsset: Dex.DTO.Asset, amountAsset: Dex.DTO.Asset)
}
