//
//  EnterCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 21/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol EnterCoordinatorDelegate: AnyObject {
    func userCompletedLogIn(wallet: DomainLayer.DTO.Wallet)
}

final class EnterCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let slideMenuRouter: SlideMenuRouter
    private let navigationRouter: NavigationRouter

    private var account: NewAccountTypes.DTO.Account?

    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    weak var delegate: EnterCoordinatorDelegate?

    init(slideMenuRouter: SlideMenuRouter, applicationCoordinator: ApplicationCoordinatorProtocol) {
        self.slideMenuRouter = slideMenuRouter
        self.navigationRouter = NavigationRouter(navigationController: CustomNavigationController())
        self.applicationCoordinator = applicationCoordinator
    }

    func start() {

        let enter = StoryboardScene.Enter.enterStartViewController.instantiate()
        enter.delegate = self
        navigationRouter.popAllAndSetRootViewController(enter)

        slideMenuRouter.setContentViewController(navigationRouter.navigationController)
    }
}

// MARK: PresentationCoordinator

extension EnterCoordinator: PresentationCoordinator {

    enum Display {
        case chooseAccount
        case importAccount
        case newAccount
        case passcodeRegistration(PasscodeTypes.DTO.Account)
    }

    func showDisplay(_ display: Display) {
        switch display {

        case .chooseAccount:
            showSignInAccount()

        case .importAccount:
            break

        case .newAccount:
            showNewAccount()

        case .passcodeRegistration(let account):
            showPasscode(with: account)
        }
    }

}

// MARK: EnterStartViewControllerDelegate

extension EnterCoordinator: EnterStartViewControllerDelegate {

    func showSignInAccount() {

        guard let applicationCoordinator = self.applicationCoordinator else { return }

        let chooseAccountCoordinator = ChooseAccountCoordinator(navigationRouter: navigationRouter,
                                                                applicationCoordinator: applicationCoordinator)
        chooseAccountCoordinator.delegate = self
        addChildCoordinatorAndStart(childCoordinator: chooseAccountCoordinator)
    }

    func showImportCoordinator() {
//        let coordinator = ImportCoordinator(navigationController: navigationController) { [weak self] account in
//            self?.showPasscode(with: .init(privateKey: account.privateKey,
//                                           password: account.password,
//                                           name: account.name,
//                                           needBackup: false))
//        }
//        addChildCoordinator(childCoordinator: coordinator)
//        coordinator.start()
    }

    func showNewAccount() {

        let coordinator = NewAccountCoordinator(navigationRouter: navigationRouter) { [weak self] account, needBackup  in
            let account: PasscodeTypes.DTO.Account = .init(privateKey: account.privateKey,
                                                           password: account.password,
                                                           name: account.name,
                                                           needBackup: needBackup)

            self?.showDisplay(.passcodeRegistration(account))
        }
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showPasscode(with account: PasscodeTypes.DTO.Account) {

        let passcodeCoordinator = PasscodeNewAccountCoordinator(navigationRouter: navigationRouter, account: account)
        passcodeCoordinator.delegate = self

        addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)        
    }
    
    func showLanguageCoordinator() {
//        let languageCoordinator = EnterLanguageCoordinator(parentController: navigationController)
//        addChildCoordinator(childCoordinator: languageCoordinator)
//        languageCoordinator.start()
    }
}

// MARK: PasscodeNewAccountCoordinatorDelegate
extension EnterCoordinator: PasscodeNewAccountCoordinatorDelegate {
    
    func passcodeCoordinatorCreatedWallet(wallet: DomainLayer.DTO.Wallet) {
        delegate?.userCompletedLogIn(wallet: wallet)
        removeFromParentCoordinator()
    }
}

// MARK: PasscodeCoordinatorDelegate
extension EnterCoordinator: ChooseAccountCoordinatorDelegate {

    func userChooseCompleted(wallet: DomainLayer.DTO.Wallet) {

        delegate?.userCompletedLogIn(wallet: wallet)
        removeFromParentCoordinator()
    }    

}
