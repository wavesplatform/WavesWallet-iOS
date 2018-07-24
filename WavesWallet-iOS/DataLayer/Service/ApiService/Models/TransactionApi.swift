//
//  Transaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension API.DTO {

    // TODO: Not test
    struct ExchangeTransaction: Codable {
        let ticker: String?
        let id: String
        let name: String
        let precision: Int64
        let height: Int64
        let description: String
        let timestamp: String
        let sender: String
        let quantity: Int64
        let reissuable: Bool
        let firstPrice: Int64
        let lastPrice: Int64
        let volume: Int64
        let volumeWaves: Int64
    }
}
