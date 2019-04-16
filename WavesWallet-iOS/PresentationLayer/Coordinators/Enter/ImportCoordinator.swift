//
//  ImportCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import WavesSDKExtension
import WavesSDKCrypto

private enum Constants {
    static let duration: TimeInterval = 3
}

final class ImportCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationRouter: NavigationRouter
    private let completed: ((ImportTypes.DTO.Account) -> Void)

    private let disposeBag: DisposeBag = DisposeBag()
    private let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private var currentPrivateKeyAccount: PrivateKeyAccount?
    

    init(navigationRouter: NavigationRouter, completed: @escaping ((ImportTypes.DTO.Account) -> Void)) {
        self.navigationRouter = navigationRouter
        self.completed = completed
    }

    func start() {
        let vc = StoryboardScene.Import.importAccountViewController.instantiate() as ImportAccountViewController
        
        vc.scanViewController.delegate = self
        vc.manuallyViewController.delegate = self

        navigationRouter.pushViewController(vc, animated: true) { [weak self] in
            guard let self = self else { return }
            self.removeFromParentCoordinator()
        }        
    }
    
    // MARK: - Child Controllers
    
    func scannedSeed(_ seed: String) {
        guard seed.utf8.count >= UIGlobalConstants.minimumSeedLength else {
            navigationRouter.navigationController.topViewController?.showMessageSnack(title: Localizable.Waves.Enter.Button.Importaccount.Error.insecureSeed)
            return
        }

        let privateKeyAccount = PrivateKeyAccount(seedStr: seed)

        auth
            .existWallet(by: privateKeyAccount.getPublicKeyStr())
            .subscribe(onNext: { [weak self] wallet in
                guard let self = self else { return }
                self.navigationRouter.navigationController.topViewController?.showErrorSnackWithoutAction(tille: Localizable.Waves.Import.General.Error.alreadyinuse, duration: Constants.duration)
            }, onError: { [weak self] _ in
                guard let self = self else { return }
                self.showAccountPassword(privateKeyAccount)
            })
            .disposed(by: disposeBag)
    }
    
    func showQRCodeReader() {
        
        let qrcode = QRCodeReaderControllerCoordinator(navigationRouter: navigationRouter,
                                                       completionBlock:
            { [weak self] (result) in
                guard let self = self else { return }
                self.scannedSeed(result)
            })

        addChildCoordinatorAndStart(childCoordinator: qrcode)
    }
    
    func showAccountPassword(_ keyAccount: PrivateKeyAccount) {

        currentPrivateKeyAccount = keyAccount
        let vc = StoryboardScene.Import.importAccountPasswordViewController.instantiate()
        vc.delegate = self
        vc.address = keyAccount.address
        navigationRouter.pushViewController(vc)
    }
}

// MARK: ImportAccountViewControllerDelegate
extension ImportCoordinator: ImportAccountViewControllerDelegate {

    func scanTapped() {
        showQRCodeReader()
    }
}

// MARK: ImportWelcomeBackViewControllerDelegate
extension ImportCoordinator: ImportWelcomeBackViewControllerDelegate {
    
    func userCompletedInputSeed(_ keyAccount: PrivateKeyAccount) {
        currentPrivateKeyAccount = keyAccount
        showAccountPassword(keyAccount)
    }
}

// MARK: ImportAccountPasswordViewControllerDelegate
extension ImportCoordinator: ImportAccountPasswordViewControllerDelegate {
    
    func userCompletedInputAccountData(password: String, name: String) {

        guard let privateKeyAccount = currentPrivateKeyAccount else { return }

        completed(.init(privateKey: privateKeyAccount,
                        password: password,
                        name: name))
    }
}
