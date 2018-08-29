//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation


//struct DecodableElement<Base : Decodable> : Decodable {
//
//    let base: Base?
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        self.base = try? container.decode(Base.self)
//    }
//}
//
//struct CodableArray<Element : Codable> : Codable {
//
//    var elements: [Element]
//
//    init(from decoder: Decoder) throws {
//
//        var container = try decoder.unkeyedContainer()
//
//        var elements = [Element]()
//        if let count = container.count {
//            elements.reserveCapacity(count)
//        }
//
//        while !container.isAtEnd {
//            if let element = try container.decode(Decodable<Element>.self).base {
//                elements.append(element)
//            }
//        }
//
//        self.elements = elements
//    }
//
//    func encode(to encoder: Encoder) throws {
//        _r = encoder.singleValueContainer()
//        try container.encode(elements)
//    }
//}

extension Node.DTO {

    enum CodingKeys: String, CodingKey {
        case type = "type"
    }

    struct TransactionContainers: Decodable {
        enum Transaction {
            case unrecognised
            case issue(Node.DTO.TransactionIssue)
            case transfer(Node.DTO.TransactionTransfer)
            case reissue(Node.DTO.TransactionReissue)
            case burn(Node.DTO.TransactionBurn)
            case exchange(Node.DTO.TransactionExchange)
            case lease(Node.DTO.TransactionLease)
            case leaseCancel(Node.DTO.TransactionLeaseCancel)
            case alias(Node.DTO.TransactionAlias)
            case massTransfer(Node.DTO.TransactionMassTransfer)
            case data(Node.DTO.TransactionData)
        }

        enum TransactionTypes: Int, Decodable {
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

        init(from decoder: Decoder) throws {

            var transactions: [Transaction] = []

            do {

                var container = try decoder.unkeyedContainer()
                var listForType = try container.nestedUnkeyedContainer()

                var listArray = listForType
                while !listForType.isAtEnd {

                    let objectType = try listForType.nestedContainer(keyedBy: CodingKeys.self)
                    guard let type = try? objectType.decode(TransactionTypes.self, forKey: .type) else {
                        transactions.append(.unrecognised)
                        continue
                    }

                    switch type {
                    case .issue:
                        let tx = try listArray.decode(Node.DTO.TransactionIssue.self)
                        transactions.append(.issue(tx))

                    case .transfer:
                        let tx = try listArray.decode(Node.DTO.TransactionTransfer.self)
                        transactions.append(.transfer(tx))

                    case .reissue:
                        let tx = try listArray.decode(Node.DTO.TransactionReissue.self)
                        transactions.append(.reissue(tx))

                    case .burn:
                        let tx = try listArray.decode(Node.DTO.TransactionBurn.self)
                        transactions.append(.burn(tx))

                    case .exchange:
                        let tx = try listArray.decode(Node.DTO.TransactionExchange.self)
                        transactions.append(.exchange(tx))

                    case .lease:
                        let tx = try listArray.decode(Node.DTO.TransactionLease.self)
                        transactions.append(.lease(tx))

                    case .leaseCancel:
                        let tx = try listArray.decode(Node.DTO.TransactionLeaseCancel.self)
                        transactions.append(.leaseCancel(tx))

                    case .alias:
                        let tx = try listArray.decode(Node.DTO.TransactionAlias.self)
                        transactions.append(.alias(tx))

                    case .massTransfer:
                        let tx = try listArray.decode(Node.DTO.TransactionMassTransfer.self)
                        transactions.append(.massTransfer(tx))

                    case .data:
                        let tx = try listArray.decode(Node.DTO.TransactionData.self)
                        transactions.append(.data(tx))
                    }
                }

            } catch let e {
                error(e)
            }

           debug(transactions)
        }
    }
}
