//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {

    struct TransactionContainers: Decodable {
        enum Transaction {
            case unrecognised
            case issue(Node.DTO.TransactionIssue)
            case transfer(Node.DTO.TransactionTransfer)
            case reissue(Node.DTO.TransactionReissue)
            case burn(Node.DTO.TransactionBurnTransactionBurn)
            case exchange(Node.DTO.TransactionExchange)
            case lease(Node.DTO.LeasingTransaction)
            case leaseCancel(Node.DTO.TransactionLeaseCancel)
            case alias(Node.DTO.TransactionAlias)
            case massTransfer(Node.DTO.TransactionAlias)
            case data(Node.DTO.TransactionData)
        }

        init(from decoder: Decoder) throws {

        }
    }
}
