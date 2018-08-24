//
//  DexMyOrdersTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexMyOrders {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case readyView
        case setOrders([DexMyOrders.DTO.Order])
        case didRemoveOrder(IndexPath)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
        }
        
        var action: Action
        var sections: [DexMyOrders.ViewModel.Section]
    }
}

extension DexMyOrders.ViewModel {
    
    struct Header {
        let date: Date
    }
    
    struct Section: Mutating {
        var items: [Row]
        var header: Header
    }

    enum Row {
        case order(DexMyOrders.DTO.Order)
    }
}

extension DexMyOrders.DTO {
    
    enum OrderType {
        case sell
        case buy
    }
    
    struct Order {
        let time: Date
        let status: String
        let price: Money
        let amount: Money
        let type: OrderType
    }
}
