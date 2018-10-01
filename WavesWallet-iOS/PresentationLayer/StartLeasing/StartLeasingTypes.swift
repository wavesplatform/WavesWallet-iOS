//
//  StartLeasingTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum StartLeasing {
    enum DTO {}
}

extension StartLeasing.DTO {
    
    struct Order {
        let assetId: String
        var address: String
        var amount: Money
    }
}
