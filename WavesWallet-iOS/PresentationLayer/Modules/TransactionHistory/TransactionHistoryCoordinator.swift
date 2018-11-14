//
//  TransactionHistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryCoordinator: TransactionHistoryModuleInput {
    
    let transactions: [DomainLayer.DTO.SmartTransaction]
    let currentIndex: Int
    let navigationController: UINavigationController
    
    init(transactions: [DomainLayer.DTO.SmartTransaction],
         currentIndex: Int,
         navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        self.transactions = transactions
        self.currentIndex = currentIndex
    }
    
    private lazy var transactionHistoryViewController: TransactionHistoryViewController = {
        return TransactionHistoryModuleBuilder(output: self).build(input: self) as! TransactionHistoryViewController
    }()
    
    func start() {
        transactionHistoryViewController.transitioningDelegate = transactionHistoryViewController
        transactionHistoryViewController.modalPresentationStyle = .custom
        navigationController.present(transactionHistoryViewController, animated: true, completion: nil)
    }
}

extension TransactionHistoryCoordinator: TransactionHistoryModuleOutput {

    func transactionHistoryAddAddressToHistoryBook(address: String) {
        let vc = AddAddressBookModuleBuilder(output: self).build(input: AddAddressBook.DTO.Input(contact: nil, address: address))

        navigationController.dismiss(animated: true) {
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func transactionHistoryEditAddressToHistoryBook(address: String) {
        let vc = AddAddressBookModuleBuilder(output: self).build(input: AddAddressBook.DTO.Input(contact: nil, address: address))

        navigationController.dismiss(animated: true) {
            self.navigationController.pushViewController(vc, animated: true)
        }
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
