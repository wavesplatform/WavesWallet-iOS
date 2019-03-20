//
//  TransactionCardSystem+Mapper.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 15/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

private struct Constants {
    static let maxVisibleRecipients: Int = 3
}

fileprivate typealias Types = TransactionCard

extension TransactionCardSystem {

    func section(by core: TransactionCard.State.Core) -> [TransactionCard.Section]  {
        return core.transaction.sections(core: core)
    }
}

fileprivate extension DomainLayer.DTO.SmartTransaction {

    func sections(core: TransactionCard.State.Core) -> [Types.Section] {

        switch self.kind {
        case .sent(let transfer):
            return sentSection(transfer: transfer, core: core)
            
        case .receive(let transfer):
            return receiveSection(transfer: transfer, core: core)

        case .spamReceive(let transfer):
            return spamReceiveSection(transfer: transfer, core: core)

        case .selfTransfer(let transfer):
            return selfTransferSection(transfer: transfer, core: core)

        case .massSent(let transfer):
            return massSentSection(transfer: transfer, core: core)

        case .massReceived(let massReceive):
            return massReceivedSection(transfer: massReceive, core: core)

        case .spamMassReceived(let massReceive):
            return massReceivedSection(transfer: massReceive, core: core)

        case .startedLeasing(let leasing):
            return leasingSection(transfer: leasing,
                                  title: Localizable.Waves.Transactioncard.Title.startedLeasing,
                                  titleContact: Localizable.Waves.Transactioncard.Title.sentTo,
                                  needCancelLeasing: true,
                                  core: core)

        case .canceledLeasing(let leasing):
            return leasingSection(transfer: leasing,
                                  title: Localizable.Waves.Transactioncard.Title.canceledLeasing,
                                  titleContact: Localizable.Waves.Transactioncard.Title.nodeAddress,
                                  needCancelLeasing: false,
                                  core: core)

        case .incomingLeasing(let leasing):
            return leasingSection(transfer: leasing,
                                  title: Localizable.Waves.Transactioncard.Title.startedLeasing,
                                  titleContact: Localizable.Waves.Transactioncard.Title.from,
                                  needCancelLeasing: false,
                                  core: core)

        case .exchange(let exchange):
            return exchangeSection(transfer: exchange)

        case .tokenGeneration(let issue):
            return issueSection(transfer: issue,
                                title: Localizable.Waves.Transactioncard.Title.tokenGeneration,
                                balanceSign: .none)

        case .tokenBurn(let issue):
            return issueSection(transfer: issue,
                                title: Localizable.Waves.Transactioncard.Title.tokenBurn,
                                balanceSign: .minus)

        case .tokenReissue(let issue):
            return issueSection(transfer: issue,
                                title: Localizable.Waves.Transactioncard.Title.tokenReissue,
                                balanceSign: .plus)

        case .createdAlias(let alias):
            return deffaultSection(title: Localizable.Waves.Transactioncard.Title.createAlias,
                                   description: alias)

        case .unrecognisedTransaction:
            return deffaultSection(title: Localizable.Waves.Transactioncard.Title.unrecognisedTransaction,
                                   description: "")

        case .data:
            return deffaultSection(title: Localizable.Waves.Transactioncard.Title.entryInBlockchain,
                                   description: Localizable.Waves.Transactioncard.Title.dataTransaction)

        case .script(let isHasScript):

            let description = isHasScript == true ? Localizable.Waves.Transactioncard.Title.setScriptTransaction : Localizable.Waves.Transactioncard.Title.cancelScriptTransaction

            return deffaultSection(title: Localizable.Waves.Transactioncard.Title.entryInBlockchain,
                                   description: description)

        case .assetScript(let asset):
            return setAssetScriptSection(asset: asset)

        case .sponsorship(let isEnabled, let asset):
            return sponsorshipSection(asset: asset, isEnabled: isEnabled)
            
        }
    }

    // MARK: - Sent Sections

    func sentSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer, core: TransactionCard.State.Core) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: Localizable.Waves.Transactioncard.Title.sent,
                               addressTitle: Localizable.Waves.Transactioncard.Title.sentTo,
                               balanceSign: .minus,
                               core: core,
                               needSendAgain: true)
    }

    // MARK: - Receive Sections
    func receiveSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer, core: TransactionCard.State.Core) ->  [Types.Section] {

        if transfer.hasSponsorship {
            return receivedSponsorshipSection(transfer: transfer)
        }

        return transferSection(transfer: transfer,
                               generalTitle: Localizable.Waves.Transactioncard.Title.received,
                               addressTitle: Localizable.Waves.Transactioncard.Title.receivedFrom,
                               balanceSign: .plus,
                               core: core)
    }

    // MARK: - SpamReceive Sections
    func spamReceiveSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer, core: TransactionCard.State.Core) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: Localizable.Waves.Transactioncard.Title.spamReceived,
                               addressTitle: Localizable.Waves.Transactioncard.Title.receivedFrom,
                               balanceSign: .plus,
                               core: core)
    }

    // MARK: - SelfTransfer Sections
    func selfTransferSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer, core: TransactionCard.State.Core) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: Localizable.Waves.Transactioncard.Title.selfTransfer,
                               addressTitle: Localizable.Waves.Transactioncard.Title.receivedFrom,
                               balanceSign: .plus,
                               core: core)
    }

    // MARK: - Sponsorship Sections
    func sponsorshipSection(asset: DomainLayer.DTO.SmartTransaction.Asset,
                            isEnabled: Bool) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let title = isEnabled == true ? Localizable.Waves.Transactioncard.Title.setSponsorship : Localizable.Waves.Transactioncard.Title.disableSponsorship

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

    // MARK: - Set Asset Script Sections
    func setAssetScriptSection(asset: DomainLayer.DTO.SmartTransaction.Asset) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: Localizable.Waves.Transactioncard.Title.entryInBlockchain,
                                                               info: .descriptionLabel(Localizable.Waves.Transactioncard.Title.setAssetScript))


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

    // MARK: - Received Sponsorship Sections
    func receivedSponsorshipSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        var rows: [Types.Row] = .init()


        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: Localizable.Waves.Transactioncard.Title.receivedSponsorship,
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


    // MARK: - Deffault Sections
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

    // MARK: - Issue Sections
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

    // MARK: - Exchange Sections
    func exchangeSection(transfer: DomainLayer.DTO.SmartTransaction.Exchange) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let myOrder = transfer.myOrder
        var sign: Balance.Sign = .none
        var title = ""

        let priceDisplayName = transfer.myOrder.pair.priceAsset.displayName
        let amountDisplayName = transfer.myOrder.pair.amountAsset.displayName

        if myOrder.kind == .sell {
            sign = .plus
            title = Localizable.Waves.Transactioncard.Title.Exchange.sell(amountDisplayName, priceDisplayName)
        } else {
            sign = .minus
            title = Localizable.Waves.Transactioncard.Title.Exchange.buy(amountDisplayName, priceDisplayName)
        }

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: title,
                                                               info: .balance(.init(balance: myOrder.total,
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

    // MARK: - Leasing Sections
    func leasingSection(transfer: DomainLayer.DTO.SmartTransaction.Leasing,
                        title: String,
                        titleContact: String = "",
                        needCancelLeasing: Bool,
                        core: Types.State.Core) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: title,
                                                               info: .balance(.init(balance: transfer.balance,
                                                                                    sign: .none,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])


        let address = transfer.account.address

        let contact = core.normalizedContact(by: address,
                                             externalContact: transfer.account.contact)

        let name = contact?.name

        let isEditName = name != nil

        let rowAddressModel = TransactionCardAddressCell.Model.init(contact: contact,
                                                                    contactDetail: .init(title: titleContact,
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

    // MARK: - Mass Received Sections
    func massReceivedSection(transfer: DomainLayer.DTO.SmartTransaction.MassReceive,
                             core: Types.State.Core) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title:  Localizable.Waves.Transactioncard.Title.massReceived,
                                                               info: .balance(.init(balance: transfer.myTotal,
                                                                                    sign: .plus,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        let isSpam = transfer.asset.isSpam

        var visibleRecipients: [DomainLayer.DTO.SmartTransaction.MassReceive.Transfer] = transfer.transfers

        if core.showingAllRecipients == false {
            visibleRecipients = Array(transfer.transfers.prefix(Constants.maxVisibleRecipients))
        }

        for element in visibleRecipients.enumerated() {
            let tx = element.element
            let rowRecipientModel = tx.createTransactionCardAddressCell(isSpam: isSpam, core: core)
            rows.append(.address(rowRecipientModel))
        }

        if core.showingAllRecipients == false && transfer.transfers.count > Constants.maxVisibleRecipients {
            rows.append(.showAll(TransactionCardShowAllCell.Model.init(countOtherTransactions: transfer.transfers.count - Constants.maxVisibleRecipients)))
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

    // MARK: - MassSent Sections
    func massSentSection(transfer: DomainLayer.DTO.SmartTransaction.MassTransfer,
                         core: Types.State.Core) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: Localizable.Waves.Transactioncard.Title.massSent,
                                                               info: .balance(.init(balance: transfer.total,
                                                                                    sign: .minus,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        var visibleTransfers: [DomainLayer.DTO.SmartTransaction.MassTransfer.Transfer] = transfer.transfers

        if core.showingAllRecipients == false {
            visibleTransfers = Array(transfer.transfers.prefix(Constants.maxVisibleRecipients))
        }


        for element in visibleTransfers.enumerated() {

            let rowRecipientModel = element
                .element
                .createTransactionCardMassSentRecipientModel(currency: transfer.total.currency,
                                                             number: element.offset + 1,
                                                             core: core)

            rows.append(.massSentRecipient(rowRecipientModel))
        }

        if core.showingAllRecipients == false  && transfer.transfers.count > Constants.maxVisibleRecipients {
            rows.append(.showAll(TransactionCardShowAllCell.Model.init(countOtherTransactions: transfer.transfers.count - Constants.maxVisibleRecipients)))
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

    // MARK: - Transfer Sections
    func transferSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer,
                         generalTitle: String,
                         addressTitle: String,
                         balanceSign: Balance.Sign,
                         core: TransactionCard.State.Core,
                         needSendAgain: Bool = false) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let isSpam = transfer.asset.isSpam

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: generalTitle,
                                                               info: .balance(.init(balance: transfer.balance,
                                                                                    sign: balanceSign,
                                                                                    style: .large)))

        let address = transfer.recipient.address

        let contact = core.normalizedContact(by: address,
                                             externalContact: transfer.recipient.contact)

        let name = contact?.name
        let isEditName = name != nil

        let rowAddressModel = TransactionCardAddressCell.Model.init(contact: contact,
                                                                    contactDetail: .init(title: addressTitle,
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
        return TransactionCardKeyValueCell.Model(key: Localizable.Waves.Transactioncard.Title.block, value: "\(height)")
    }

    var rowConfirmationsModel: TransactionCardKeyValueCell.Model {

        return TransactionCardKeyValueCell.Model(key: Localizable.Waves.Transactioncard.Title.confirmations, value: "\(String(describing: confirmationHeight))")
    }

    var rowFeeModel: TransactionCardKeyBalanceCell.Model {
        return TransactionCardKeyBalanceCell.Model(key: Localizable.Waves.Transactioncard.Title.fee, value: BalanceLabel.Model(balance: self.totalFee,
                                                                                         sign: nil,
                                                                                         style: .small))
    }

    var rowTimestampModel: TransactionCardKeyValueCell.Model {

        let formatter = DateFormatter.sharedFormatter
        formatter.dateFormat = Localizable.Waves.Transactioncard.Timestamp.format
        let timestampValue = formatter.string(from: timestamp)

        return TransactionCardKeyValueCell.Model(key: Localizable.Waves.Transactioncard.Title.timestamp, value: timestampValue)
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

extension Types.State.Core {

    func normalizedContact(by address: String, externalContact: DomainLayer.DTO.Contact?) -> DomainLayer.DTO.Contact? {

        if let mutation = contacts[address] {
            if case .contact(let newContact) = mutation {
                return newContact
            } else {
                return nil
            }
        } else {
            return externalContact
        }
    }
}

extension DomainLayer.DTO.SmartTransaction.MassReceive.Transfer {

    func createTransactionCardAddressCell(isSpam: Bool, core: TransactionCard.State.Core) -> TransactionCardAddressCell.Model {

        let address = recipient.address

        let contact = core.normalizedContact(by: address,
                                             externalContact: recipient.contact)

        let name = contact?.name
        let isEditName = name != nil

        let addressTitle = Localizable.Waves.Transactioncard.Title.receivedFrom

        let rowRecipientModel = TransactionCardAddressCell.Model
            .init(contact: recipient.contact,
                  contactDetail: .init(title: addressTitle,
                                       address: address,
                                       name: name),
                  isSpam: isSpam,
                  isEditName: isEditName)

        return rowRecipientModel
    }
}

extension DomainLayer.DTO.SmartTransaction.MassTransfer.Transfer {

    func createTransactionCardMassSentRecipientModel(currency: Balance.Currency,
                                                     number: Int,
                                                     core: TransactionCard.State.Core) -> TransactionCardMassSentRecipientCell.Model {

        let address = recipient.address

        let contact = core.normalizedContact(by: address,
                                             externalContact: recipient.contact)

        let name = contact?.name
        let isEditName = name != nil

        let balance = Balance(currency: currency,
                              money: amount)

        let addressTitle = Localizable.Waves.Transactioncard.Title.recipient("\(number)")

        let rowRecipientModel = TransactionCardMassSentRecipientCell.Model
            .init(contact: contact,
                  contactDetail: .init(title: addressTitle,
                                       address: address,
                                       name: name),
                  balance: .init(balance: balance,
                                 sign: .none,
                                 style: .small),
                  isEditName: isEditName)

        return rowRecipientModel
    }
}
