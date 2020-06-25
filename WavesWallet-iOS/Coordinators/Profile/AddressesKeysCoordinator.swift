//
//  AddressesKeysCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import RxSwift
import UIKit

private enum Constants {
    static let popoverHeight: CGFloat = 378
}

final class AddressesKeysCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationRouter: NavigationRouter
    private let wallet: Wallet
    private var rootViewController: UIViewController?

    private let authorization = UseCasesFactory.instance.authorization
    private let disposeBag = DisposeBag()
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?
    private var currentPopup: PopupViewController?

    init(navigationRouter: NavigationRouter,
         wallet: Wallet,
         applicationCoordinator: ApplicationCoordinatorProtocol) {
        self.navigationRouter = navigationRouter
        self.wallet = wallet
        self.applicationCoordinator = applicationCoordinator
    }

    func start() {
        let vc = AddressesKeysModuleBuilder(output: self).build(input: .init(wallet: wallet))
        rootViewController = vc
        navigationRouter.pushViewController(vc, animated: true) { [weak self] in
            guard let self = self else { return }
            self.removeFromParentCoordinator()
        }
    }
}

// MARK: AddressesKeysModuleOutput

extension AddressesKeysCoordinator: AddressesKeysModuleOutput {
    func addressesKeysShowAliases(_ aliases: [DomainLayer.DTO.Alias]) {
        if aliases.isEmpty {
            let controller = StoryboardScene.Profile.aliasWithoutViewController.instantiate()
            controller.delegate = self
            let popup = PopupViewController()
            popup.contentHeight = Constants.popoverHeight
            popup.present(contentViewController: controller)
            currentPopup = popup
        } else {
            let controller = AliasesModuleBuilder(output: self).build(input: .init(aliases: aliases))
            let popup = PopupViewController()
            popup.present(contentViewController: controller)
            currentPopup = popup
        }
    }

    func addressesKeysNeedPrivateKey(wallet _: Wallet,
                                     callback: @escaping (SignedWallet?) -> Void) {
        authorization
            .authorizedWallet()
            .subscribe(onNext: { signedWallet in
                callback(signedWallet)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: AliasesModuleOutput

extension AddressesKeysCoordinator: AliasesModuleOutput {
    func aliasesCreateAlias() {
        currentPopup?.dismissPopup {
            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationRouter.pushViewController(vc)
            UseCasesFactory.instance.analyticManager.trackEvent(.alias(.createProfile))
        }
    }
}

// MARK: AliasWithoutViewControllerDelegate

extension AddressesKeysCoordinator: AliasWithoutViewControllerDelegate {
    func aliasWithoutUserTapCreateNewAlias() {
        currentPopup?.dismissPopup {
            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationRouter.pushViewController(vc, animated: true)
            UseCasesFactory.instance.analyticManager.trackEvent(.alias(.createProfile))
        }
    }
}

// MARK: CreateAliasModuleOutput

extension AddressesKeysCoordinator: CreateAliasModuleOutput {
    func createAliasCompletedCreateAlias(_: String) {
        if let rootViewController = self.rootViewController {
            navigationRouter.popToViewController(rootViewController, animated: true)
        }
    }
}
