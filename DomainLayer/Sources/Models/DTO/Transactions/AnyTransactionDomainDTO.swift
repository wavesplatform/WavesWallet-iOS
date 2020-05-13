//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

public enum AnyTransaction {
    case unrecognised(UnrecognisedTransaction)
    case issue(IssueTransaction)
    case transfer(TransferTransaction)
    case reissue(ReissueTransaction)
    case burn(BurnTransaction)
    case exchange(ExchangeTransaction)
    case lease(LeaseTransaction)
    case leaseCancel(LeaseCancelTransaction)
    case alias(AliasTransaction)
    case massTransfer(MassTransferTransaction)
    case data(DataTransaction)
    case script(ScriptTransaction)
    case assetScript(AssetScriptTransaction)
    case sponsorship(SponsorshipTransaction)
    case invokeScript(InvokeScriptTransaction)
}

public extension AnyTransaction {
    var status: TransactionStatus {
        switch self {
        case let .unrecognised(tx):
            return tx.status

        case let .issue(tx):
            return tx.status

        case let .transfer(tx):
            return tx.status

        case let .reissue(tx):
            return tx.status

        case let .burn(tx):
            return tx.status

        case let .exchange(tx):
            return tx.status

        case let .lease(tx):
            return tx.status

        case let .leaseCancel(tx):
            return tx.status

        case let .alias(tx):
            return tx.status

        case let .massTransfer(tx):
            return tx.status

        case let .data(tx):
            return tx.status

        case let .script(tx):
            return tx.status

        case let .assetScript(tx):
            return tx.status

        case let .sponsorship(tx):
            return tx.status

        case let .invokeScript(tx):
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
        case let .unrecognised(tx):
            return tx.id

        case let .issue(tx):
            return tx.id

        case let .transfer(tx):
            return tx.id

        case let .reissue(tx):
            return tx.id

        case let .burn(tx):
            return tx.id

        case let .exchange(tx):
            return tx.id

        case let .lease(tx):
            return tx.id

        case let .leaseCancel(tx):
            return tx.id

        case let .alias(tx):
            return tx.id

        case let .massTransfer(tx):
            return tx.id

        case let .data(tx):
            return tx.id

        case let .script(tx):
            return tx.id

        case let .assetScript(tx):
            return tx.id

        case let .sponsorship(tx):
            return tx.id

        case let .invokeScript(tx):
            return tx.id
        }
    }

    var timestamp: Date {
        switch self {
        case let .unrecognised(tx):
            return tx.timestamp

        case let .issue(tx):
            return tx.timestamp

        case let .transfer(tx):
            return tx.timestamp

        case let .reissue(tx):
            return tx.timestamp

        case let .burn(tx):
            return tx.timestamp

        case let .exchange(tx):
            return tx.timestamp

        case let .lease(tx):
            return tx.timestamp

        case let .leaseCancel(tx):
            return tx.timestamp

        case let .alias(tx):
            return tx.timestamp

        case let .massTransfer(tx):
            return tx.timestamp

        case let .data(tx):
            return tx.timestamp

        case let .script(tx):
            return tx.timestamp

        case let .assetScript(tx):
            return tx.timestamp

        case let .sponsorship(tx):
            return tx.timestamp

        case let .invokeScript(tx):
            return tx.timestamp
        }
    }

    var modified: Date {
        switch self {
        case let .unrecognised(tx):
            return tx.modified

        case let .issue(tx):
            return tx.modified

        case let .transfer(tx):
            return tx.modified

        case let .reissue(tx):
            return tx.modified

        case let .burn(tx):
            return tx.modified

        case let .exchange(tx):
            return tx.modified

        case let .lease(tx):
            return tx.modified

        case let .leaseCancel(tx):
            return tx.modified

        case let .alias(tx):
            return tx.modified

        case let .massTransfer(tx):
            return tx.modified

        case let .data(tx):
            return tx.modified

        case let .script(tx):
            return tx.modified

        case let .assetScript(tx):
            return tx.modified

        case let .sponsorship(tx):
            return tx.modified

        case let .invokeScript(tx):
            return tx.modified
        }
    }
}
