//
//  Decimal+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 29/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

public extension Decimal {
        
    mutating func round(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) {
        var localCopy = self
        NSDecimalRound(&self, &localCopy, scale, roundingMode)
    }

    func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
    
    func rounded() -> Decimal {
        
        let behavior = NSDecimalNumberHandler(roundingMode: .down,
                                              scale: 0,
                                              raiseOnExactness: false,
                                              raiseOnOverflow: false,
                                              raiseOnUnderflow: false,
                                              raiseOnDivideByZero: false)
        
        let number = NSDecimalNumber(decimal: self)
        return number.rounding(accordingToBehavior: behavior).decimalValue
    }
    
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }

    var floatValue: Float {
        return NSDecimalNumber(decimal: self).floatValue
    }

    var int64Value: Int64 {
        return NSDecimalNumber(decimal: self).int64Value
    }
}
