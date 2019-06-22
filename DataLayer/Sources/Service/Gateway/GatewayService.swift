//
//  GavewayService.swift
//  InternalDataLayer
//
//  Created by Pavel Gubin on 22.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

enum Gateway {
    enum Service {}
    enum DTO {}
}

extension Gateway.DTO {
    
    struct Withdraw: Decodable {
        let recipientAddress: String
        let minAmount: Double
        let maxAmount: Double
        let fee: Double
        let processId: String
    }
}
