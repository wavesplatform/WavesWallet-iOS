//
//  SmartTransactionDTO+EncodingToString.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import WavesSDKExtensions

extension SmartTransaction {
    var allData: String {
        return "Transaction ID: \(id)\n"
            + typeData
            + dateData
            + senderData
            + recipientData
            + amountData
            + priceData
            + feeData
            + attachmentData
            + scriptAddress
    }

    private var titleData: String {
        switch kind {
        case .receive, .spamReceive:
            return "receive"

        case .selfTransfer:
            return "self transfer"

        case .sent:
            return "send"

        case .massSent:
            return "mass Transfer"

        case .massReceived, .spamMassReceived:
            return "mass received"

        case .startedLeasing:
            return "started leasing"

        case .incomingLeasing:
            return "incoming leasing"

        case .canceledLeasing:
            return "lease cancel"

        case .exchange:
            return "exchange"

        case .tokenGeneration:
            return "token generation"

        case .tokenBurn:
            return "token burn"

        case .tokenReissue:
            return "token reissue"

        case .createdAlias:
            return "create alias"

        case .unrecognisedTransaction:
            return "unrecognised transaction"

        case .data:
            return "data"

        case .script:
            return "script"

        case .assetScript:
            return "asset script"

        case .sponsorship:
            return "sponsor ship"

        case .invokeScript:
            return "invoke script"

        case .updateAssetInfo:
            return "update  asset Info"
        }
    }

    private var typeData: String {
        switch kind {
        case .receive,
             .sent,
             .spamReceive,
             .selfTransfer,
             .massSent,
             .massReceived,
             .spamMassReceived,
             .startedLeasing,
             .incomingLeasing,
             .canceledLeasing,
             .tokenGeneration,
             .tokenBurn,
             .tokenReissue,
             .createdAlias,
             .unrecognisedTransaction,
             .data,
             .script,
             .assetScript,
             .sponsorship,
             .updateAssetInfo,
             .invokeScript:

            return "Type: \(type) (\(titleData))\n"

        case let .exchange(tx):

            if tx.myOrder.kind == .sell {
                return "Type: \(type) (exchange-sell)\n"
            } else {
                return "Type: \(type) (exchange-buy)\n"
            }
        }
    }

    private var recipientAny: Address? {
        switch kind {
        case let .receive(tx):
            return tx.myAccount

        case let .sent(tx):
            return tx.recipient

        case let .spamReceive(tx):
            return tx.myAccount

        case let .selfTransfer(tx):
            return tx.recipient
            
        case .updateAssetInfo:
            return nil

        case .massSent:
            return nil

        case .massReceived:
            return nil

        case .spamMassReceived:
            return nil

        case let .startedLeasing(tx):
            return tx.account

        case let .incomingLeasing(tx):
            return tx.myAccount

        case let .canceledLeasing(tx):
            return tx.account

        case .exchange:
            return nil

        case .tokenGeneration:
            return nil

        case .tokenBurn:
            return nil

        case .tokenReissue:
            return nil

        case .createdAlias:
            return nil

        case .unrecognisedTransaction:
            return nil

        case .data:
            return nil

        case .script:
            return nil

        case .assetScript:
            return nil

        case .sponsorship:
            return nil

        case .invokeScript:
            return nil
        }
    }

    private var senderData: String {
        return "Sender: \(sender.address)\n"
    }

    private var dateData: String {
        let formatter = DateFormatter.uiSharedFormatter(key: TransactionCard.Constants.transactionCardDateFormatterKey)
        formatter.dateFormat = "dd.MM.yyyy at HH:mm"
        return "Date: \(formatter.string(from: timestamp))\n"
    }

    private var recipientData: String {
        guard let recipient = recipientAny else { return "" }
        return "Recipient: \(recipient.address)\n"
    }

