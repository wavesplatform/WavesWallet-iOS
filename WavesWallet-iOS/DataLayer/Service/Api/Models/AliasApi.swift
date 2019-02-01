//
//  AliasApi.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/30/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension API.DTO {
    
    struct Alias: Decodable {
        let alias: String
        let address: String
    }
}
