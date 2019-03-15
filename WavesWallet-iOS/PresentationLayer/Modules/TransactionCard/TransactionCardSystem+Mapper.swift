//
//  TransactionCardSystem+Mapper.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 15/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension TransactionCardSystem {

    func section(by transaction: DomainLayer.DTO.SmartTransaction) -> [TransactionCard.Section]  {
        return transaction.sections
    }
}

fileprivate typealias Types = TransactionCard

fileprivate extension DomainLayer.DTO.SmartTransaction {



    var sections: [Types.Section] {

        switch self.kind {
        case .sent(let transfer):
            return sentSection(transfer: transfer)
            
        case .receive(let transfer):
            return receiveSection(transfer: transfer)

        case .spamReceive(let transfer):
            return spamReceiveSection(transfer: transfer)

        case .selfTransfer(let transfer):
            return selfTransferSection(transfer: transfer)

        case .massSent(let transfer):
            return massSentSection(transfer: transfer)

        case .massReceived(let massReceive):
            return massReceivedSection(transfer: massReceive)

        case .spamMassReceived(let massReceive):
            return massReceivedSection(transfer: massReceive)

        case .startedLeasing(let leasing):
            return leasingSection(transfer: leasing,
                                  title: "Started Leasing",
                                  needCancelLeasing: true)

        case .canceledLeasing(let leasing):
            return leasingSection(transfer: leasing,
                                  title: "Canceled Leasing",
                                  needCancelLeasing: false)

        case .incomingLeasing(let leasing):
            return leasingSection(transfer: leasing,
                                  title: "Incoming Leasing",
                                  needCancelLeasing: false)

        case .exchange(let exchange):
            return exchangeSection(transfer: exchange)

        case .tokenGeneration(let issue):
            return issueSection(transfer: issue,
                                title: "Token Generation",
                                balanceSign: .none)

        case .tokenBurn(let issue):
            return issueSection(transfer: issue,
                                title: "Token Burn",
                                balanceSign: .minus)

        case .tokenReissue(let issue):
            return issueSection(transfer: issue,
                                title: "Token Reissue",
                                balanceSign: .plus)

        case .createdAlias(let alias):
            return deffaultSection(title: "Create Alias",
                                   description: alias)

        case .unrecognisedTransaction:
            return deffaultSection(title: "Unrecognised Transaction",
                                   description: "")

        case .data:
            return deffaultSection(title: "Entry in blockchain",
                                   description: "Data transaction")

        case .script(let isHasScript):

            let description = isHasScript == true ? "Set Script Transaction" : "Cancel Script Transaction"

            return deffaultSection(title: "Entry in blockchain",
                                   description: description)

        case .assetScript(let asset):
            return setAssetScriptSection(asset: asset)

        case .sponsorship(let isEnabled, let asset):
            return sponsorshipSection(asset: asset, isEnabled: isEnabled)
            
        }
    }

    // MARK: Sent Sections

    func sentSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: "Sent",
                               addressTitle: "Sent to",
                               balanceSign: .minus,
                               needSendAgain: true)
    }

    // MARK: Receive Sections
    func receiveSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        if transfer.hasSponsorship {
            return receivedSponsorshipSection(transfer: transfer)
        }

        return transferSection(transfer: transfer,
                               generalTitle: "Received",
                               addressTitle: "Received from",
                               balanceSign: .plus)
    }

    // MARK: SpamReceive Sections
    func spamReceiveSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: "Spam Received",
                               addressTitle: "Received from",
                               balanceSign: .plus)
    }

    // MARK: SelfTransfer Sections
    func selfTransferSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: "Self-transfer",
                               addressTitle: "Received from",
                               balanceSign: .plus)
    }

    // MARK: Sponsorship Sections
    func sponsorshipSection(asset: DomainLayer.DTO.SmartTransaction.Asset,
                            isEnabled: Bool) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let title = isEnabled == true ? "Set Sponsorship" : "Disable Sponsorship"

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: title,
                                                               info: .descriptionLabel(asset.displayName))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        let rowAssetModel = TransactionCardAssetDetailCell.Model.init(assetId: asset.id,
                                                                      isReissuable: nil)

        rows.append(.assetDetail(rowAssetModel))

        let balance = Balance(currency: .init(title: asset.displayName,
                                              ticker: asset.ticker),
                              money: Money(asset.minSponsoredFee,
                                           asset.precision))

        if isEnabled {
            let rowSponsorshipModel = TransactionCardSponsorshipDetailCell
                .Model(balance: .init(balance: balance,
                                      sign: .none,
                                      style: .small))

            rows.append(.sponsorshipDetail(rowSponsorshipModel))
        }

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()


        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])


        let rowActionsModel = TransactionCardActionsCell.Model(buttons: [.viewOnExplorer, .copyTxID, .copyAllData])



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    // MARK: Set Asset Script Sections
    func setAssetScriptSection(asset: DomainLayer.DTO.SmartTransaction.Asset) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: "Entry in blockchain",
                                                               info: .descriptionLabel("Set Asset Script"))


        let rowAssetModel = TransactionCardAssetCell.Model.init(asset: asset)

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()

        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])

        let rowActionsModel = TransactionCardActionsCell.Model(buttons: buttonsActions)

        rows.append(contentsOf:[.general(rowGeneralModel),
                                .asset(rowAssetModel),
                                .keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    // MARK: Received Sponsorship Sections
    func receivedSponsorshipSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: "Received Sponsorship",
                                                               info: .balance(.init(balance: transfer.balance,
                                                                                    sign: .plus,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        let rowAssetModel = TransactionCardAssetDetailCell.Model.init(assetId: transfer.asset.id,
                                                                      isReissuable: nil)

        rows.append(.assetDetail(rowAssetModel))

        if let attachment = transfer.attachment, attachment.count > 0 {
            let rowDescriptionModel = TransactionCardDescriptionCell.Model.init(description: attachment)
            rows.append(.description(rowDescriptionModel))
        }

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()

        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])

        let rowActionsModel = TransactionCardActionsCell.Model(buttons: buttonsActions)



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }


    // MARK: Deffault Sections
    func deffaultSection(title: String,
                         description: String) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: title,
                                                               info: .descriptionLabel(description))

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()

        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])

        let rowActionsModel = TransactionCardActionsCell.Model(buttons: buttonsActions)

        rows.append(contentsOf:[.general(rowGeneralModel),
                                .dashedLine(.nonePadding),
                                .keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    // MARK: Issue Sections
    func issueSection(transfer: DomainLayer.DTO.SmartTransaction.Issue,
                      title: String,
                      balanceSign: Balance.Sign) ->  [Types.Section] {

        var rows: [Types.Row] = .init()


        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: title,
                                                               info: .balance(.init(balance: transfer.balance,
                                                                                    sign: balanceSign,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        let rowAssetModel = TransactionCardAssetDetailCell.Model.init(assetId: transfer.asset.id,
                                                                      isReissuable: transfer.asset.isReusable)

        rows.append(.assetDetail(rowAssetModel))

        if let description = transfer.description, description.count > 0 {
            let rowDescriptionModel = TransactionCardDescriptionCell.Model.init(description: description)
            rows.append(.description(rowDescriptionModel))
        }

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()


        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])


        let rowActionsModel = TransactionCardActionsCell.Model(buttons: [.viewOnExplorer, .copyTxID, .copyAllData])



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    // MARK: Exchange Sections
    func exchangeSection(transfer: DomainLayer.DTO.SmartTransaction.Exchange) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let myOrder = transfer.myOrder
        var sign: Balance.Sign = .none
        var title = ""

        let priceDisplayName = transfer.myOrder.pair.priceAsset.displayName
        let amountDisplayName = transfer.myOrder.pair.amountAsset.displayName

        if myOrder.kind == .sell {
            sign = .minus
            title = "Sell: \(amountDisplayName)/\(priceDisplayName)"
        } else {
            sign = .plus
            title = "Buy: \(amountDisplayName)/\(priceDisplayName)"
        }

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: title,
                                                               info: .balance(.init(balance: myOrder.amount,
                                                                                    sign: sign,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        let rowExchangeModel = TransactionCardExchangeCell.Model.init(sell: .init(balance: transfer.sell.amount,
                                                                                  sign: .none,
                                                                                  style: .small),
                                                                      price: .init(balance: transfer.buy.price,
                                                                                   sign: .none,
                                                                                   style: .small))

        rows.append(contentsOf:[.exchange(rowExchangeModel)])

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()


        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])


        let rowActionsModel = TransactionCardActionsCell.Model(buttons: [.viewOnExplorer, .copyTxID, .copyAllData])



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    // MARK: Leasing Sections
    func leasingSection(transfer: DomainLayer.DTO.SmartTransaction.Leasing,
                        title: String,
                        needCancelLeasing: Bool) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: title,
                                                               info: .balance(.init(balance: transfer.balance,
                                                                                    sign: .none,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        let name = transfer.account.contact?.name
        let address = transfer.account.address
        let isEditName = name != nil

        let rowAddressModel = TransactionCardAddressCell.Model.init(contactDetail: .init(title: "Node address",
                                                                                         address: address,
                                                                                         name: name),
                                                                    isSpam: transfer.asset.isSpam,
                                                                    isEditName: isEditName)

        rows.append(contentsOf:[.address(rowAddressModel)])

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()

        if needCancelLeasing {
            //TODO: cancelLeasing
            buttonsActions.append(.sendAgain)
        }

        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])


        let rowActionsModel = TransactionCardActionsCell.Model(buttons: [.viewOnExplorer, .copyTxID, .copyAllData])



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    // MARK: Mass Received Sections
    func massReceivedSection(transfer: DomainLayer.DTO.SmartTransaction.MassReceive) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: "Mass Received",
                                                               info: .balance(.init(balance: transfer.total,
                                                                                    sign: .minus,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        let isSpam = transfer.asset.isSpam

        for element in transfer.transfers.prefix(3).enumerated() {
            let tx = element.element
            let rowRecipientModel = tx.createTransactionCardAddressCell(isSpam: isSpam)
            rows.append(.address(rowRecipientModel))
        }

        if transfer.transfers.count > 3 {
            rows.append(.showAll(TransactionCardShowAllCell.Model.init(countOtherTransactions: transfer.transfers.count - 3)))
        }


        if let attachment = transfer.attachment, attachment.count > 0 {
            let rowDescriptionModel = TransactionCardDescriptionCell.Model.init(description: attachment)
            rows.append(.description(rowDescriptionModel))
        }

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()

        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])

        let rowActionsModel = TransactionCardActionsCell.Model(buttons: [.viewOnExplorer, .copyTxID, .copyAllData])



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    // MARK: MassSent Sections
    func massSentSection(transfer: DomainLayer.DTO.SmartTransaction.MassTransfer) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: "Mass sent",
                                                               info: .balance(.init(balance: transfer.total,
                                                                                    sign: .minus,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        for element in transfer.transfers.prefix(3).enumerated() {

            let rowRecipientModel = element
                .element
                .createTransactionCardMassSentRecipientModel(currency: transfer.total.currency,
                                                             number: element.offset + 1)

            rows.append(.massSentRecipient(rowRecipientModel))
        }

        if transfer.transfers.count > 3 {
            rows.append(.showAll(TransactionCardShowAllCell.Model.init(countOtherTransactions: transfer.transfers.count - 3)))
        }


        if let attachment = transfer.attachment, attachment.count > 0 {
            let rowDescriptionModel = TransactionCardDescriptionCell.Model.init(description: attachment)
            rows.append(.description(rowDescriptionModel))
        }

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()

        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])

        let rowActionsModel = TransactionCardActionsCell.Model(buttons: [.viewOnExplorer, .copyTxID, .copyAllData])



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    // MARK: Transfer Sections
    func transferSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer,
                         generalTitle: String,
                         addressTitle: String,
                         balanceSign: Balance.Sign,
                         needSendAgain: Bool = false) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let isSpam = transfer.asset.isSpam

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: generalTitle,
                                                               info: .balance(.init(balance: transfer.balance,
                                                                                    sign: balanceSign,
                                                                                    style: .large)))

        let name = transfer.recipient.contact?.name
        let address = transfer.recipient.address
        let isEditName = name != nil

        let rowAddressModel = TransactionCardAddressCell.Model.init(contactDetail: .init(title: addressTitle,
                                                                                         address: address,
                                                                                         name: name),
                                                                    isSpam: isSpam,
                                                                    isEditName: isEditName)

        rows.append(contentsOf:[.general(rowGeneralModel),
                                .address(rowAddressModel)])


        if let attachment = transfer.attachment, attachment.count > 0 {
            let rowDescriptionModel = TransactionCardDescriptionCell.Model.init(description: attachment)
            rows.append(.description(rowDescriptionModel))
        }

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()

        if needSendAgain {
            buttonsActions.append(.sendAgain)
        }

        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])

        let rowActionsModel = TransactionCardActionsCell.Model(buttons: buttonsActions)



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    var rowBlockModel: TransactionCardKeyValueCell.Model {
        let height = self.height ?? 0
        return TransactionCardKeyValueCell.Model(key: "Block", value: "\(height)")
    }

    var rowConfirmationsModel: TransactionCardKeyValueCell.Model {

        return TransactionCardKeyValueCell.Model(key: "Confirmations", value: "\(String(describing: confirmationHeight))")
    }

    var rowFeeModel: TransactionCardKeyBalanceCell.Model {
        return TransactionCardKeyBalanceCell.Model(key: "Fee", value: BalanceLabel.Model(balance: self.totalFee,
                                                                                         sign: nil,
                                                                                         style: .small))
    }

    var rowTimestampModel: TransactionCardKeyValueCell.Model {

        let formatter = DateFormatter.sharedFormatter
        formatter.dateFormat = "dd.MM.yyyy at HH:mm"
        let timestampValue = formatter.string(from: timestamp)

        return TransactionCardKeyValueCell.Model(key: "Timestamp", value: timestampValue)
    }

    var rowStatusModel: TransactionCardStatusCell.Model {
        switch status {
        case .activeNow:
            return .activeNow

        case .completed:
            return .completed

        case .unconfirmed:
            return .unconfirmed
        }
    }
}

