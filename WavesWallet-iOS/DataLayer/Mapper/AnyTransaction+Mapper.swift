//
//  AnyTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO.TransactionContainers {

    func anyTransactions() -> [DomainLayer.DTO.AnyTransaction] {

        var anyTransactions = [DomainLayer.DTO.AnyTransaction]()

        for transaction in self.transactions {

            switch transaction {
            case .unrecognised(let transaction):
              anyTransactions.append(.unrecognised(.init(transaction: transaction)))

            case .issue(let transaction):
                anyTransactions.append(.issue(.init(transaction: transaction)))

            case .transfer(let transaction):
                anyTransactions.append(.transfer(.init(transaction: transaction)))

            case .reissue(let transaction):
                anyTransactions.append(.reissue(.init(transaction: transaction)))

            case .burn(let transaction):
                anyTransactions.append(.burn(.init(transaction: transaction)))

            case .exchange(let transaction):
                anyTransactions.append(.exchange(.init(transaction: transaction)))

            case .lease(let transaction):
                anyTransactions.append(.lease(.init(transaction: transaction)))

            case .leaseCancel(let transaction):
                anyTransactions.append(.leaseCancel(.init(transaction: transaction)))

            case .alias(let transaction):
                anyTransactions.append(.alias(.init(transaction: transaction)))

            case .massTransfer(let transaction):
                anyTransactions.append(.massTransfer(.init(transaction: transaction)))

            case .data(let transaction):
                anyTransactions.append(.data(.init(transaction: transaction)))
            }
        }

        return anyTransactions
    }
}
////DomainLayer.DTO.AnyTransaction
//
//extension DomainLayer.DTO.AnyTransaction {
//
//    static func map(transacations: AnyTransaction) -> [DomainLayer.DTO.AnyTransaction] {
//
//    }
//}
//
