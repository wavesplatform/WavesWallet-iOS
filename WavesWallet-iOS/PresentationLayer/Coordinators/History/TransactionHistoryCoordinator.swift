//
//  TransactionHistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

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
    private let router: NavigationRouter

    private var lastDisplay: Display?
    
    init(transactions: [DomainLayer.DTO.SmartTransaction],
         currentIndex: Int,
         router: NavigationRouter) {
        
        self.router = router
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
            router.present(transactionHistoryViewController, animated: true, completion: nil)

        case .addAddress(let address, _):

            let vc = AddAddressBookModuleBuilder(output: self).build(input: AddAddressBook.DTO.Input(kind: .add(address, isMutable: false)))
            router.dismiss(animated: true) { [weak self] in
                self?.router.pushViewController(vc)
            }

        case .editContact(let contact, _):

            let vc = AddAddressBookModuleBuilder(output: self).build(input: AddAddressBook.DTO.Input(kind: .edit(contact: contact,
                                                                                                                 isMutable: false)))
            router.dismiss(animated: true) { [weak self] in
                self?.router.pushViewController(vc)
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


// MARK: - StartLeasingModuleOutput
extension TransactionHistoryCoordinator: StartLeasingModuleOutput {
    
    func startLeasingDidSuccess(transaction: DomainLayer.DTO.SmartTransaction, kind: StartLeasingTypes.Kind) {
        
        switch kind {
        case .cancel:
            break
        //TODO: here can be logic
        default:
            break
        }
    }
}
// MARK: AddAddressBookModuleOutput
extension TransactionHistoryCoordinator: AddAddressBookModuleOutput {

    func transactionHistoryResendTransaction(_ transaction: DomainLayer.DTO.SmartTransaction) {
        switch transaction.kind {
        case .sent(let tx):
            router.dismiss(animated: false)
            
            let model = Send.DTO.InputModel.ResendTransaction(address: tx.recipient.address,
                                                             asset: tx.asset,
                                                             amount: tx.balance.money)
            let send = SendModuleBuilder().build(input: .resendTransaction(model))
            router.pushViewController(send)

        default:
            break
        }
    }

    func transactionHistoryCancelLeasing(_ transaction: DomainLayer.DTO.SmartTransaction) {
        
        switch transaction.kind {
        case .startedLeasing(let leasing):
            router.dismiss(animated: false)
            
            let cancelOrder = StartLeasingTypes.DTO.CancelOrder(leasingTX: transaction.id,
                                                               amount: leasing.balance.money)
            let vc = StartLeasingConfirmModuleBuilder(output: self).build(input: .cancel(cancelOrder))
            router.pushViewController(vc, animated: true)

        default:
            break
        }
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

        _ = self.router.popViewController(animated: true, completed: { [weak self] in
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
