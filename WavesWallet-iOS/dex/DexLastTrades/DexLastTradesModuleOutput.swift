//
//  DexLastTradesModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexLastTradesModuleOutput: AnyObject {
    func didTapSellBuy(_ trade: DexLastTrades.DTO.SellBuyTrade)
    func didTapEmptyBuy()
    func didTapEmptySell()
}
