//
//  Transactions.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum TransactionsRepositoryError: Error {
    case fail
}

enum TransactionStatus: Int, Decodable {
    case activeNow
    case completed
    case unconfirmed
}

enum TransactionType: Int {
    case issue = 3
    case transfer = 4
    case reissue = 5
    case burn = 6
    case exchange = 7
    case lease = 8
    case leaseCancel = 9
    case alias = 10
    case massTransfer = 11
    case data = 12
    case script = 13
    case sponsorship = 14
    case assetScript = 15
    case invokeScript = 16
    case any_17 = 17
    case any_18 = 18
    case any_19 = 19
    case any_20 = 20
    case any_21 = 21

    static var all: [TransactionType] {
        return [.issue,
                .transfer,
                .reissue,
                .burn,
                .exchange,
                .lease,
                .leaseCancel,
                .alias,
                .massTransfer,
                .data,
                .script,
                .sponsorship,
                .assetScript,
                .invokeScript,
                .any_17,
                .any_18,
                .any_19,
                .any_20,
                .any_21]
    }
}

struct TransactionsSpecifications {
    
    struct Page {
        let offset: Int
        let limit: Int
    }

    let page: Page?
    let assets: [String]
    let senders: [String]
    let types: [TransactionType]
}


struct AliasTransactionSender {
    let alias: String
    let fee: Int64
}

public struct LeaseTransactionSender {
    public let recipient: String
    public let amount: Int64
    public let fee: Int64
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

    struct TransactionFeeRules {
        struct Rule  {
            let addSmartAssetFee: Bool
            let addSmartAccountFee: Bool
            let minPriceStep: Int64
            let fee: Int64
            let pricePerTransfer: Int64
            let pricePerKb: Int64
        }

        let smartAssetExtraFee: Int64
        let smartAccountExtraFee: Int64

        let defaultRule: TransactionFeeRules.Rule
        let rules: [TransactionType: TransactionFeeRules.Rule]
    }
}

