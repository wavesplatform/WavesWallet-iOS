//
//  Decimal+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension Decimal {
    
    //We ovveride this methods because is Foundation framework Decimal has a bug when it init from (U)Int64
    //  https://github.com/apple/swift/commit/2f4e70bf7f4eee43bfb2f24d6215eb1f63c05d01
    
    //TODO: can be fixed with new xCode 10.2, need to check
    
    public init(_ value: UInt64) {
        self = Decimal()
        if value == 0 {
            return
        }
        
        var compactValue = value
        var exponent: Int32 = 0
        while compactValue % 10 == 0 {
            compactValue = compactValue / 10
            exponent = exponent + 1
        }
        _isCompact = 1
        _exponent = exponent
        
        let wordCount = ((UInt64.bitWidth - compactValue.leadingZeroBitCount) + (UInt16.bitWidth - 1)) / UInt16.bitWidth
        _length = UInt32(wordCount)
        _mantissa.0 = UInt16(truncatingIfNeeded: compactValue >> 0)
        _mantissa.1 = UInt16(truncatingIfNeeded: compactValue >> 16)
        _mantissa.2 = UInt16(truncatingIfNeeded: compactValue >> 32)
        _mantissa.3 = UInt16(truncatingIfNeeded: compactValue >> 48)
    }
    
    public init(_ value: Int64) {
        self.init(value.magnitude)
        if value < 0 {
            _isNegative = 1
        }
    }
    
    public func rounded() -> Decimal {
        
        let behavior = NSDecimalNumberHandler(roundingMode: .down,
                                              scale: 0,
                                              raiseOnExactness: false,
                                              raiseOnOverflow: false,
                                              raiseOnUnderflow: false,
                                              raiseOnDivideByZero: false)
        
        let number = NSDecimalNumber(decimal: self)
        return number.rounding(accordingToBehavior: behavior).decimalValue
    }
    
    public var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }

    public var floatValue: Float {
        return NSDecimalNumber(decimal: self).floatValue
    }

    public var int64Value: Int64 {
        return NSDecimalNumber(decimal: self).int64Value
    }
}
