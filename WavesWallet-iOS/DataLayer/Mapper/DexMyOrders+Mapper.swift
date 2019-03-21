//
//  DexMyOrders+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/14/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation


extension DomainLayer.DTO.Dex.MyOrder {
    
    init(_ model: Matcher.DTO.Order, priceAsset: DomainLayer.DTO.Dex.Asset, amountAsset: DomainLayer.DTO.Dex.Asset) {
        
        id = model.id
        
        price = Money.price(amount: model.price, amountDecimals: amountAsset.decimals, priceDecimals: priceAsset.decimals)
        
        amount = Money(model.amount, amountAsset.decimals)
        time = model.timestamp
        filled = Money(model.filled, amountAsset.decimals)
        
        if model.status == .Accepted {
            status = .accepted
        }
        else if model.status == .PartiallyFilled {
            status = .partiallyFilled
        }
        else if model.status == .Filled {
            status = .filled
        }
        else {
            status = .cancelled
        }
        
        if model.type == .sell {
            type = .sell
        }
        else {
            type = .buy
        }
        
        self.amountAsset = amountAsset
        self.priceAsset = priceAsset
        percentFilled = Int(filled.amount * 100 / amount.amount)
    }
}
