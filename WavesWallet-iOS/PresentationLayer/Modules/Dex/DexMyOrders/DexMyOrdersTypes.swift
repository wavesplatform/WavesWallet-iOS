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
        case cancelOrder(IndexPath)
        case orderDidFinishCancel(ResponseType<Bool>)
        case refresh
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
            case orderDidFailCancel(NetworkError)
            case orderDidFinishCancel
        }
        
        var action: Action
        var section: DexMyOrders.ViewModel.Section
        var isNeedLoadOrders: Bool
        var isNeedCancelOrder: Bool
        var canceledOrder: DexMyOrders.DTO.Order?
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
        var status: Status
        let price: Money
        let amount: Money
        let filled: Money
        let type: Dex.DTO.OrderType
        let amountAsset: Dex.DTO.Asset
        let priceAsset: Dex.DTO.Asset
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
    
    struct CancelRequest {
        private let senderPublicKey: PublicKeyAccount
        private let senderPrivateKey: PrivateKeyAccount
        private let orderId: String
        
        init(senderPublicKey: PublicKeyAccount, senderPrivateKey: PrivateKeyAccount,  orderId: String) {
            self.senderPublicKey = senderPublicKey
            self.senderPrivateKey = senderPrivateKey
            self.orderId = orderId
        }
        
        private var toSign: [UInt8] {
            let s1 = senderPublicKey.publicKey
            let s2 = Base58.decode(orderId)
            return s1 + s2
        }
        
        private var signature: [UInt8] {
            return Hash.sign(toSign, senderPrivateKey.privateKey)
        }
        
        var params: [String : Any] {
            return ["sender" :  Base58.encode(senderPublicKey.publicKey),
                    "orderId" : orderId,
                    "signature" : Base58.encode(signature)]
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

extension DexMyOrders.State: Equatable {
    
    static func == (lhs: DexMyOrders.State, rhs: DexMyOrders.State) -> Bool {
        return lhs.isNeedLoadOrders == rhs.isNeedLoadOrders &&
            lhs.isNeedCancelOrder == rhs.isNeedCancelOrder
    }
}
