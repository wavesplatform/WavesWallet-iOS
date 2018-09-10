//
//  AssetPairDomainLayer+Assistants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 08/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO.Asset {

    func balance(_ amount: Int64) -> Balance {
        return balance(amount, precision: precision)
    }

    func balance(_ amount: Int64, precision: Int) -> Balance {
        return Balance(currency: .init(title: name, ticker: ticker), money: money(amount))
    }

    func money(_ amount: Int64) -> Money {
        return .init(amount, precision)
    }
}

extension DomainLayer.DTO.AssetPair {

    var precisionDifference: Int {
        return (priceAsset.precision - amountAsset.precision) + 8
    }

    func priceBalance(_ amount: Int64) -> Balance {
        return priceAsset.balance(amount, precision: precisionDifference)
    }

    func amountBalance(_ amount: Int64) -> Balance {
        return amountAsset.balance(amount)
    }

    func totalBalance(priceAmount: Int64, assetAmount: Int64) -> Balance {
        return priceAsset.balance(priceAmount + assetAmount, precision: precisionDifference + priceAsset.precision)
    }
}
