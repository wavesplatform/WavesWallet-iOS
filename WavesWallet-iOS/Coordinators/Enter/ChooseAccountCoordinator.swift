//
//  ChooseAccountCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

protocol ChooseAccountCoordinatorDelegate: AnyObject {
    func userChooseCompleted(wallet: DomainLayer.DTO.Wallet)
    func userDidTapBackButton()
}

final class ChooseAccountCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    weak var delegate: ChooseAccountCoordinatorDelegate?
    private let navigationRouter: NavigationRouter
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning { [weak self] in
        guard let self = self else { return }
    }
    
    init(navigationRouter: NavigationRouter, applicationCoordinator: ApplicationCoordinatorProtocol?) {
        self.navigationRouter = navigationRouter
        self.applicationCoordinator = applicationCoordinator
    }

    func start() {
        
        
        let vc = ChooseAccountModuleBuilder(output: self)
            .build(input: .init())
        navigationRouter.pushViewController(vc, animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.removeFromParentCoordinator()
        })
    }

    private func showEdit(wallet: DomainLayer.DTO.Wallet, animated: Bool = true) {
        let editCoordinator = EditAccountNameCoordinator(navigationRouter: navigationRouter, wallet: wallet)
        addChildCoordinatorAndStart(childCoordinator: editCoordinator)
    }

    private func showAccountPassword(kind: AccountPasswordTypes.DTO.Kind) {

        let vc = AccountPasswordModuleBuilder(output: self)
            .build(input: .init(kind: kind))
        navigationRouter.pushViewController(vc)
    }
    
    private func addOrImportAccountShow() {
        
        //TODO: Localization
        let elements: [ActionSheet.DTO.Element] =  [.init(title: "Add"),
                                                    .init(title: "Import")]
        
        let data = ActionSheet.DTO.Data.init(title: Localizable.Waves.Widgetsettings.Actionsheet.Changestyle.title,
                                             elements: elements,
                                             selectedElement: nil)
        
        let vc = ActionSheetViewBuilder { [weak self] (element) in
            
            guard let self = self else { return }
            
            self.navigationRouter.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                
                if element.title == "Add" {
                    self.showDisplay(.newAccount)
                } else {
                    self.showDisplay(.importAccount)
                }
            })
        }
        .build(input: data)
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning
        
        self.navigationRouter.present(vc, animated: true) {}
    }
    
    private func passcodeRegistration(with account: PasscodeTypes.DTO.Account) {
        
        let passcodeCoordinator = PasscodeCoordinator(kind: .registration(account), behaviorPresentation: .push(navigationRouter, dissmissToRoot: false))
        passcodeCoordinator.delegate = self
        
        addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)
    }
}

// MARK: PresentationCoordinator

extension ChooseAccountCoordinator: PresentationCoordinator {

    enum Display {
        case passcodeLogIn(DomainLayer.DTO.Wallet)
        case passcodeChangePasscode(DomainLayer.DTO.Wallet, password: String)
        case editAccountName(DomainLayer.DTO.Wallet)
        case accountPasswordLogIn(DomainLayer.DTO.Wallet)
        case passcodeRegistration(PasscodeTypes.DTO.Account)
        case importAccount
        case newAccount
    }

    func showDisplay(_ display: Display) {
        switch display {

        case .passcodeLogIn(let wallet):
            guard isHasCoordinator(type: PasscodeLogInCoordinator.self) != true else { return }

            let passcodeCoordinator = PasscodeLogInCoordinator(wallet: wallet, routerKind: .navigation(navigationRouter))
            passcodeCoordinator.delegate = self

            addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)

        case .passcodeChangePasscode(let wallet, let password):
            guard isHasCoordinator(type: PasscodeCoordinator.self) != true else { return }

            let passcodeCoordinator = PasscodeCoordinator(kind: .changePasscodeByPassword(wallet, password: password), behaviorPresentation: .push(navigationRouter, dissmissToRoot: true))
            passcodeCoordinator.delegate = self

            addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)

        case .editAccountName(let wallet):
            showEdit(wallet: wallet)

        case .accountPasswordLogIn(let wallet):
            showAccountPassword(kind: .logIn(wallet))
            
