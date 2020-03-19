//
//  Date.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

extension Date {
    var isThisYear: Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let year = calendar.component(.year, from: self)
        return year == currentYear
    }
    
    var isThisMonth: Bool {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let month = calendar.component(.month, from: self)
        return month == currentMonth
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
}
