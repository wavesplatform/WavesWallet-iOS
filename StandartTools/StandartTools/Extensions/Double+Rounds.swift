//
//  Double+Rounds.swift
//  StandartTools
//
//  Created by rprokofev on 18.08.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import Foundation

public extension Double {
    /// Rounds the double to decimal places value
    public  func rounded(toPlaces places: Int, rule: FloatingPointRoundingRule) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(rule) / divisor
    }
}
