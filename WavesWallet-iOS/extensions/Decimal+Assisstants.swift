//
//  Decimal+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }

    var floatValue: Float {
        return NSDecimalNumber(decimal: self).floatValue
    }
}
