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
        
    init(_ amount: Int64, _ decimals: Int) {
        self.amount = amount
        self.decimals = decimals
    }
}

extension Money {
 
    init(value: Decimal, _ decimals: Int) {
        self.decimals = decimals
        self.amount = Int64(truncating: value * pow(10, decimals) as NSNumber)
    }
    
    func formattedText(defaultMinimumFractionDigits: Bool = false) -> String {
        return MoneyUtil.getScaledText(amount, decimals: decimals, defaultMinimumFractionDigits: defaultMinimumFractionDigits)
    }
}

extension Money {

    var isZero: Bool {
        return amount == 0
    }

    var displayText: String {
        return MoneyUtil.getScaledTextTrimZeros(amount, decimals: decimals)
    }

    var displayTextFull: String {
        return MoneyUtil.getScaledText(amount, decimals: decimals)
    }
    
    var decimalValue: Decimal {
        return (Decimal(amount) / pow(10, decimals)).rounded(to: decimals)
    }

    var doubleValue: Double {
        return decimalValue.doubleValue
    }

    var floatValue: Float {
        return decimalValue.floatValue
    }
}
