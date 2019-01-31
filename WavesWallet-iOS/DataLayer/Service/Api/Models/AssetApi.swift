//
//  Asset.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension API.DTO {
    struct Asset: Decodable {
        let ticker: String?
        let id: String
        let name: String
        let precision: Int
        let description: String
        let height: Int64
        let timestamp: Date
        let sender: String
        let quantity: Int64
        let reissuable: Bool
        let hasScript: Bool
        let minSponsoredFee: Int64?
    }
}
