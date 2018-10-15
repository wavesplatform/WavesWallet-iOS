//
//  Money.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct Money: Hashable, Codable {
    let amount: Int64
    let decimals: Int
    
    private var _isBigAmount = false
    
    init(_ amount: Int64, _ decimals: Int) {
        self.amount = amount
        self.decimals = decimals
    }
}

extension Money {
 
    init(value: Decimal, _ decimals: Int) {
        let decimalValue = (value * pow(10, decimals)).rounded()
        let isValidDecimal = Decimal(Int64.max) >= decimalValue
        
        self.amount = isValidDecimal ? Int64(truncating: decimalValue as NSNumber) : 0
        self.decimals = decimals
        self._isBigAmount = self.amount == 0 && value > 0
    }
}


extension Money {
    var displayText: String {
        return MoneyUtil.getScaledTextTrimZeros(amount, decimals: decimals)
    }
    
    var displayTextFull: String {
        return MoneyUtil.getScaledText(amount, decimals: decimals)
    }
    
    func formattedText(defaultMinimumFractionDigits: Bool = false) -> String {
        return MoneyUtil.getScaledText(amount, decimals: decimals, defaultMinimumFractionDigits: defaultMinimumFractionDigits)
    }
}

extension Money {

    var isZero: Bool {
        return amount == 0
    }
    
    var isBigAmount: Bool {
        return _isBigAmount
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


extension Money {
    
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
