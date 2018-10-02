//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {

    enum CodingKeys: String, CodingKey {
        case type = "type"
    }

    struct TransactionContainers: Decodable {
        enum Transaction {
            case unrecognised(Node.DTO.UnrecognisedTransaction)
            case issue(Node.DTO.IssueTransaction)
            case transfer(Node.DTO.TransferTransaction)
            case reissue(Node.DTO.ReissueTransaction)
            case burn(Node.DTO.BurnTransaction)
            case exchange(Node.DTO.ExchangeTransaction)
            case lease(Node.DTO.LeaseTransaction)
            case leaseCancel(Node.DTO.LeaseCancelTransaction)
            case alias(Node.DTO.AliasTransaction)
            case massTransfer(Node.DTO.MassTransferTransaction)
            case data(Node.DTO.DataTransaction)
        }

        private enum TransactionType: Int, Decodable {
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
        }

        let transactions: [Transaction]

        init(from decoder: Decoder) throws {

            var transactions: [Transaction] = []

            do {

                var container = try decoder.unkeyedContainer()
                var listForType = try container.nestedUnkeyedContainer()

                var listArray = listForType
                while !listForType.isAtEnd {

                    let objectType = try listForType.nestedContainer(keyedBy: CodingKeys.self)
                    guard let type = try? objectType.decode(TransactionType.self, forKey: .type) else {

                        if let tx = try? listArray.decode(Node.DTO.UnrecognisedTransaction.self) {
                            transactions.append(.unrecognised(tx))
                        }
                        continue
                    }

                    do {
                        switch type {
                        case .issue:
                            let tx = try listArray.decode(Node.DTO.IssueTransaction.self)
                            transactions.append(.issue(tx))

                        case .transfer:
                            let tx = try listArray.decode(Node.DTO.TransferTransaction.self)
                            transactions.append(.transfer(tx))

                        case .reissue:
                            let tx = try listArray.decode(Node.DTO.ReissueTransaction.self)
                            transactions.append(.reissue(tx))

                        case .burn:
                            let tx = try listArray.decode(Node.DTO.BurnTransaction.self)
                            transactions.append(.burn(tx))

                        case .exchange:
                            let tx = try listArray.decode(Node.DTO.ExchangeTransaction.self)
                            transactions.append(.exchange(tx))

                        case .lease:
                            let tx = try listArray.decode(Node.DTO.LeaseTransaction.self)
                            transactions.append(.lease(tx))

                        case .leaseCancel:
                            let tx = try listArray.decode(Node.DTO.LeaseCancelTransaction.self)
                            transactions.append(.leaseCancel(tx))

                        case .alias:
                            let tx = try listArray.decode(Node.DTO.AliasTransaction.self)
                            transactions.append(.alias(tx))

                        case .massTransfer:
                            let tx = try listArray.decode(Node.DTO.MassTransferTransaction.self)
                            transactions.append(.massTransfer(tx))

                        case .data:
                            let tx = try listArray.decode(Node.DTO.DataTransaction.self)
                            transactions.append(.data(tx))
                        }
                    } catch let e {
                        error(e)
                        if let tx = try? listArray.decode(Node.DTO.UnrecognisedTransaction.self) {
                            transactions.append(.unrecognised(tx))
                        }
                    }
                }

            } catch let e {
                error(e)
            }

            self.transactions = transactions
        }
    }
}
