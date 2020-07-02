//
//  EnterCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 21/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import UIKit

protocol EnterCoordinatorDelegate: AnyObject {
    func userCompletedLogIn(wallet: Wallet)
}

final class EnterCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let windowRouter: WindowRouter
    private let navigationRouter: NavigationRouter

    private var account: NewAccountTypes.DTO.Account?

    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    weak var delegate: EnterCoordinatorDelegate?
        
    init(windowRouter: WindowRouter, applicationCoordinator: ApplicationCoordinatorProtocol) {
        self.windowRouter = windowRouter
        navigationRouter = NavigationRouter(navigationController: CustomNavigationController())
        self.applicationCoordinator = applicationCoordinator
    }

    func start() {
            
        let enter = StoryboardScene.Enter.enterStartViewController.instantiate()
        enter.delegate = self
                
        navigationRouter.pushViewController(enter,
                                            animated: false)
        
        windowRouter.setRootViewController(navigationRouter,
                                           animated: nil)
    }
}

// MARK: PresentationCoordinator

extension EnterCoordinator: PresentationCoordinator {
    enum Display {
        case chooseAccount
        case importAccount
        case newAccount
        case passcodeRegistration(PasscodeTypes.DTO.Account)
        case changeLanguage
    }

    func showDisplay(_ display: Display) {
        switch display {
        case .chooseAccount:
            showSignInAccount()

        case .importAccount:
            let coordinator = ImportCoordinator(navigationRouter: navigationRouter) { [weak self] account in

                guard let self = self else { return }
                self.showPasscode(with: .init(privateKey: account.privateKey,
                                              password: account.password,
                                              name: account.name,
                                              needBackup: false))
            }
            addChildCoordinatorAndStart(childCoordinator: coordinator)

        case .newAccount:
            let coordinator = NewAccountCoordinator(navigationRouter: navigationRouter) { [weak self] account, needBackup in

                guard let self = self else { return }

                let account: PasscodeTypes.DTO.Account = .init(privateKey: account.privateKey,
                                                               password: account.password,
                                                               name: account.name,
                                                               needBackup: needBackup)

                self.showDisplay(.passcodeRegistration(account))
            }
            addChildCoordinatorAndStart(childCoordinator: coordinator)

        case let .passcodeRegistration(account):
            showPasscode(with: account)

        case .changeLanguage:
            let languageCoordinator = EnterLanguageCoordinator()
            addChildCoordinatorAndStart(childCoordinator: languageCoordinator)
        }
    }
}

// MARK: EnterStartViewControllerDelegate

extension EnterCoordinator: EnterStartViewControllerDelegate {
    func showDebug() {
        let vc = StoryboardScene.Support.debugViewController.instantiate()
        vc.delegate = self
        let nv = CustomNavigationController()
        nv.viewControllers = [vc]
        nv.modalPresentationStyle = .fullScreen
        navigationRouter.present(nv, animated: true, completion: nil)
    }

    func showSignInAccount() {
        guard let applicationCoordinator = self.applicationCoordinator else { return }

        let chooseAccountCoordinator = ChooseAccountCoordinator(navigationRouter: navigationRouter,
                                                                applicationCoordinator: applicationCoordinator)
        chooseAccountCoordinator.delegate = self
        addChildCoordinatorAndStart(childCoordinator: chooseAccountCoordinator)
    }

    func showImportCoordinator() {
        showDisplay(.importAccount)
    }

    func showNewAccount() {
        showDisplay(.newAccount)
    }

    func showPasscode(with account: PasscodeTypes.DTO.Account) {
        let behaviorPresentation: PasscodeCoordinator.BehaviorPresentation = .push(navigationRouter,
                                                                                   dissmissToRoot: false)
        let passcodeCoordinator = PasscodeCoordinator(kind: .registration(account),
                                                      behaviorPresentation: behaviorPresentation)
        passcodeCoordinator.delegate = self
        addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)
    }

    func showLanguageCoordinator() {
        showDisplay(.changeLanguage)
    }
}

// MARK: PasscodeCoordinatorDelegate

extension EnterCoordinator: PasscodeCoordinatorDelegate {
    func passcodeCoordinatorAuthorizationCompleted(wallet: Wallet) {
        delegate?.userCompletedLogIn(wallet: wallet)
        removeFromParentCoordinator()
    }

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet _: SignedWallet) {}

    func passcodeCoordinatorWalletLogouted() {}
}

// MARK: PasscodeCoordinatorDelegate

extension EnterCoordinator: ChooseAccountCoordinatorDelegate {
    func userChooseCompleted(wallet: Wallet) {
        delegate?.userCompletedLogIn(wallet: wallet)
        removeFromParentCoordinator()
    }

    func userDidTapBackButton() {
        navigationRouter.popViewController()
    }
}

// MARK: DebugViewControllerDelegate

extension EnterCoordinator: DebugViewControllerDelegate {
    func relaunchApplication() {}

    func dissmissDebugVC(isNeedRelaunchApp _: Bool) {
        navigationRouter.dismiss(animated: true, completion: nil)
    }
}
