//
//  CandleFilters.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension API.Query {
    
    struct CandleFilters: Codable {
        let timeStart: Int64
        let timeEnd: Int64
        let interval: String
    }
}
