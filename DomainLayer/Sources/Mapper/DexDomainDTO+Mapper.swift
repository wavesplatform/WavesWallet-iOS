//
//  DexDomainDTO+Mapper.swift
//  DomainLayer
//
//  Created by Pavel Gubin on 20.12.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

private extension DomainLayer.DTO.Dex.Asset {

    var ticker: String? {
        if name == shortName {
            return nil
        } else {
            return shortName
        }
    }

    func balance(_ amount: Int64) -> Balance {
        return balance(amount, precision: decimals)
    }

    func balance(_ amount: Int64, precision: Int) -> Balance {
        return Balance(currency: .init(title: name, ticker: ticker), money: money(amount, precision: precision))
    }

    func money(_ amount: Int64, precision: Int) -> Money {
        return .init(amount, precision)
    }

    func money(_ amount: Int64) -> Money {
        return money(amount, precision: decimals)
    }
}

private extension DomainLayer.DTO.Dex.MyOrder {
    
    var precisionDifference: Int {
        return (priceAsset.decimals - amountAsset.decimals) + 8
    }

    func priceBalance(_ amount: Int64) -> Balance {
        return priceAsset.balance(amount, precision: precisionDifference)
    }

    func amountBalance(_ amount: Int64) -> Balance {
        return amountAsset.balance(amount)
    }

    func totalBalance(priceAmount: Int64, assetAmount: Int64) -> Balance {

        let priceA = Decimal(priceAmount) / pow(10, priceAsset.decimals)
        let assetA = Decimal(assetAmount) / pow(10, amountAsset.decimals)

        let amountA = (priceA * assetA) * pow(10, priceAsset.decimals)

        return priceAsset.balance(amountA.int64Value, precision: priceAsset.decimals)
    }
}

public extension DomainLayer.DTO.Dex.MyOrder {

    var filledBalance: Balance {
        return .init(currency: .init(title: amountAsset.name, ticker: amountAsset.ticker), money: self.filled)
    }

    var priceBalance: Balance {
        return .init(currency: .init(title: priceAsset.name, ticker: priceAsset.ticker), money: self.price)
    }

    var amountBalance: Balance {
        return .init(currency: .init(title: amountAsset.name, ticker: amountAsset.ticker), money: self.amount)
    }

    var totalBalance: Balance {
        return self.totalBalance(priceAmount: self.price.amount, assetAmount: self.amount.amount)
    }
}
