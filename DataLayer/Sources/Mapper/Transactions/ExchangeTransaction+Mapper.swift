//
//  ExchangeTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK

extension ExchangeTransactionRealm {
    convenience init(transaction: ExchangeTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
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

        order1 = ExchangeTransactionOrderRealm(order: transaction.order1)
        order2 = ExchangeTransactionOrderRealm(order: transaction.order2)
        status = transaction.status.rawValue
    }
}

extension ExchangeTransaction {
    init(transaction: NodeService.DTO.ExchangeTransaction,
         status: TransactionStatus?,
         aliasScheme: String) {
        let order1 = ExchangeTransaction.Order(order: transaction.order1,
                                                               aliasScheme: aliasScheme)

        let order2 = ExchangeTransaction.Order(order: transaction.order2,
                                                               aliasScheme: aliasScheme)

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  height: transaction.height,
                  signature: transaction.signature,
                  proofs: nil,
                  order1: order1,
                  order2: order2,
                  price: transaction.price,
                  amount: transaction.amount,
                  buyMatcherFee: transaction.buyMatcherFee,
                  sellMatcherFee: transaction.sellMatcherFee,
                  modified: Date(),
                  status: status ?? transaction.applicationStatus?.transactionStatus ?? .completed,
                  version: transaction.version)
    }

    init(transaction: ExchangeTransactionRealm) {
        let order1 = ExchangeTransaction.Order(order: transaction.order1!)
        let order2 = ExchangeTransaction.Order(order: transaction.order2!)

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  height: transaction.height,
                  signature: transaction.signature,
                  proofs: transaction.proofs.toArray(),
                  order1: order1,
                  order2: order2,
                  price: transaction.price,
                  amount: transaction.amount,
                  buyMatcherFee: transaction.buyMatcherFee,
                  sellMatcherFee: transaction.sellMatcherFee,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed,
                  version: transaction.version)
    }
}

private extension ExchangeTransaction.Order.Kind {
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

extension ExchangeTransactionOrderRealm {
    convenience init(order: ExchangeTransaction.Order) {
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

        let assetPair = ExchangeTransactionAssetPairRealm()
        assetPair.amountAsset = order.assetPair.amountAsset
        assetPair.priceAsset = order.assetPair.priceAsset
        self.assetPair = assetPair
        matcherFeeAssetId = order.matcherFeeAssetId
    }
}

extension ExchangeTransaction.Order {
    init(order: NodeService.DTO.ExchangeTransaction.Order,
         aliasScheme: String) {
        let amountAsset = order.assetPair.amountAsset.normalizeAssetId
        let priceAsset = order.assetPair.priceAsset.normalizeAssetId

        let assetPair = ExchangeTransaction.Pair(amountAsset: amountAsset,
                                                                      priceAsset: priceAsset)
        self.init(id: order.id,
                  sender: order.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: order.senderPublicKey,
                  matcherPublicKey: order.matcherPublicKey,
                  assetPair: assetPair,
                  orderType: .init(key: order.orderType),
                  price: order.price,
                  amount: order.amount,
                  timestamp: order.timestamp,
                  expiration: order.expiration,
                  matcherFee: order.matcherFee,
                  signature: order.signature,
                  matcherFeeAssetId: order.matcherFeeAssetId)
    }

    init(order: ExchangeTransactionOrderRealm) {
        let amountAssetId = order.assetPair?.amountAsset
        let priceAssetId = order.assetPair?.priceAsset

        let assetPair = ExchangeTransaction.Pair(amountAsset: amountAssetId.normalizeAssetId,
                                                                      priceAsset: priceAssetId.normalizeAssetId)

        self.init(id: order.id,
                  sender: order.sender,
                  senderPublicKey: order.senderPublicKey,
                  matcherPublicKey: order.matcherPublicKey,
                  assetPair: assetPair,
                  orderType: .init(key: order.orderType),
                  price: order.price,
                  amount: order.amount,
                  timestamp: order.timestamp,
                  expiration: order.expiration,
                  matcherFee: order.matcherFee,
                  signature: order.signature,
                  matcherFeeAssetId: order.matcherFeeAssetId)
    }
}
