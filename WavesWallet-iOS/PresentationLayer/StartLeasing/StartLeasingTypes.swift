//
//  StartLeasingTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

private enum Constansts {
    static let fee: Int64 = 100000
}

enum StartLeasing {
    enum DTO {}
    
    enum Event {
        case createOrder
        case orderDidCreate(Response<Bool>)
        case updateInputOrder(DTO.Order)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case showCreatingOrderState
            case orderDidFailCreate(String)
            case orderDidCreate
        }
        
        var isNeedCreateOrder: Bool
        var order: DTO.Order?
        var action: Action
    }
}

extension StartLeasing.DTO {
    
    struct Order {
        var recipient: String
        var amount: Money
        let fee = Constansts.fee
        var time: Date
    }
}