    private var amountAssetAny: Asset? {
        switch kind {
        case let .receive(tx):
            return tx.asset

        case let .sent(tx):
            return tx.asset

        case let .spamReceive(tx):
            return tx.asset

        case let .selfTransfer(tx):
            return tx.asset

        case let .massSent(tx):
            return tx.asset

        case let .massReceived(tx):
            return tx.asset

        case let .spamMassReceived(tx):
            return tx.asset

        case let .startedLeasing(tx):
            return tx.asset

        case let .incomingLeasing(tx):
            return tx.asset

        case let .canceledLeasing(tx):
            return tx.asset

        case let .exchange(tx):
            return tx.myOrder.pair.amountAsset

        case let .tokenGeneration(tx):
            return tx.asset

        case let .tokenBurn(tx):
            return tx.asset

        case let .tokenReissue(tx):
            return tx.asset

        case .createdAlias:
            return nil

        case .unrecognisedTransaction:
            return nil

        case .data:
            return nil

        case .script:
            return nil

        case .assetScript:
            return nil

        case .sponsorship:
            return nil

        case .invokeScript:
            return nil
            
        case .updateAssetInfo:
            return nil
        }
    }

    private var amountAny: DomainLayer.DTO.Balance? {
        switch kind {
        case let .receive(tx):
            return tx.balance

        case let .sent(tx):
            return tx.balance

        case let .spamReceive(tx):
            return tx.balance

        case let .selfTransfer(tx):
            return tx.balance

        case let .massSent(tx):
            return tx.total

        case let .massReceived(tx):
            return tx.myTotal

        case let .spamMassReceived(tx):
            return tx.myTotal

        case let .startedLeasing(tx):
            return tx.balance

        case let .incomingLeasing(tx):
            return tx.balance

        case let .canceledLeasing(tx):
            return tx.balance

        case let .exchange(tx):
            return tx.myOrder.amount

        case let .tokenGeneration(tx):
            return tx.balance

        case let .tokenBurn(tx):
            return tx.balance

        case let .tokenReissue(tx):
            return tx.balance

        case .createdAlias:
            return nil

        case .unrecognisedTransaction:
            return nil

        case .data:
            return nil

        case .script:
            return nil

        case .assetScript:
            return nil

        case .sponsorship:
            return nil

        case .invokeScript:
            return nil
            
        case .updateAssetInfo:
            return nil
        }
    }

    private var amountData: String {
        guard let amount = amountAny else { return "" }
        guard let amountAsset = amountAssetAny else { return "" }
        return "Amount: \(amount.displayText) (\(amountAsset.id))\n"
    }

    private var priceData: String {
        if case let .exchange(tx) = kind {
            return "Price: \(tx.price.displayText)\nTotal Price: \(tx.total.displayText)\n"
        }

        return ""
    }

    private var feeData: String {
        return "Fee: \(totalFee.displayText) (\(feeAsset.id))\n"
    }

    private var attachmentAny: String? {
        switch kind {
        case let .receive(tx):
            return tx.attachment

        case let .sent(tx):
            return tx.attachment

        case let .spamReceive(tx):
            return tx.attachment

        case let .selfTransfer(tx):
            return tx.attachment

        case let .massSent(tx):
            return tx.attachment

        case let .massReceived(tx):
            return tx.attachment

        case let .spamMassReceived(tx):
            return tx.attachment

        case .startedLeasing:
            return nil

        case .incomingLeasing:
            return nil

        case .canceledLeasing:
            return nil

        case .exchange:
            return nil

        case .tokenGeneration:
            return nil

        case .tokenBurn:
            return nil

        case .tokenReissue:
            return nil

        case .createdAlias:
            return nil

        case .unrecognisedTransaction:
            return nil

        case .data:
            return nil

        case .script:
            return nil

        case .assetScript:
            return nil

        case .sponsorship:
            return nil

        case .invokeScript:
            return nil
        case .updateAssetInfo:
            return nil
        }
    }

    private var attachmentData: String {
        guard let attachment = attachmentAny else { return "" }
        guard !attachment.isEmpty else { return "" }

        return "Attachment: \(attachment)\n"
    }

    private var scriptAddress: String {
        switch kind {
        case let .invokeScript(tx):
            return "Script address: \(tx.scriptAddress)\n"
        default:
            return ""
        }
    }
}
