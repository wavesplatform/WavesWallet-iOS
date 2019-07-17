//
//  Transactions.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK

public enum TransactionsRepositoryError: Error {
    case fail
}

public enum TransactionStatus: Int, Decodable {
    case activeNow
    case completed
    case unconfirmed
}

public extension TransactionType {

    static var all: [TransactionType] {
        return [.issue,
                .transfer,
                .reissue,
                .burn,
                .exchange,
                .createLease,
                .cancelLease,
                .createAlias,
                .massTransfer,
                .data,
                .script,
                .sponsorship,
                .assetScript,
                .invokeScript]
    }
}

public struct TransactionsSpecifications {
    
    public struct Page {
        public let offset: Int
        public let limit: Int

        public init(offset: Int, limit: Int) {
            self.offset = offset
            self.limit = limit
        }
    }

    public let page: Page?
    public let assets: [String]
    public let senders: [String]
    public let types: [TransactionType]

    public init(page: Page?, assets: [String], senders: [String], types: [TransactionType]) {
        self.page = page
        self.assets = assets
        self.senders = senders
        self.types = types
    }
}


public struct AliasTransactionSender {
    public let alias: String
    public let fee: Int64

    public init(alias: String, fee: Int64) {
        self.alias = alias
        self.fee = fee
    }
}

public struct LeaseTransactionSender {
    public let recipient: String
    public let amount: Int64
    public let fee: Int64

    public init(recipient: String, amount: Int64, fee: Int64) {
        self.recipient = recipient
        self.amount = amount
        self.fee = fee
    }
}

public struct BurnTransactionSender {
    public let assetID: String
    public let quantity: Int64
    public let fee: Int64

    public init(assetID: String, quantity: Int64, fee: Int64) {
        self.assetID = assetID
        self.quantity = quantity
        self.fee = fee
    }
}

public struct CancelLeaseTransactionSender {
    public let leaseId: String
    public let fee: Int64
    
    public init(leaseId: String, fee: Int64) {
        self.leaseId = leaseId
        self.fee = fee
    }
}

public struct DataTransactionSender {
    public struct Value {
        public enum Kind {
            case integer(Int64)
            case boolean(Bool)
            case string(String)
            case binary([UInt8])
        }

        public let key: String
        public let value: Kind

        public init(key: String, value: Kind) {
            self.key = key
            self.value = value
        }
    }

    public let fee: Int64
    public let data: [Value]

    public init(fee: Int64, data: [Value]) {
        self.fee = fee
        self.data = data
    }
}

public struct SendTransactionSender {
    public let recipient: String
    public let assetId: String
    public let amount: Int64
    public let fee: Int64
    public let attachment: String
    public let feeAssetID: String

    public init(recipient: String, assetId: String, amount: Int64, fee: Int64, attachment: String, feeAssetID: String) {
        self.recipient = recipient
        self.assetId = assetId
        self.amount = amount
        self.fee = fee
        self.attachment = attachment
        self.feeAssetID = feeAssetID
    }
}

public enum TransactionSenderSpecifications {
    case createAlias(AliasTransactionSender)
    case lease(LeaseTransactionSender)
    case burn(BurnTransactionSender)
    case cancelLease(CancelLeaseTransactionSender)
    case data(DataTransactionSender)
    case send(SendTransactionSender)
}

public protocol TransactionsRepositoryProtocol {

    func transactions(by address: DomainLayer.DTO.Address, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]>
    func transactions(by address: DomainLayer.DTO.Address, specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]>
    func newTransactions(by address: DomainLayer.DTO.Address,
                         specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]>

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> 
    
    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool>

    func isHasTransaction(by id: String, accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool>
    func isHasTransactions(by ids: [String], accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool>
    func isHasTransactions(by accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool>

    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.AnyTransaction>

    func feeRules() -> Observable<DomainLayer.DTO.TransactionFeeRules>
}

extension DomainLayer.DTO {

    public struct TransactionFeeRules {
        public struct Rule  {
            public let addSmartAssetFee: Bool
            public let addSmartAccountFee: Bool
            public let minPriceStep: Int64
            public let fee: Int64
            public let pricePerTransfer: Int64
            public let pricePerKb: Int64
        

            public init(addSmartAssetFee: Bool, addSmartAccountFee: Bool, minPriceStep: Int64, fee: Int64, pricePerTransfer: Int64, pricePerKb: Int64) {
                self.addSmartAssetFee = addSmartAssetFee
                self.addSmartAccountFee = addSmartAccountFee
                self.minPriceStep = minPriceStep
                self.fee = fee
                self.pricePerTransfer = pricePerTransfer
                self.pricePerKb = pricePerKb
            }
        }
        
        public let smartAssetExtraFee: Int64
        public let smartAccountExtraFee: Int64

        public let defaultRule: TransactionFeeRules.Rule
        public let rules: [TransactionType: TransactionFeeRules.Rule]

        public init(smartAssetExtraFee: Int64, smartAccountExtraFee: Int64, defaultRule: TransactionFeeRules.Rule, rules: [TransactionType: TransactionFeeRules.Rule]) {
            self.smartAssetExtraFee = smartAssetExtraFee
            self.smartAccountExtraFee = smartAccountExtraFee
            self.defaultRule = defaultRule
            self.rules = rules
        }
    }
}