        case .passcodeRegistration(let account):
            passcodeRegistration(with: account)
            
        case .importAccount:
            let coordinator = ImportCoordinator(navigationRouter: navigationRouter) { [weak self] account in
                
                guard let self = self else { return }
                self.passcodeRegistration(with: .init(privateKey: account.privateKey,
                                              password: account.password,
                                              name: account.name,
                                              needBackup: false))
            }
            addChildCoordinatorAndStart(childCoordinator: coordinator)
            
        case .newAccount:
            let coordinator = NewAccountCoordinator(navigationRouter: navigationRouter) { [weak self] account, needBackup  in
                
                guard let self = self else { return }
                
                let account: PasscodeTypes.DTO.Account = .init(privateKey: account.privateKey,
                                                               password: account.password,
                                                               name: account.name,
                                                               needBackup: needBackup)
                
                self.showDisplay(.passcodeRegistration(account))
            }
            addChildCoordinatorAndStart(childCoordinator: coordinator)

        }
    }

}

// MARK: ChooseAccountModuleOutput
extension ChooseAccountCoordinator: ChooseAccountModuleOutput {
    
    func userChooseAccount(wallet: DomainLayer.DTO.Wallet, passcodeNotCreated: Bool) -> Void {
        if passcodeNotCreated {
            showDisplay(.accountPasswordLogIn(wallet))
        } else {
            showDisplay(.passcodeLogIn(wallet))
        }
    }
    
    func userEditAccount(wallet: DomainLayer.DTO.Wallet) {
        showDisplay(.editAccountName(wallet))
    }
    
    func chooseAccountDidTapBack() {    
        self.delegate?.userDidTapBackButton()
    }
    
    func chooseAccountDidTapAddAccount() {
        addOrImportAccountShow()
    }
}

// MARK: AccountPasswordModuleOutput
extension ChooseAccountCoordinator: AccountPasswordModuleOutput {

    func accountPasswordAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {
        showDisplay(.passcodeChangePasscode(wallet, password: password))
    }

    func accountPasswordVerifyAccess(signedWallet: DomainLayer.DTO.SignedWallet, password: String) {}
}

// MARK: PasscodeLogInCoordinatorDelegate
extension ChooseAccountCoordinator: PasscodeLogInCoordinatorDelegate {

    func passcodeCoordinatorLogInCompleted(wallet: DomainLayer.DTO.Wallet) {
        //TODO: Как бы сбросить состояние по другому?
        let index = self.navigationRouter
            .navigationController
            .viewControllers
            .enumerated()
            .first { $0.element is ChooseAccountViewController }
        
        if let index = index {
            let result = self.navigationRouter.navigationController.viewControllers.prefix(index.offset + 1)
            self.navigationRouter.navigationController.viewControllers = Array(result)
        }
        
        delegate?.userChooseCompleted(wallet: wallet)
        removeFromParentCoordinator()
    }
}

// MARK: PasscodeCoordinatorDelegate
extension ChooseAccountCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {}

    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet) {
        //TODO: Как бы сбросить состояние по другому?
//        self.navigationRouter.navigationController.viewControllers = self.viewControllers ?? []
        
        //TODO: Fix
        let index = self.navigationRouter
            .navigationController
            .viewControllers
            .enumerated()
            .first { $0.element is ChooseAccountViewController }
        
        if let index = index {
            let result = self.navigationRouter.navigationController.viewControllers.prefix(index.offset + 1)
            self.navigationRouter.navigationController.viewControllers = Array(result)
        }
        
        delegate?.userChooseCompleted(wallet: wallet)
        removeFromParentCoordinator()
    }

    func passcodeCoordinatorWalletLogouted() {
        //TODO: Как бы сбросить состояние по другому?
        let index = self.navigationRouter
            .navigationController
            .viewControllers
            .enumerated()
            .first { $0.element is ChooseAccountViewController }
        
        if let index = index {
            let result = self.navigationRouter.navigationController.viewControllers.prefix(index.offset + 1)
            self.navigationRouter.navigationController.viewControllers = Array(result)
        }
        
        self.applicationCoordinator?.showEnterDisplay()
        removeFromParentCoordinator()
    }
}
