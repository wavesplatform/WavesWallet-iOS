//
//  SmartTransactionDTO+EncodingToString.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO.SmartTransaction {

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
             .sponsorship:
            return "Type: \(type) (\(titleData))\n"

        case .exchange(let tx):

            if tx.myOrder.kind == .sell {
                return "Type: \(type) (exchange-sell)\n"
            } else {
                return "Type: \(type) (exchange-buy)\n"
            }
        }
    }

    private var recipientAny: DomainLayer.DTO.Address? {

        switch kind {
        case .receive(let tx):
            return tx.recipient

        case .sent(let tx):
            return tx.recipient

        case .spamReceive(let tx):
            return tx.recipient

        case .selfTransfer(let tx):
            return tx.recipient

        case .massSent:
            return nil

        case .massReceived:
            return nil

        case .spamMassReceived:
            return nil

        case .startedLeasing(let tx):
            return tx.account

        case .incomingLeasing(let tx):
            return tx.myAccount

        case .canceledLeasing(let tx):
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
        }
    }

    private var senderData: String {
        return "Sender: \(sender.address)\n"
    }

    private var dateData: String {
        let formatter = DateFormatter.sharedFormatter
        formatter.dateFormat = "dd.MM.yyyy at HH:mm"
        return "Date: \(formatter.string(from: timestamp))\n"
    }

    private var recipientData: String {
        guard let recipient = self.recipientAny else { return "" }
        return "Recipient: \(recipient.address)\n"
    }

    private var amountAssetAny: Asset? {

        switch kind {
        case .receive(let tx):
            return tx.asset

        case .sent(let tx):
            return tx.asset

        case .spamReceive(let tx):
            return tx.asset

        case .selfTransfer(let tx):
            return tx.asset

        case .massSent(let tx):
            return tx.asset

        case .massReceived(let tx):
            return tx.asset

        case .spamMassReceived(let tx):
            return tx.asset

        case .startedLeasing(let tx):
            return tx.asset

        case .incomingLeasing(let tx):
            return tx.asset

        case .canceledLeasing(let tx):
            return tx.asset

        case .exchange(let tx):
            return tx.myOrder.pair.amountAsset

        case .tokenGeneration(let tx):
            return tx.asset

        case .tokenBurn(let tx):
            return tx.asset

        case .tokenReissue(let tx):
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
        }
    }

    private var amountAny: Balance? {

        switch kind {
        case .receive(let tx):
            return tx.balance

        case .sent(let tx):
            return tx.balance

        case .spamReceive(let tx):
            return tx.balance

        case .selfTransfer(let tx):
            return tx.balance

        case .massSent(let tx):
            return tx.total

        case .massReceived(let tx):
            return tx.myTotal

        case .spamMassReceived(let tx):
            return tx.myTotal

        case .startedLeasing(let tx):
            return tx.balance

        case .incomingLeasing(let tx):
            return tx.balance

        case .canceledLeasing(let tx):
            return tx.balance

        case .exchange(let tx):
            return tx.myOrder.amount

        case .tokenGeneration(let tx):
            return tx.balance

        case .tokenBurn(let tx):
            return tx.balance

        case .tokenReissue(let tx):
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
        }
    }

    private var amountData: String {

        guard let amount = self.amountAny else { return "" }
        guard let amountAsset = self.amountAssetAny else { return "" }
        return "Amount: \(amount.displayText) (\(amountAsset.id))\n"
    }

    private var priceData: String {

        if case .exchange(let tx) = kind {
            return "Price: \(tx.price.displayText)\nTotal Price: \(tx.total.displayText)\n"
        }

        return ""
    }

    private var feeData: String {
        return "Fee: \(totalFee.displayText) (\(feeAsset.id))\n"
    }

    private var attachmentAny: String? {

        switch kind {
        case .receive(let tx):
            return tx.attachment

        case .sent(let tx):
            return tx.attachment

        case .spamReceive(let tx):
            return tx.attachment

        case .selfTransfer(let tx):
            return tx.attachment

        case .massSent(let tx):
            return tx.attachment

        case .massReceived(let tx):
            return tx.attachment

        case .spamMassReceived(let tx):
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
        }
    }

    private var attachmentData: String {

        guard let attachment = self.attachmentAny else { return "" }
        guard attachment.count > 0 else { return "" }

        return "Attachment: \(attachment)\n"
    }
}
