//
//  DexMyOrders+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/14/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import DomainLayer
import Extensions

extension DomainLayer.DTO.Dex.MyOrder {
    
    init(_ model: MatcherService.DTO.Order, priceAsset: DomainLayer.DTO.Dex.Asset, amountAsset: DomainLayer.DTO.Dex.Asset) {
        
        let price = Money.price(amount: model.price, amountDecimals: amountAsset.decimals, priceDecimals: priceAsset.decimals)
        
        let amount = Money(model.amount, amountAsset.decimals)
        
        let filled = Money(model.filled, amountAsset.decimals)
        
        var status: DomainLayer.DTO.Dex.MyOrder.Status!
        
        if model.status == .Accepted {
            status = .accepted
        } else if model.status == .PartiallyFilled {
            status = .partiallyFilled
        } else if model.status == .Filled {
            status = .filled
        } else {
            status = .cancelled
        }
        
        var type: DomainLayer.DTO.Dex.OrderType!
        
        if model.type == .sell {
            type = DomainLayer.DTO.Dex.OrderType.sell
        } else {
            type = DomainLayer.DTO.Dex.OrderType.buy
        }
        
        let percentFilled = status == .filled ? 100 : Int(filled.amount * 100 / amount.amount)
        
        self.init(id: model.id,
                  time: model.timestamp,
                  status: status,
                  price: price,
                  amount: amount,
                  filled: filled,
                  type: type,
                  amountAsset: amountAsset,
                  priceAsset: priceAsset,
                  percentFilled: percentFilled,
                  fee: model.fee,
                  feeAsset: model.feeAsset)
    }
}
    
