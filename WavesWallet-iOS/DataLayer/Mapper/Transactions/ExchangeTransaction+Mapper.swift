//
//  ExchangeTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKCrypto

extension ExchangeTransaction {

    convenience init(transaction: DomainLayer.DTO.ExchangeTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = 1
        height = transaction.height
        modified = transaction.modified

        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        signature = transaction.signature
        amount = transaction.amount
        price = transaction.price
        signature = transaction.signature
        buyMatcherFee = transaction.buyMatcherFee
        sellMatcherFee = transaction.sellMatcherFee

        order1 = ExchangeTransactionOrder(order: transaction.order1)
        order2 = ExchangeTransactionOrder(order: transaction.order2)
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.ExchangeTransaction {

    init(transaction: Node.DTO.ExchangeTransaction, status: DomainLayer.DTO.TransactionStatus, environment: Environment) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender.normalizeAddress(environment: environment)
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height
        modified = Date()

        signature = transaction.signature
        amount = transaction.amount
        price = transaction.price        
        buyMatcherFee = transaction.buyMatcherFee
        sellMatcherFee = transaction.sellMatcherFee
        order1 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order1, environment: environment)
        order2 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order2, environment: environment)
        proofs = []
        self.status = status
    }

    init(transaction: ExchangeTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height
        modified = transaction.modified

        amount = transaction.amount
        price = transaction.price
        signature = transaction.signature
        proofs = transaction.proofs.toArray()
        buyMatcherFee = transaction.buyMatcherFee
        sellMatcherFee = transaction.sellMatcherFee
        order1 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order1!)
        order2 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order2!)
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}

fileprivate extension DomainLayer.DTO.ExchangeTransaction.Order.Kind {

    init(key: String) {
        if key == "sell" {
            self = .sell
        } else {
            self = .buy
        }
    }

    var key: String {
        switch self {
        case .sell:
            return "sell"
        case .buy:
            return "buy"
        }
    }
}

extension ExchangeTransactionOrder {

    convenience init(order: DomainLayer.DTO.ExchangeTransaction.Order) {
        self.init()

        id = order.id
        sender = order.sender
        senderPublicKey = order.sender
        matcherPublicKey = order.matcherPublicKey
        orderType = order.orderType.key
        price = order.price
        amount = order.amount
        timestamp = order.timestamp
        expiration = order.expiration
        matcherFee = order.matcherFee
        signature = order.signature

        let assetPair = ExchangeTransactionAssetPair()
        assetPair.amountAsset = order.assetPair.amountAsset
        assetPair.priceAsset = order.assetPair.priceAsset
        self.assetPair = assetPair
    }
}

extension DomainLayer.DTO.ExchangeTransaction.Order {

    init(order: Node.DTO.ExchangeTransaction.Order, environment: Environment) {

        id = order.id
        sender = order.sender.normalizeAddress(environment: environment)
        senderPublicKey = order.senderPublicKey
        matcherPublicKey = order.matcherPublicKey
        orderType = .init(key: order.orderType)
        price = order.price
        amount = order.amount
        timestamp = order.timestamp
        expiration = order.expiration
        matcherFee = order.matcherFee
        signature = order.signature
        assetPair = DomainLayer.DTO.ExchangeTransaction.AssetPair(amountAsset: order.assetPair.amountAsset.normalizeAssetId,
                                                                  priceAsset: order.assetPair.priceAsset.normalizeAssetId)
    }

    init(order: ExchangeTransactionOrder) {
        id = order.id
        sender = order.sender
        senderPublicKey = order.sender
        matcherPublicKey = order.matcherPublicKey
        orderType =  .init(key: order.orderType)
        price = order.price
        amount = order.amount
        timestamp = order.timestamp
        expiration = order.expiration
        matcherFee = order.matcherFee
        signature = order.signature

        let amountAssetId = order.assetPair?.amountAsset
        let priceAssetId = order.assetPair?.priceAsset
        
        assetPair = DomainLayer.DTO.ExchangeTransaction.AssetPair(amountAsset: amountAssetId.normalizeAssetId,
                                                                  priceAsset: priceAssetId.normalizeAssetId)
    }
}

