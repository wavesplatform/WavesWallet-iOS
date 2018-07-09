//
//  ExchangeFilters.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DataService.Query {

    struct ExchangeFilters: Codable {
        // Address of a matcher which sent the transaction
        let matcher: String?
        // Address of a trader-participant in a transaction — an ORDER sender
        let sender: String?
        // Time range filter, start. Defaults to first transaction's time_stamp in db.
        let timeStart: String?
        // Time range filter, end. Defaults to now.
        let timeEnd: String?
        // Asset ID of the amount asset.
        let amountAsset: String?
        // Asset ID of the price asset.
        let priceAsset: String?
        // Cursor in base64 encoding. Holds information about timestamp, id, sort.
        let after: String?
        // Sort order. Gonna be rewritten by cursor's sort if present.
        let sort: String?
        // How many transactions to await in response.
        let limit: Int
    }
}
