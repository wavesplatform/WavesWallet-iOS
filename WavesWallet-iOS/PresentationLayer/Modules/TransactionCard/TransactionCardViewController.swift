//
//  TransactionCardViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 04/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

private typealias Types = TransactionCard

protocol TransactionCardModuleOutput: AnyObject {

    func transactionCardAddContact(address: String)
    func transactionCardEditContact(contact: DomainLayer.DTO.Contact)

    func transactionCardResendTransaction(_ transaction: DomainLayer.DTO.SmartTransaction)
    func transactionCardCancelLeasing(_ transaction: DomainLayer.DTO.SmartTransaction)
    func transactionCardViewOnExplorer(_ transaction: DomainLayer.DTO.SmartTransaction)
}

protocol TransactionCardModuleInput: AnyObject {

    func addedContact(address: String, contact: DomainLayer.DTO.Contact)
    func editedContact(address: String, contact: DomainLayer.DTO.Contact)
    func deleteContact(address: String, contact: DomainLayer.DTO.Contact)
}

final class TransactionCardViewController: ModalScrollViewController, DataSourceProtocol {

    @IBOutlet var tableView: UITableView!
    
    override var scrollView: UIScrollView {
        return tableView!
    }
    
    private var rootView: TransactionCardView {
        return view as! TransactionCardView
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private var transaction: DomainLayer.DTO.SmartTransaction?

    var system: System<TransactionCard.State, TransactionCard.Event>!

    var sections: [TransactionCard.Section] = .init()

    weak var delegate: TransactionCardModuleOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.delegate = self


        system
            .start()            
            .drive(onNext: { [weak self] (state) in
                self?.update(state: state.core)
                self?.update(state: state.ui)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: ModalScrollViewContext
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {

        var inset: CGFloat = 0

        // TODO: presentedViewController == SLideVC

        if let vc = presentationController?.presentingViewController, vc.children.count > 1 {
            inset = vc.children[1].children.first?.children.first?.layoutInsets.top ?? 0
        }

        return size.height
//            - inset
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

// MARK: Private

extension TransactionCardViewController {

    private func update(state: Types.State.Core) {
        self.transaction = state.transaction
    }

    private func update(state: Types.State.UI) {

        switch state.action {
        case .update:
            self.sections = state.sections
            tableView.reloadData()

        case .insertRows:
            
            self.sections = state.sections

            //TODO: Insert
            UIView.transition(with: self.tableView, duration: 0.24, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }, completion: { (_) in

            })

        default:
            break
        }

    }

    private func updateContact(address: String, contact: DomainLayer.DTO.Contact?, isAdd: Bool) {

        if isAdd {
            self.delegate?.transactionCardAddContact(address: address)
        } else {
            if let contact = contact {
                self.delegate?.transactionCardEditContact(contact: contact)
            }
        }
    }

    private func handlerTapActionButton(_ button: TransactionCardActionsCell.Model.Button) {

        guard let transaction = self.transaction else { return }

        switch button {
        case .cancelLeasing:
            self.delegate?.transactionCardCancelLeasing(transaction)

        case .sendAgain:
            self.delegate?.transactionCardResendTransaction(transaction)

        case .copyAllData:
            UIPasteboard.general.string = transaction.allData

        case .copyTxID:
            break

        case .viewOnExplorer:
            self.delegate?.transactionCardViewOnExplorer(transaction)
        }
    }
}

// MARK: ModalRootViewDelegate

extension TransactionCardViewController: ModalRootViewDelegate {
    
    func modalHeaderView() -> UIView {
        
        let view = TransactionCardHeaderView.loadView()

        return view
    }
    
    func modalHeaderHeight() -> CGFloat {
        return 14
    }
}


// MARK: TransactionCardViewControllerInput

extension TransactionCardViewController: TransactionCardModuleInput {

    func deleteContact(address: String, contact: DomainLayer.DTO.Contact) {
        self.system?.send(.deleteContact(contact: contact))
    }

    func addedContact(address: String, contact: DomainLayer.DTO.Contact) {
        self.system?.send(.addContact(contact: contact))
    }

    func editedContact(address: String, contact: DomainLayer.DTO.Contact) {
        self.system?.send(.editContact(contact: contact))
    }
}

// MARK: UITableViewDataSource

extension TransactionCardViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = self[indexPath]

        switch row {
        case .general(let model):
            let cell: TransactionCardGeneralCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .address(let model):
            let cell:TransactionCardAddressCell = tableView.dequeueCell()
            cell.update(with: model)
            cell.tapAddressBookButton = { [weak self] (isAdd) in
                self?.updateContact(address: model.contactDetail.address,
                                    contact: model.contact,
                                    isAdd: isAdd)
            }

            return cell

        case .keyValue(let model):
            let cell: TransactionCardKeyValueCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .keyBalance(let model):
            let cell: TransactionCardKeyBalanceCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .status(let model):
            let cell: TransactionCardStatusCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .massSentRecipient(let model):
            let cell: TransactionCardMassSentRecipientCell = tableView.dequeueCell()
            cell.update(with: model)
            cell.tapAddressBookButton = { [weak self] (isAdd) in
                self?.updateContact(address: model.contactDetail.address,
                                    contact: model.contact,
                                    isAdd: isAdd)
            }

            return cell

        case .dashedLine(let model):
            let cell: TransactionCardDashedLineCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .actions(let model):
            let cell: TransactionCardActionsCell = tableView.dequeueCell()
            cell.update(with: model)
            cell.tapOnButton = { [weak self] (button)  in
                self?.handlerTapActionButton(button)
            }

            return cell

        case .description(let model):
            let cell: TransactionCardDescriptionCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .exchange(let model):
            let cell: TransactionCardExchangeCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .assetDetail(let model):
            let cell: TransactionCardAssetDetailCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .showAll(let model):
            let cell: TransactionCardShowAllCell = tableView.dequeueCell()
            cell.update(with: model)

            cell.didTapButtonShowAll = { [weak self] in
                self?.system?.send(.showAllRecipients)
            }

            return cell

        case .asset(let model):
            let cell: TransactionCardAssetCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .sponsorshipDetail(let model):
            let cell: TransactionCardSponsorshipDetailCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension TransactionCardViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
}

fileprivate extension DomainLayer.DTO.SmartTransaction {

    private func copyTransactionId() {
        UIPasteboard.general.string = id
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

        case .startedLeasing, .incomingLeasing:
            return "lease"

        case .canceledLeasing:
            return "lease cancel"

        case .exchange:
            return "exchange"

        case .tokenGeneration,
             .tokenBurn,
             .tokenReissue:
            return "burn"

        case .createdAlias:
            return "create Alias"

        case .unrecognisedTransaction:
            return "unrecognised Transaction"

        case .data:
            return "data"

        case .script:
            return "script"

        case .assetScript:
            return "asset Script"

        case .sponsorship:
            return "sponsorShip"
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
            return tx.account

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


//    Transaction ID: 2HBrA4DbMuLFNsZkujBZbcSn56KEg9LG7mZXov2ekPs3
//    Type: 7 (exchange-buy)
//    Date: 02/22/2019 14:22
//    Sender: 3PJaDyprvekvPXPuAtxrapacuDJopgJRaU3
//    Amount: 429.223176 Aloha (EXK2jJo1PbL9CUNr5FSedw6cueZH5MUCDXNhR1WQEZa4)
//    Price: 233 SmartAssetTrue (Aj3pbMJocAyfiNQP4utWkTDPg11eE4P2HL34LhTYkLdR)
//    Total price: 100 009.00000800 SmartAssetTrue
//    Fee: 0.007 Waves (WAVES)

    var allData: String {

        var data = "Transaction ID: \(id)\n" + typeData + dateData + senderData + recipientData + amountData + priceData + feeData + attachmentData
        return data
    }
//        let id = id
//        let kind = transaction.title
//        let sender = transaction.sender.address



//        var recipients = [String]()
//        var balance: Balance?
//
//
//        switch kind {
//        case .receive(let model):
//            recipients.append(model.recipient.address)
//            balance = model.balance
//
//        case .sent(let model):
//            recipients.append(model.recipient.address)
//            balance = model.balance
//
//        case .exchange(let model):
//            balance = model.total
//
//        case .selfTransfer(let model):
//            balance = model.balance
//
//        case .tokenGeneration(let model):
//            balance = model.balance
//
//        case .tokenReissue(let model):
//            balance = model.balance
//
//        case .tokenBurn(let model):
//            balance = model.balance
//
//        case .startedLeasing(let model):
//            recipients.append(model.account.address)
//            balance = model.balance
//
//        case .canceledLeasing(let model):
//            recipients.append(model.account.address)
//            balance = model.balance
//
//        case .incomingLeasing(let model):
//            recipients.append(model.account.address)
//            balance = model.balance
//
//        case .spamReceive(let model):
//            recipients.append(model.recipient.address)
//            balance = model.balance
//
//        case .massSent(let model):
//            recipients.append(contentsOf: model.transfers.map({ $0.recipient.address }))
//            balance = model.total
//
//        case .massReceived(let model):
////            recipients.append(contentsOf: model.transfers.map({ $0.recipient.address }))
////            balance = model.total
//
//        default:
//            break
//        }
//
//        let recipientsKeys = recipients.map { (recipient) -> [String: String] in
//            return [Localizable.Waves.Transactionhistory.Copy.recipient: recipient]
//        }
//
//        let date = Date()
//        let amount = balance?.displayText
////        let fee = transaction.totalFee
//
//        let keys: [[String: String]] = [[Localizable.Waves.Transactionhistory.Copy.transactionId: id],
//                                        [Localizable.Waves.Transactionhistory.Copy.type: kind],
//                                        [Localizable.Waves.Transactionhistory.Copy.date: date],
//                                        [Localizable.Waves.Transactionhistory.Copy.sender: sender]] + recipientsKeys +
//            [[Localizable.Waves.Transactionhistory.Copy.amount: amount ?? ""], [Localizable.Waves.Transactionhistory.Copy.fee: fee]]
//
//        UIPasteboard.general.string = keys.map({ (item) -> String in
//            let key = item.first!.key
//            let value = item.first!.value
//            return key + ": " + value
//        }).joined(separator: "\n")
//    }

}
