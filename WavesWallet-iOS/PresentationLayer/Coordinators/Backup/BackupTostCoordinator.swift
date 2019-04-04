//
//  BackupTostCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

extension Coordinator {

    func setupBackupTost(target: UIViewController, navigationRouter: NavigationRouter, disposeBag: DisposeBag) {

        target
            .rx
            .viewDidAppear
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showTost(navigationRouter: navigationRouter)
            })
            .disposed(by: disposeBag)

        target
            .rx
            .viewDidDisappear
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.hideTost()
            })
            .disposed(by: disposeBag)
    }

    private func showTost(navigationRouter: NavigationRouter) {
        let tost = BackupTostCoordinator(navigationRouter: navigationRouter)
        self.addChildCoordinatorAndStart(childCoordinator: tost)
    }

    private func hideTost() {
        childCoordinators.first(where: { (coordinator) -> Bool in
            return coordinator is BackupTostCoordinator
        })?.removeFromParentCoordinator()
    }
}


final class BackupTostCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private let disposeBag: DisposeBag = DisposeBag()
    private let authorization: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let navigationRouter: NavigationRouter
    private var snackBackupSeedKey: String?

    private static var lockMap: [String] = []

    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    func start() {

        self.authorization
            .authorizedWallet()
            .subscribe(onNext: { [weak self] (signedWallet) in
                guard let self = self else { return }
                self.showBackupTostIfNeed(signedWallet: signedWallet)
            })
            .disposed(by: disposeBag)
    }

    private func showBackupTostIfNeed(signedWallet: DomainLayer.DTO.SignedWallet) {

        guard let topViewController = navigationRouter.navigationController.topViewController else { return }
        guard signedWallet.wallet.isBackedUp == false else { return }

        if BackupTostCoordinator.lockMap.contains(signedWallet.address) {
            return
        }

        snackBackupSeedKey = topViewController.showWarningSnack(title: Localizable.Waves.General.Tost.Savebackup.title,
                                                                subtitle: Localizable.Waves.General.Tost.Savebackup.subtitle,
                                                                icon: Images.warning18White.image,
                                                                didTap:
            { [weak self] in
                guard let self = self else { return }
                BackupTostCoordinator.lockMap.append(signedWallet.address)
                let backupContainer = BackupContainer(navigationRouter: self.navigationRouter, signedWallet: signedWallet)
                self.parent?.addChildCoordinatorAndStart(childCoordinator: backupContainer)
        }) {
            BackupTostCoordinator.lockMap.append(signedWallet.address)
        }
    }

    private func hideBackupTost() {
        if let snackBackupSeedKey = self.snackBackupSeedKey {
            self.navigationRouter.navigationController.hideSnack(key: snackBackupSeedKey)
        }
    }

    deinit {
        hideBackupTost()
    }
}

final private class BackupContainer: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private let disposeBag: DisposeBag = DisposeBag()
    private let authorization: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let signedWallet: DomainLayer.DTO.SignedWallet
    private let navigationRouter: NavigationRouter

    init(navigationRouter: NavigationRouter, signedWallet: DomainLayer.DTO.SignedWallet) {
        self.signedWallet = signedWallet
        self.navigationRouter = navigationRouter
    }

    func start() {
        showBackup(signedWallet: signedWallet)
    }

    private func showBackup(signedWallet: DomainLayer.DTO.SignedWallet) {

        let seed = signedWallet.seedWords
        let backup = BackupCoordinator(seed: seed,
                                       behaviorPresentation: .push(navigationRouter),
                                       hasShowNeedBackupView: false) { [weak self] isSkipBackup in

                                        guard let self = self else { return }

                                        if isSkipBackup {
                                            return
                                        }

                                        let wallet = signedWallet.wallet.mutate {
                                            $0.isBackedUp = true
                                        }

                                        self
                                            .authorization
                                            .changeWallet(wallet)
                                            .subscribe()
                                            .disposed(by: self.disposeBag)
        }

        parent?.addChildCoordinatorAndStart(childCoordinator: backup)
    }
}
