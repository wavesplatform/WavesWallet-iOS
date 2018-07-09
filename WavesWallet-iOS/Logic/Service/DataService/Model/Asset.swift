//
//  Asset.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DataService.Model {
    struct Asset: Decodable {
        let ticker: String?
        let id, name: String
        let precision: Int
        let description: String
        let height: Int
        let timestamp, sender: String
        let quantity: Int
        let reissuable: Bool
    }
}
