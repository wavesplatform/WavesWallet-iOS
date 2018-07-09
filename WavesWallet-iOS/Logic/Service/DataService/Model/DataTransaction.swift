//
//  Transaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DataService.Model {

    struct ExchangeTransaction: Codable {
        let ticker: String?
        let id: String
        let name: String
        let precision: Int
        let height: Int
        let description: String
        let timestamp: String
        let sender: String
        let quantity: Int
        let reissuable: Bool
        let firstPrice: Int
        let lastPrice: Int
        let volume: Int
        let volumeWaves: Int
    }
}
