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
        transactionHistoryViewController.transitioningDelegate = transactionHistoryViewController
        transactionHistoryViewController.modalPresentationStyle = .custom
        navigationController.present(transactionHistoryViewController, animated: true, completion: nil)
    }
}

extension TransactionHistoryCoordinator: PresentationCoordinator {

    func showDisplay(_ display: Display) {

        self.lastDisplay = display

        switch display {
        case .showTransactionHistory:
            break

        case .addAddress(let address, let finishedAddressBook):

            let vc = AddAddressBookModuleBuilder(output: self).build(input: AddAddressBook.DTO.Input(kind: .add(address, isMutable: false)))
            navigationController.dismiss(animated: true) {
                self.navigationController.pushViewController(vc, animated: true)
            }

        case .editContact(let contact, let finishedAddressBook):

            let vc = AddAddressBookModuleBuilder(output: self).build(input: AddAddressBook.DTO.Input(kind: .edit(contact: contact,
                                                                                                                 isMutable: false)))

            navigationController.dismiss(animated: true) {
                self.navigationController.pushViewController(vc, animated: true)
            }
        }
    }
}

extension TransactionHistoryCoordinator: TransactionHistoryModuleOutput {

    func transactionHistoryAddAddressToHistoryBook(address: String, finished: @escaping FinishedAddressBook) {
        showDisplay(.addAddress(address, finished))
    }

    func transactionHistoryEditAddressToHistoryBook(contact: DomainLayer.DTO.Contact, finished: @escaping FinishedAddressBook) {
        showDisplay(.editContact(contact, finished))
    }
}

extension TransactionHistoryCoordinator: AddAddressBookModuleOutput {

    func addAddressBookDidEdit(contact: DomainLayer.DTO.Contact, newContact: DomainLayer.DTO.Contact) {

    }

    func addAddressBookDidCreate(contact: DomainLayer.DTO.Contact) {

    }

    func addAddressBookDidDelete(contact: DomainLayer.DTO.Contact) {

    }
}
