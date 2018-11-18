//
//  TransactionHistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryCoordinator: Coordinator {

    enum Display {
        case showTransactionHistory
        case addAddress(_ address: String, FinishedAddressBook)
        case editContact(_ contact: DomainLayer.DTO.Contact, FinishedAddressBook)
    }

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let transactions: [DomainLayer.DTO.SmartTransaction]
    private let currentIndex: Int
    private let navigationController: UINavigationController

    private var lastDisplay: Display?
    
    init(transactions: [DomainLayer.DTO.SmartTransaction],
         currentIndex: Int,
         navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        self.transactions = transactions
        self.currentIndex = currentIndex
    }
    
    private lazy var transactionHistoryViewController: TransactionHistoryViewController = {
        return TransactionHistoryModuleBuilder(output: self).build(input: .init(transactions: transactions, currentIndex: currentIndex)) as! TransactionHistoryViewController
    }()
    
    func start() {
        showDisplay(.showTransactionHistory)
    }
}

extension TransactionHistoryCoordinator: PresentationCoordinator {

    func showDisplay(_ display: Display) {

        self.lastDisplay = display

        switch display {
        case .showTransactionHistory:        
            transactionHistoryViewController.transitioningDelegate = transactionHistoryViewController
            transactionHistoryViewController.modalPresentationStyle = .custom
            navigationController.present(transactionHistoryViewController, animated: true, completion: nil)

        case .addAddress(let address, _):

            let vc = AddAddressBookModuleBuilder(output: self).build(input: AddAddressBook.DTO.Input(kind: .add(address, isMutable: false)))
            navigationController.dismiss(animated: true) {
                self.navigationController.pushViewController(vc, animated: true)
            }

        case .editContact(let contact, _):

            let vc = AddAddressBookModuleBuilder(output: self).build(input: AddAddressBook.DTO.Input(kind: .edit(contact: contact,
                                                                                                                 isMutable: false)))
            navigationController.dismiss(animated: true) {
                self.navigationController.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: TransactionHistoryModuleOutput

extension TransactionHistoryCoordinator: TransactionHistoryModuleOutput {

    func transactionHistoryAddAddressToHistoryBook(address: String, finished: @escaping FinishedAddressBook) {
        showDisplay(.addAddress(address, finished))
    }

    func transactionHistoryEditAddressToHistoryBook(contact: DomainLayer.DTO.Contact, finished: @escaping FinishedAddressBook) {
        showDisplay(.editContact(contact, finished))
    }
}


// MARK: AddAddressBookModuleOutput
extension TransactionHistoryCoordinator: AddAddressBookModuleOutput {

    func transactionHistoryResendTransaction(_ transaction: DomainLayer.DTO.SmartTransaction) {
        //TODO: resend transaction
    }

    func transactionHistoryCancelLeasing(_ transaction: DomainLayer.DTO.SmartTransaction) {

        let transactions = FactoryInteractors.instance.transactions

//        transactions.send(by: .lease(<#T##LeaseTransactionSender#>), wallet: <#T##DomainLayer.DTO.SignedWallet#>)
    }

    func addAddressBookDidEdit(contact: DomainLayer.DTO.Contact, newContact: DomainLayer.DTO.Contact) {
        finishedAddToAddressBook(contact: .update(newContact))
    }

    func addAddressBookDidCreate(contact: DomainLayer.DTO.Contact) {
        finishedAddToAddressBook(contact: .update(contact))
    }

    func addAddressBookDidDelete(contact: DomainLayer.DTO.Contact) {
        finishedAddToAddressBook(contact: .delete(contact))
    }
}

extension TransactionHistoryCoordinator {

    func finishedAddToAddressBook(contact: TransactionHistoryTypes.DTO.ContactState) {

        self.navigationController.popViewController(animated: true, completed: { [weak self] in
            self?.lastDisplay?.finishedAddressBook?(contact, true)
            self?.showDisplay(.showTransactionHistory)
        })
    }
}

// MARK: Assistant
extension TransactionHistoryCoordinator.Display {

    var finishedAddressBook: TransactionHistoryModuleOutput.FinishedAddressBook? {

        switch self {

        case .addAddress(_, let finishedAddressBook):
            return finishedAddressBook

        case .editContact(_, let finishedAddressBook):
            return finishedAddressBook

        default:
            return nil
        }
    }
}
