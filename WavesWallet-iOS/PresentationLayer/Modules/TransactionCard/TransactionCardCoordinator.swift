//
//  TransactionCardCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 16/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

private struct Constants {
    static let wavesExplorerTransactionUrl = "https://wavesexplorer.com/tx/"
    static let wavesExplorerTransactionTestnetUrl = "https://wavesexplorer.com/testnet/tx/"
}

final class TransactionCardCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private var navigationRouter: NavigationRouter!
    private var cardNavigationRouter: NavigationRouter!
    private let disposeBag: DisposeBag = DisposeBag()

    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning { [weak self] in
        self?.removeFromParentCoordinator()
    }
    
    private let transaction: DomainLayer.DTO.SmartTransaction
    private var transactionCardViewControllerInput: TransactionCardModuleInput?

    init(transaction: DomainLayer.DTO.SmartTransaction, router: NavigationRouter) {
        self.transaction = transaction
        self.navigationRouter = router

        let nv = CustomNavigationController()
        cardNavigationRouter = NavigationRouter(navigationController: nv)
    }

    func start() {

        let callbackInput: ((TransactionCardModuleInput) -> Void) = { [weak self] (input) in
            self?.transactionCardViewControllerInput = input
        }

        let vc = TransactionCardBuilder(output: self).build(input: .init(transaction: transaction,
                                                                         callbackInput: callbackInput))

        cardNavigationRouter.viewController.modalPresentationStyle = .custom
        cardNavigationRouter.viewController.transitioningDelegate = popoverViewControllerTransitioning

        cardNavigationRouter.pushViewController(vc)

        navigationRouter.present(cardNavigationRouter.viewController, animated: true, completion: nil)
    }
}

// MARK: StartLeasingErrorDelegate

extension TransactionCardCoordinator: StartLeasingModuleOutput {

    func startLeasingDidSuccess(transaction: DomainLayer.DTO.SmartTransaction, kind: StartLeasingTypes.Kind) {
        
    }
}

// MARK: TransactionCardViewControllerDelegate

extension TransactionCardCoordinator: TransactionCardModuleOutput {
    
    func transactionCardViewDismissCard() {
        navigationRouter.dismiss(animated: true, completion: nil)
    }

    func transactionCardAddContact(address: String) {

        let vc = AddAddressBookModuleBuilder(output: self)
            .build(input: AddAddressBook.DTO.Input(kind: .add(address, isMutable: false)))
            self.cardNavigationRouter.pushViewController(vc)
    }

    func transactionCardEditContact(contact: DomainLayer.DTO.Contact) {

        let vc = AddAddressBookModuleBuilder(output: self)
            .build(input: AddAddressBook.DTO.Input(kind:.edit(contact: contact,
                                                              isMutable: false)))
        self.cardNavigationRouter.pushViewController(vc)
    }

    func transactionCardCancelLeasing(_ transaction: DomainLayer.DTO.SmartTransaction) {
        guard let leasing = transaction.startedLeasing else { return }

        let cancelOrder = StartLeasingTypes.DTO.CancelOrder(leasingTX: transaction.id,
                                                            amount: leasing.balance.money,
                                                            fee: Money(0, 0))

        let vc = StartLeasingConfirmModuleBuilder(output: self, errorDelegate: nil).build(input: .cancel(cancelOrder))
        cardNavigationRouter.pushViewController(vc)
    }

    func transactionCardResendTransaction(_ transaction: DomainLayer.DTO.SmartTransaction) {
        guard let tx = transaction.sent else { return }


        let model = Send.DTO.InputModel.ResendTransaction(address: tx.recipient.address,
                                                          asset: tx.asset,
                                                          amount: tx.balance.money)
        let send = SendModuleBuilder().build(input: .resendTransaction(model))
        cardNavigationRouter.pushViewController(send)
    }

    func transactionCardViewOnExplorer(_ transaction: DomainLayer.DTO.SmartTransaction) {

        var url: URL?
        if Environment.isTestNet {
            url = URL(string: "\(Constants.wavesExplorerTransactionTestnetUrl)\(transaction.id)")
        } else {
            url = URL(string: "\(Constants.wavesExplorerTransactionUrl)\(transaction.id)")
        }

        if let url = url {
            let vc = BrowserViewController(url: url)
            cardNavigationRouter.pushViewController(vc)
        }

    }
}

// MARK: AddAddressBookModuleOutput

extension TransactionCardCoordinator: AddAddressBookModuleOutput {

    func addAddressBookDidEdit(contact: DomainLayer.DTO.Contact, newContact: DomainLayer.DTO.Contact) {
        transactionCardViewControllerInput?.editedContact(address: newContact.address, contact: newContact)
    }

    func addAddressBookDidCreate(contact: DomainLayer.DTO.Contact) {
        transactionCardViewControllerInput?.addedContact(address: contact.address, contact: contact)
    }

    func addAddressBookDidDelete(contact: DomainLayer.DTO.Contact) {
        transactionCardViewControllerInput?.deleteContact(address: contact.address, contact: contact)
    }
}

fileprivate extension DomainLayer.DTO.SmartTransaction {

    var startedLeasing: DomainLayer.DTO.SmartTransaction.Leasing? {

        switch kind {
        case .startedLeasing(let leasing):
            return leasing

        default:
            return nil
        }
    }

    var sent: DomainLayer.DTO.SmartTransaction.Transfer? {

        switch kind {
        case .sent(let tx):
            return tx

        default:
            return nil
        }
    }
}
