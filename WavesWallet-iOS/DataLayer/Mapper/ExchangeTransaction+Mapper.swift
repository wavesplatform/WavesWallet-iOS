//
//  ExchangeTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

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

        signature = transaction.signature
        amount = transaction.amount
        price = transaction.price
        signature = transaction.signature
        buyMatcherFee = transaction.buyMatcherFee
        sellMatcherFee = transaction.sellMatcherFee

        order1 = ExchangeTransactionOrder(order: transaction.order1)
        order2 = ExchangeTransactionOrder(order: transaction.order2)
    }
}

extension DomainLayer.DTO.ExchangeTransaction {

    init(transaction: Node.DTO.ExchangeTransaction) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height
        modified = Date()

        signature = transaction.signature
        amount = transaction.amount
        price = transaction.price        
        buyMatcherFee = transaction.buyMatcherFee
        sellMatcherFee = transaction.sellMatcherFee
        order1 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order1)
        order2 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order2)
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
        buyMatcherFee = transaction.buyMatcherFee
        sellMatcherFee = transaction.sellMatcherFee
        order1 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order1!)
        order2 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order2!)
    }
}

extension ExchangeTransactionOrder {

    convenience init(order: DomainLayer.DTO.ExchangeTransaction.Order) {
        self.init()

        id = order.id
        sender = order.sender
        senderPublicKey = order.sender
        matcherPublicKey = order.matcherPublicKey
        orderType = order.orderType
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

    init(order: Node.DTO.ExchangeTransaction.Order) {

        id = order.id
        sender = order.sender
        senderPublicKey = order.sender
        matcherPublicKey = order.matcherPublicKey
        orderType = order.orderType
        price = order.price
        amount = order.amount
        timestamp = order.timestamp
        expiration = order.expiration
        matcherFee = order.matcherFee
        signature = order.signature
        assetPair = DomainLayer.DTO.ExchangeTransaction.AssetPair(amountAsset: order.assetPair.amountAsset,
                                                                  priceAsset: order.assetPair.priceAsset)
    }

    init(order: ExchangeTransactionOrder) {
        id = order.id
        sender = order.sender
        senderPublicKey = order.sender
        matcherPublicKey = order.matcherPublicKey
        orderType = order.orderType
        price = order.price
        amount = order.amount
        timestamp = order.timestamp
        expiration = order.expiration
        matcherFee = order.matcherFee
        signature = order.signature
        assetPair = DomainLayer.DTO.ExchangeTransaction.AssetPair(amountAsset: order.assetPair?.amountAsset ?? "",
                                                                  priceAsset: order.assetPair?.priceAsset ?? "")
    }
}

