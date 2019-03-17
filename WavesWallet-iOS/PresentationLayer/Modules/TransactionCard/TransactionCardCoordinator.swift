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

final class TransactionCardCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private var navigationRouter: NavigationRouter!
    private var cardNavigationRouter: NavigationRouter!
    private let disposeBag: DisposeBag = DisposeBag()

    private let popoverViewControllerTransitioning = ModalViewControllerTransitioning {

    }

    private let transaction: DomainLayer.DTO.SmartTransaction
    private var transactionCardViewControllerInput: TransactionCardViewControllerInput?

    init(transaction: DomainLayer.DTO.SmartTransaction, router: NavigationRouter) {
        self.transaction = transaction
        self.navigationRouter = router

        let nv = CustomNavigationController()
        cardNavigationRouter = NavigationRouter(navigationController: nv)
    }

    func start() {

        var callbackInput: ((TransactionCardViewControllerInput) -> Void) = { [weak self] (input) in
            self?.transactionCardViewControllerInput = input
        }

        let vc = TransactionCardBuilder(output: self).build(input: .init(transaction: transaction,
                                                                         callbackInput: callbackInput))
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning
        vc.navigationItem.isNavigationBarHidden = true

        cardNavigationRouter.viewController.modalPresentationStyle = .custom

        cardNavigationRouter.pushViewController(vc)
        navigationRouter.present(cardNavigationRouter.viewController, animated: true, completion: nil)
    }
}

extension TransactionCardCoordinator: TransactionCardViewControllerDelegate {

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
