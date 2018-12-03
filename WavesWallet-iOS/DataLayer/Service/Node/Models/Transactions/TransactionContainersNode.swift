//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {

    fileprivate enum TransactionType: Int, Decodable {
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

    enum TransactionError: Error {
        case none
    }

    enum Transaction: Decodable {
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

        init(from decoder: Decoder) throws {

            do {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(TransactionType.self, forKey: .type)

                self = try Transaction.transaction(from: decoder, type: type)
            } catch let e {
                error(e)
                throw TransactionError.none
            }
        }


        fileprivate static func transaction(from decode: Decoder, type: TransactionType) throws -> Transaction {

            switch type {
            case .issue:
                return .issue( try Node.DTO.IssueTransaction(from: decode))

            case .transfer:
                return .transfer( try Node.DTO.TransferTransaction(from: decode))

            case .reissue:
                return .reissue( try Node.DTO.ReissueTransaction(from: decode))

            case .burn:
                return .burn( try Node.DTO.BurnTransaction(from: decode))

            case .exchange:
                return .exchange( try Node.DTO.ExchangeTransaction(from: decode))

            case .lease:
                return .lease( try Node.DTO.LeaseTransaction(from: decode))

            case .leaseCancel:
                return .leaseCancel( try Node.DTO.LeaseCancelTransaction(from: decode))

            case .alias:
                return .alias( try Node.DTO.AliasTransaction(from: decode))

            case .massTransfer:
                return .massTransfer( try Node.DTO.MassTransferTransaction(from: decode))

            case .data:
                return .data(try Node.DTO.DataTransaction(from: decode))
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case type = "type"
    }

    struct TransactionContainers: Decodable {

        let transactions: [Transaction]

        init(from decoder: Decoder) throws {

            var transactions: [Transaction] = []

            do {

                var container = try decoder.unkeyedContainer()
                var listForType = try container.nestedUnkeyedContainer()

                var listArray = listForType
                while !listForType.isAtEnd {

                    let objectType = try listForType.nestedContainer(keyedBy: CodingKeys.self)

                    do {
                        let type = try objectType.decode(TransactionType.self, forKey: .type)

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

                        if let tx = try? listArray.decode(Node.DTO.UnrecognisedTransaction.self) {
                            transactions.append(.unrecognised(tx))
                            error("Unrecognised \(e)")
                        } else {
                            error("Not Found type \(e)")
                        }
                    }
                }

            } catch let e {
                error("WTF \(e)")
            }

            print("self.transactions \(transactions.count)")
            self.transactions = transactions
        }
    }
}
