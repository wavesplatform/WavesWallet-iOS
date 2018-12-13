//
//  AddressesKeysCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum Constants {
    static let popoverHeight: CGFloat = 378
}

final class AddressesKeysCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationController: UINavigationController
    private let wallet: DomainLayer.DTO.Wallet    
    private var rootViewController: UIViewController?

    private let authorization = FactoryInteractors.instance.authorization
    private let disposeBag: DisposeBag = DisposeBag()
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?
    private var currentPopup: PopupViewController?

    init(navigationController: UINavigationController, wallet: DomainLayer.DTO.Wallet, applicationCoordinator: ApplicationCoordinatorProtocol) {
        self.navigationController = navigationController
        self.wallet = wallet
        self.applicationCoordinator = applicationCoordinator
    }

    func start() {
        let vc = AddressesKeysModuleBuilder(output: self).build(input: .init(wallet: wallet))
        self.rootViewController = vc
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: AddressesKeysModuleOutput

extension AddressesKeysCoordinator: AddressesKeysModuleOutput {

    func addressesKeysShowAliases(_ aliases: [DomainLayer.DTO.Alias]) {

        if aliases.count == 0 {
            let controller = StoryboardScene.Profile.aliasWithoutViewController.instantiate()
            controller.delegate = self
            let popup = PopupViewController()
            popup.contentHeight = Constants.popoverHeight
            popup.present(contentViewController: controller)
            self.currentPopup = popup
        } else {
            let controller = AliasesModuleBuilder.init(output: self).build(input: .init(aliases: aliases))
            let popup = PopupViewController()            
            popup.present(contentViewController: controller)
            self.currentPopup = popup
        }
    }

    func addressesKeysNeedPrivateKey(wallet: DomainLayer.DTO.Wallet, callback: @escaping ((DomainLayer.DTO.SignedWallet?) -> Void)) {

        authorization
            .authorizedWallet()
            .subscribe(onNext: { (signedWallet) in
                callback(signedWallet)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: AliasesModuleOutput

extension AddressesKeysCoordinator: AliasesModuleOutput {
    func aliasesCreateAlias() {

        self.currentPopup?.dismissPopup {
            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
}

// MARK: AliasWithoutViewControllerDelegate

extension AddressesKeysCoordinator: AliasWithoutViewControllerDelegate {
    func aliasWithoutUserTapCreateNewAlias() {
        self.currentPopup?.dismissPopup {
            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
}

// MARK: CreateAliasModuleOutput

extension AddressesKeysCoordinator: CreateAliasModuleOutput {
    func createAliasCompletedCreateAlias(_ alias: String) {
        if let rootViewController = self.rootViewController {
            navigationController.popToViewController(rootViewController, animated: true)
        }
    }
}


