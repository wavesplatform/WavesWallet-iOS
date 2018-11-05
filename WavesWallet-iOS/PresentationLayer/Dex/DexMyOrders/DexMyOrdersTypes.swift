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
        }
        
        var action: Action
        var section: DexMyOrders.ViewModel.Section
        var isAppeared: Bool
    }
}

extension DexMyOrders.ViewModel {
 
    struct Section: Mutating {
        var items: [Row]
    }

    enum Row {
        case order(DexMyOrders.DTO.Order)
    }
    
    static let dateFormatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    static let dateFormatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
}

extension DexMyOrders.DTO {
    
    enum Status {
        case accepted
        case partiallyFilled
        case cancelled
        case filled
    }
    
    struct Order {
        let id: String
        let time: Date
        let status: Status
        let price: Money
        let amount: Money
        let filled: Money
        let type: Dex.DTO.OrderType
    }
    
    struct MyOrdersRequest {
        private let senderPrivateKey: PrivateKeyAccount
        let timestamp: Int64
        
        init(senderPrivateKey: PrivateKeyAccount) {
            self.senderPrivateKey = senderPrivateKey
            self.timestamp = Int64(Date().millisecondsSince1970)
        }
        
        private var toSign: [UInt8] {
            let s1 = senderPrivateKey.publicKey
            let s2 = toByteArray(timestamp)
            return s1 + s2
        }
        
        var signature: [UInt8] {
            return Hash.sign(toSign, senderPrivateKey.privateKey)
        }
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
