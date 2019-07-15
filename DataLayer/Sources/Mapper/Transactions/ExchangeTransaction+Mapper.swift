//
//  ExchangeTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import DomainLayer

extension ExchangeTransaction {

    convenience init(transaction: DomainLayer.DTO.ExchangeTransaction) {
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

        order1 = ExchangeTransactionOrder(order: transaction.order1)
        order2 = ExchangeTransactionOrder(order: transaction.order2)
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.ExchangeTransaction {

    init(transaction: NodeService.DTO.ExchangeTransaction, status: DomainLayer.DTO.TransactionStatus, environment: WalletEnvironment) {

        let order1 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order1, environment: environment)
        let order2 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order2, environment: environment)
        
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(environment: environment),
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
                  status: status,
                  version: transaction.version)
    }

    init(transaction: ExchangeTransaction) {
        
        let order1 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order1!)
        let order2 = DomainLayer.DTO.ExchangeTransaction.Order(order: transaction.order2!)
        
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
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed,
                  version: transaction.version)
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
        matcherFeeAssetId = order.matcherFeeAssetId
    }
}

extension DomainLayer.DTO.ExchangeTransaction.Order {

    init(order: NodeService.DTO.ExchangeTransaction.Order, environment: WalletEnvironment) {

        let assetPair = DomainLayer.DTO.ExchangeTransaction.AssetPair(amountAsset: order.assetPair.amountAsset.normalizeAssetId,
                                                                      priceAsset: order.assetPair.priceAsset.normalizeAssetId)
        self.init(id: order.id,
                  sender: order.sender.normalizeAddress(environment: environment),
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

    init(order: ExchangeTransactionOrder) {
        
        let amountAssetId = order.assetPair?.amountAsset
        let priceAssetId = order.assetPair?.priceAsset
        
        let assetPair = DomainLayer.DTO.ExchangeTransaction.AssetPair(amountAsset: amountAssetId.normalizeAssetId,
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

