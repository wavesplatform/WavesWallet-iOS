//
//  DexTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/12/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum Dex {
    enum DTO {}
}

extension Dex.DTO {
    
    struct Asset {
        let id: String
        let name: String
        let decimals: Int
    }

    enum OrderType {
        case sell
        case buy
    }
}

