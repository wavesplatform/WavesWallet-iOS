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
        return Balance(currency: .init(title: displayName, ticker: ticker), money: money(amount, precision: precision))
    }

    func money(_ amount: Int64, precision: Int) -> Money {
        return .init(amount, precision)
    }

    func money(_ amount: Int64) -> Money {
        return money(amount, precision: precision)
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

        let price = Decimal(priceAmount) / pow(10, precisionDifference)
        let asset = Decimal(assetAmount) / pow(10, amountAsset.precision)

        let amount = (price * asset) * pow(10, priceAsset.precision)

        return priceAsset.balance(amount.int64Value, precision: priceAsset.precision)
    }
}
