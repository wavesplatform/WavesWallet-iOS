//
//  Decimal+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Decimal {
    
    func rounded(to: Int) -> Decimal {

        let number = NSDecimalNumber(decimal: self)
        let behavior = NSDecimalNumberHandler(roundingMode: .plain,
                                              scale: Int16(to),
                                              raiseOnExactness: false,
                                              raiseOnOverflow: false,
                                              raiseOnUnderflow: false,
                                              raiseOnDivideByZero: false)
        
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
