//
//  DexOrderBookModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexOrderBookModuleOutput: AnyObject {
    func didTapSell(_ bid: DexOrderBook.DTO.BidAsk)
    func didTapEmptySell()
    func didTapBuy(_ ask: DexOrderBook.DTO.BidAsk)
    func didTapEmptyBuy()
}