extension DomainLayer.DTO.SmartTransaction.MassReceive.Transfer {

    func createTransactionCardAddressCell(isSpam: Bool) -> TransactionCardAddressCell.Model {

        let name = recipient.contact?.name
        let address = recipient.address
        let isEditName = name != nil

        let addressTitle = "Received from"

        let rowRecipientModel = TransactionCardAddressCell.Model
            .init(contactDetail: .init(title: addressTitle,
                                       address: address,
                                       name: name),
                  isSpam: isSpam,
                  isEditName: isEditName)

        return rowRecipientModel
    }
}

extension DomainLayer.DTO.SmartTransaction.MassTransfer.Transfer {

    func createTransactionCardMassSentRecipientModel(currency: Balance.Currency, number: Int) -> TransactionCardMassSentRecipientCell.Model {

        let name = recipient.contact?.name
        let address = recipient.address
        let isEditName = name != nil

        let balance = Balance(currency: currency,
                              money: amount)

        let addressTitle = "#\(number) Recipient"

        let rowRecipientModel = TransactionCardMassSentRecipientCell.Model
            .init(contactDetail: .init(title: addressTitle,
                                       address: address,
                                       name: name),
                  balance: .init(balance: balance,
                                 sign: .none,
                                 style: .small),
                  isEditName: isEditName)

        return rowRecipientModel
    }
}
