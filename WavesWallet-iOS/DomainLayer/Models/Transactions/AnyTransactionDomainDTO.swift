//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    enum TransactionStatus: Int, Decodable {
        case activeNow
        case completed
        case unconfirmed
    }

    enum AnyTransaction {
        case unrecognised(DomainLayer.DTO.UnrecognisedTransaction)
        case issue(DomainLayer.DTO.IssueTransaction)
        case transfer(DomainLayer.DTO.TransferTransaction)
        case reissue(DomainLayer.DTO.ReissueTransaction)
        case burn(DomainLayer.DTO.BurnTransaction)
        case exchange(DomainLayer.DTO.ExchangeTransaction)
        case lease(DomainLayer.DTO.LeaseTransaction)
        case leaseCancel(DomainLayer.DTO.LeaseCancelTransaction)
        case alias(DomainLayer.DTO.AliasTransaction)
        case massTransfer(DomainLayer.DTO.MassTransferTransaction)
        case data(DomainLayer.DTO.DataTransaction)
        case script(DomainLayer.DTO.ScriptTransaction)
        case assetScript(DomainLayer.DTO.AssetScriptTransaction)
    }
}

// TODO: Protocol
extension DomainLayer.DTO.AnyTransaction {

    var status: DomainLayer.DTO.TransactionStatus {
        switch self {
        case .unrecognised(let tx):
            return tx.status

        case .issue(let tx):
            return tx.status

        case .transfer(let tx):
            return tx.status

        case .reissue(let tx):
            return tx.status

        case .burn(let tx):
            return tx.status

        case .exchange(let tx):
            return tx.status

        case .lease(let tx):
            return tx.status

        case .leaseCancel(let tx):
            return tx.status

        case .alias(let tx):
            return tx.status

        case .massTransfer(let tx):
            return tx.status

        case .data(let tx):
            return tx.status

        case .script(let tx):
            return tx.status

        case .assetScript(let tx):
            return tx.status
        }
    }

    var isLease: Bool {
        switch self {
        case .lease:
            return true

        default:
            return false
        }
    }

    var isLeaseCancel: Bool {
        switch self {
        case .leaseCancel:
            return true

        default:
            return false
        }
    }

    var id: String {
        switch self {
        case .unrecognised(let tx):
            return tx.id

        case .issue(let tx):
            return tx.id

        case .transfer(let tx):
            return tx.id

        case .reissue(let tx):
            return tx.id

        case .burn(let tx):
            return tx.id

        case .exchange(let tx):
            return tx.id

        case .lease(let tx):
            return tx.id

        case .leaseCancel(let tx):
            return tx.id

        case .alias(let tx):
            return tx.id
            
        case .massTransfer(let tx):
            return tx.id

        case .data(let tx):
            return tx.id

        case .script(let tx):
            return tx.id

        case .assetScript(let tx):
            return tx.id
        }
    }

    var timestamp: Int64 {
        switch self {
        case .unrecognised(let tx):
            return tx.timestamp

        case .issue(let tx):
            return tx.timestamp

        case .transfer(let tx):
            return tx.timestamp

        case .reissue(let tx):
            return tx.timestamp

        case .burn(let tx):
            return tx.timestamp

        case .exchange(let tx):
            return tx.timestamp

        case .lease(let tx):
            return tx.timestamp

        case .leaseCancel(let tx):
            return tx.timestamp

        case .alias(let tx):
            return tx.timestamp

        case .massTransfer(let tx):
            return tx.timestamp

        case .data(let tx):
            return tx.timestamp

        case .script(let tx):
            return tx.timestamp

        case .assetScript(let tx):
            return tx.timestamp
        }
    }

    var modified: Date {
        switch self {
        case .unrecognised(let tx):
            return tx.modified

        case .issue(let tx):
            return tx.modified

        case .transfer(let tx):
            return tx.modified

        case .reissue(let tx):
            return tx.modified

        case .burn(let tx):
            return tx.modified

        case .exchange(let tx):
            return tx.modified

        case .lease(let tx):
            return tx.modified

        case .leaseCancel(let tx):
            return tx.modified

        case .alias(let tx):
            return tx.modified

        case .massTransfer(let tx):
            return tx.modified

        case .data(let tx):
            return tx.modified

        case .script(let tx):
            return tx.modified

        case .assetScript(let tx):
            return tx.modified
        }
    }
}

