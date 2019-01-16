//
//  MyOrderMatcher.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Matcher.DTO {
    
    struct Order: Decodable {
        
        enum OrderType: String, Decodable {
            case sell
            case buy
        }
        
        enum Status: String, Decodable {
            case Accepted
            case PartiallyFilled
            case Cancelled
            case Filled
        }
        
        let id: String
        let type: OrderType
        let amount: Int64
        let price: Int64
        let filled: Int64
        let status: Status
        let timestamp: Date
    }
}
