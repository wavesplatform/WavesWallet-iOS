//
//  Date.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import SwiftDate

extension Date {
    
    var isThisYear: Bool {
        return self.compare(.isThisYear)
    }
    
    var isThisWeek: Bool {
        return self.compare(.isThisWeek)
    }
    
    var isThisMonth: Bool {
        return self.compare(.isThisMonth)
    }
    
    var isToday: Bool {
        return self.compare(.isToday)
    }
    
    var isYesterday: Bool {
       return self.compare(.isYesterday)
    }
}
