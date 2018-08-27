//
//  Money.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation


struct Money: Hashable {
    let amount: Int64
    let decimals: Int
    
    init(_ amount: Int64, _ decimals: Int) {
        self.amount = amount
        self.decimals = decimals
    }
    
    var displayText: String {
        return MoneyUtil.getScaledTextTrimZeros(amount, decimals: decimals)
    }
    
    var displayTextFull: String {
        return MoneyUtil.getScaledText(amount, decimals: decimals)
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
    
    init(_ value: Double) {
        
        let number = NSNumber(value: value)
        let resultString = number.stringValue
        
        let theScanner = Scanner(string: resultString)
        let decimalPoint = "."
        var unwanted: NSString?
        
        theScanner.scanUpTo(decimalPoint, into: &unwanted)
        
        var countDecimals = 0
        
        if let unwanted = unwanted {
            countDecimals = ((resultString.count - unwanted.length) > 0) ? resultString.count - unwanted.length - 1 : 0
        }
        
        decimals = countDecimals
        amount = Int64(value * pow(10, decimals).doubleValue)
    }
    
    func formattedText(defaultMinimumFractionDigits: Bool = false) -> String {
        return MoneyUtil.getScaledText(amount, decimals: decimals, defaultMinimumFractionDigits: defaultMinimumFractionDigits)
    }
}

extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
    
    var floatValue: Float {
        return NSDecimalNumber(decimal: self).floatValue
    }
}
