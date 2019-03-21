//
//  TransactionCardSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 04/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxSwiftExt

private typealias Types = TransactionCard
final class TransactionCardSystem: System<TransactionCard.State, TransactionCard.Event> {

    private let transaction: DomainLayer.DTO.SmartTransaction

    init(transaction: DomainLayer.DTO.SmartTransaction) {
        self.transaction = transaction
    }

    override func initialState() -> State! {

        let core: State.Core = .init(transaction: transaction,
                                     contacts: .init(),
                                     showingAllRecipients: false)

        let sections = section(by: core)

        return State(ui: .init(sections: sections,
                               action: .update),
                     core: core)
    }

    override func internalFeedbacks() -> [Feedback] {
        return []
    }

    override func reduce(event: Event, state: inout State) {

        switch event {
        case .viewDidAppear:
            break

        case .showAllRecipients:

            guard var section = state.ui.sections.first else { return }
            guard let massTransferAny = state.core.transaction.massTransferAny else { return }
            guard let lastMassReceivedRowModel = state.ui.findLastMassReceivedRowModel() else { return }

            guard let lastMassReceivedRowIndex = state.ui.findLastMassReceivedRowIndex() else { return }

            let lastRowAddress = lastMassReceivedRowModel.contactDetail.address
            
            guard let transferIndex = massTransferAny.findTransferIndex(by: lastRowAddress) else { return }


            let count = max(0, massTransferAny.transfers.count)
            let results = massTransferAny.transfers[(transferIndex + 1)..<count]

            let newRows = results
                .enumerated()
                .map { $0.element.createTransactionCardMassSentRecipientModel(currency: massTransferAny.total.currency,
                                                                              number: lastMassReceivedRowIndex + $0.offset + 2,
                                                                              core: state.core) }
                .map { Types.Row.massSentRecipient($0) }

            let insertIndexPaths = [Int](0..<count).map {
                return IndexPath(row: $0 + lastMassReceivedRowIndex + 1, section: 0)
            }

            var newRowsAtSection = section.rows

            newRowsAtSection = newRowsAtSection.filter { (row) -> Bool in
                if case .showAll = row {
                    return false
                }

                return true
            }

            let deleteIndexPaths = section.rows.enumerated().filter { (offset, element) -> Bool in
                if case .showAll = element {
                    return true
                }

                return false
            }
            .map { IndexPath(row: $0.offset , section: 0) }

            newRowsAtSection.insert(contentsOf: newRows, at: lastMassReceivedRowIndex + 1)

            section.rows = newRowsAtSection
            state.core.showingAllRecipients = true
            state.ui.sections = [section]
            state.ui.action = .insertRows(rows: newRows,
                                          insertIndexPaths: insertIndexPaths,
                                          deleteIndexPaths: deleteIndexPaths)

        case .addContact(let contact):

            state.core.contacts[contact.address] = .contact(contact)
            let sections = section(by: state.core)
            state.ui.sections = sections
            state.ui.action = .update

        case .deleteContact(let contact):

            state.core.contacts[contact.address] = .deleted
            let sections = section(by: state.core)
            state.ui.sections = sections
            state.ui.action = .update


        case .editContact(let contact):

            state.core.contacts[contact.address] = .contact(contact)
            let sections = section(by: state.core)
            state.ui.sections = sections
            state.ui.action = .update

        default:
            break
        }
    }
}

fileprivate extension Types.State.UI {

    func findLastMassReceivedRowModel() -> TransactionCardMassSentRecipientCell.Model? {
        if let last = receivedRowsAny.last, case .massSentRecipient(let model) = last {
            return model
        }

        return nil
    }

    func findLastMassReceivedRowIndex() -> Int? {

        let list = rows.enumerated().filter { (element, model) -> Bool in

            switch model {
            case .massSentRecipient:
                return true

            default:
                return false

            }
        }

        return list.last?.offset
    }

    var receivedRowsAnyModel: [TransactionCardMassSentRecipientCell.Model] {

        return rows.map({ (row) -> TransactionCardMassSentRecipientCell.Model? in

            switch row {
            case .massSentRecipient(let model):
                return model

            default:
                return nil

            }
        })
        .compactMap { $0 }
    }

    var rows: [Types.Row] {
        return self.sections.first?.rows ?? []
    }

    var receivedRowsAny: [Types.Row] {

        return rows.filter { (row) -> Bool in
            switch row {
            case .massSentRecipient:
                return true

            default:
                return false

            }
        }
    }
}

fileprivate extension DomainLayer.DTO.SmartTransaction.MassTransfer {

    func findTransfer(by address: String) -> DomainLayer.DTO.SmartTransaction.MassTransfer.Transfer? {
        return transfers.first { $0.recipient.address == address }
    }

    func findTransferAddress(by address: String) -> String? {
        return transfers.first { $0.recipient.address == address }?.recipient.address
    }

    func findTransferIndex(by address: String) -> Int? {
        return transfers.enumerated().first { $0.element.recipient.address == address }?.offset
    }
}

fileprivate extension DomainLayer.DTO.SmartTransaction {


    var massTransferAny: MassTransfer? {

        switch kind {
        case .massSent(let massTransfer):
            return massTransfer

        default:
            return nil

        }
    }

}
