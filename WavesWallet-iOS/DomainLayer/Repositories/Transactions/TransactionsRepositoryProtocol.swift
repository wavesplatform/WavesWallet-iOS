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
                .data]
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

protocol TransactionBrodcasterSpecifications {
    var fee: Int64 { get }
    var id: String { get }
    var proofs: [String] { get }
    var timestamp: Int64 { get }
    var type: Int64 { get }
    var version: Int64 { get }

    var parameter: [String: Any] { get }


//    amount
//    amount: number
//    Defined in transactions.ts:91
//    fee
//    fee: number
//    Inherited from Transaction.fee
//    Defined in transactions.ts:26
//    id
//    id: string
//    Inherited from Transaction.id
//    Defined in transactions.ts:23
//    proofs
//    proofs: string[]
//    Inherited from WithProofs.proofs
//    Defined in transactions.ts:19
//    recipient
//    recipient: string
//    Defined in transactions.ts:92
//    senderPublicKey
//    senderPublicKey: string
//    Inherited from WithSender.senderPublicKey
//    Defined in transactions.ts:41
//    timestamp
//    timestamp: number
//    Inherited from Transaction.timestamp
//    Defined in transactions.ts:25
//    type
//    type: Lease
//    Overrides Transaction.type
//    Defined in transactions.ts:90
//    version
}

protocol TransactionsRepositoryProtocol {

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]>
    func transactions(by accountAddress: String, specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]>
    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> 
    
    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool>

    func isHasTransaction(by id: String, accountAddress: String) -> Observable<Bool>
    func isHasTransactions(by ids: [String], accountAddress: String) -> Observable<Bool>
    func isHasTransactions(by accountAddress: String) -> Observable<Bool>

    func send(by transaction: TransactionBrodcasterSpecifications, wallet: DomainLayer.DTO.SignedWallet)
}
