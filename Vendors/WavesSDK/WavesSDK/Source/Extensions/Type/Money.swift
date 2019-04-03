//
//  Money.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public struct Money: Hashable, Codable {
    let amount: Int64
    let decimals: Int
    
    private(set) var isBigAmount = false
    private(set) var isSmallAmount = false

    init(_ amount: Int64, _ decimals: Int) {
        self.amount = amount
        self.decimals = decimals
    }
}

public extension Money {
 
    init(value: Decimal, _ decimals: Int) {
        let decimalValue = (value * pow(10, decimals)).rounded()
        let isValidDecimal = Decimal(Int64.max) >= decimalValue
        
        self.amount = isValidDecimal ? Int64(truncating: decimalValue as NSNumber) : 0
        self.decimals = decimals
        self.isBigAmount = self.amount == 0 && value > 0 && decimalValue > 0
        self.isSmallAmount = self.amount == 0 && value > 0 && decimalValue == 0
    }
}


public extension Money {
    var displayText: String {
        return MoneyUtil.getScaledText(amount, decimals: decimals)
    }

    var displayTextWithoutSpaces: String {
        return displayText.replacingOccurrences(of: " ", with: "")
    }
    
    func displayTextFull(isFiat: Bool) -> String {
        return MoneyUtil.getScaledFullText(amount, decimals: decimals, isFiat: isFiat)
    }
    
    var displayShortText: String {
        return MoneyUtil.getScaledShortText(amount, decimals: decimals)
    }
}

public extension Money {

    var isZero: Bool {
        return amount == 0
    }
    
    var decimalValue: Decimal {
        return Decimal(amount) / pow(10, decimals)
    }

    var doubleValue: Double {
        return decimalValue.doubleValue
    }

    var floatValue: Float {
        return decimalValue.floatValue
    }
}


public extension Money {
    
    func add(_ value: Double) -> Money {
        let additionalValue = Int64(value * pow(10, decimals).doubleValue)
        return Money(amount + additionalValue, decimals)
    }
    
    func minus(_ value: Double) -> Money {
        
        let additionalValue = Int64(value * pow(10, decimals).doubleValue)
        var newAmount = amount - additionalValue
        
        if newAmount < 0 {
            newAmount = 0
        }
        return Money(newAmount, decimals)
    }
}

//MARK: - Calculation
public extension Money {
    
    static func price(amount: Int64, amountDecimals: Int, priceDecimals: Int) -> Money {
        
        let precisionDiff = priceDecimals - amountDecimals + 8
        let decimalValue = Decimal(amount) / pow(10, precisionDiff)
        
        return Money((decimalValue * pow(10, priceDecimals)).int64Value, priceDecimals)
    }
}
