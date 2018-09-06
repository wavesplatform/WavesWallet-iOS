//
//  Balance.swift
//  WavesWallet-iOS
//
//  Created by Mac on 06/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct Balance {
    
    struct Currency {
        let title: String
        let ticket: String?
    }
    
    let currency: Currency
    let money: Money
    
}
