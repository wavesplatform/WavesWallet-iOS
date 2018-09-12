//
//  DexOrderBookModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexOrderBookModuleOutput: AnyObject {
    func didCreateOrder(_ bidAsk: DexOrderBook.DTO.BidAsk, amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset)
    func didCreateOrderSellEmpty(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset)
    func didCreateOrderBuyEmpty(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset)
}
