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
            case deleteRow(IndexPath)
            case deleteSection(Int)
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
    
    static let dateFormatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    static let dateFormatterHeader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}

extension DexMyOrders.DTO {
    
    enum OrderType {
        case sell
        case buy
    }
    
    enum Status {
        case accepted
        case partiallyFilled
        case cancelled
        case filled
    }
    
    struct Order {
        let time: Date
        let status: Status
        let price: Money
        let amount: Money
        let type: OrderType
    }
}

extension DexMyOrders.ViewModel.Row {
    var order: DexMyOrders.DTO.Order? {
        switch self {
        case .order(let order):
            return order
        }
    }
}
