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
    static let wavesExplorerTransactionTestnetUrl = "https://stage.wavesexplorer.com/"
}

protocol TransactionCardCoordinatorDelegate: AnyObject {

    func transactionCardCoordinatorCanceledOrder(_ order: DomainLayer.DTO.Dex.MyOrder)
}

final class TransactionCardCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private var navigationRouter: NavigationRouter!
    private var cardNavigationRouter: NavigationRouter!
    private let disposeBag: DisposeBag = DisposeBag()

    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning { [weak self] in
        guard let self = self else { return }
        self.removeFromParentCoordinator()
    }

    private let kind: TransactionCard.Kind

    private var transactionCardViewControllerInput: TransactionCardModuleInput?

    weak var delegate: TransactionCardCoordinatorDelegate?

    init(transaction: DomainLayer.DTO.SmartTransaction, router: NavigationRouter) {
        self.kind = .transaction(transaction)
        self.navigationRouter = router

        let nv = CustomNavigationController()
        cardNavigationRouter = NavigationRouter(navigationController: nv)
    }

    init(kind: TransactionCard.Kind, router: NavigationRouter) {
        self.kind = kind
        self.navigationRouter = router

        let nv = CustomNavigationController()
        cardNavigationRouter = NavigationRouter(navigationController: nv)
    }

    func start() {

        let callbackInput: ((TransactionCardModuleInput) -> Void) = { [weak self] (input) in
            guard let self = self else { return }
            self.transactionCardViewControllerInput = input
        }

        let vc = TransactionCardBuilder(output: self)
            .build(input: .init(kind: self.kind,
                                callbackInput: callbackInput))

//        cardNavigationRouter.viewController.modalPresentationStyle = .custom
//        cardNavigationRouter.viewController.transitioningDelegate = popoverViewControllerTransitioning

//        cardNavigationRouter.pushViewController(vc)

        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning

        navigationRouter.present(vc, animated: true, completion: nil)
//        navigationRouter.present(cardNavigationRouter.viewController, animated: true, completion: nil)
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

    func transactionCardCanceledOrder(_ order: DomainLayer.DTO.Dex.MyOrder) {
        delegate?.transactionCardCoordinatorCanceledOrder(order)
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
        if ApplicationDebugSettings.isEnableStage {
            url = URL(string: "\(Constants.wavesExplorerTransactionTestnetUrl)\(transaction.id)")
        } else {
            url = URL(string: "\(Constants.wavesExplorerTransactionUrl)\(transaction.id)")
        }

        if let url = url {

            let vc = BrowserViewController(url: url)
            let nv = CustomNavigationController(rootViewController: vc)

            cardNavigationRouter.present(nv, animated: true, completion: nil)
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
