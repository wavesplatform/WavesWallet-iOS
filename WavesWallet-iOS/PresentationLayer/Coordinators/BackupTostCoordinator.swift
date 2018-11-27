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

    func setupBackupTost(target: UIViewController, navigationController: UINavigationController, disposeBag: DisposeBag) {

        target.rx.viewDidAppear.asObservable().subscribe(onNext: { [weak self] _ in
            self?.showTost(navigationController: navigationController)
        }).disposed(by: disposeBag)

        target.rx.viewDidDisappear.asObservable().subscribe(onNext: { [weak self] _ in
            self?.hideTosh(navigationController: navigationController)
        }).disposed(by: disposeBag)
    }

    private func showTost(navigationController: UINavigationController) {
        let tost = BackupTostCoordinator(navigationController: navigationController)
        self.addChildCoordinatorAndStart(childCoordinator: tost)
    }

    private func hideTosh(navigationController: UINavigationController) {
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
    private weak var navigationController: UINavigationController?
    private var snackBackupSeedKey: String?

    private static var lockMap: [String] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {

        self.authorization
            .authorizedWallet()
            .subscribe(onNext: { [weak self] (signedWallet) in
                self?.showBackupTostIfNeed(signedWallet: signedWallet)
            })
            .disposed(by: disposeBag)
    }

    private func showBackupTostIfNeed(signedWallet: DomainLayer.DTO.SignedWallet) {

        guard let topViewController = navigationController?.topViewController else { return }
        guard signedWallet.wallet.isBackedUp == false else { return }

        if BackupTostCoordinator.lockMap.contains(signedWallet.address) {
            return
        }

        snackBackupSeedKey = topViewController.showWarningSnack(title: Localizable.Waves.General.Tost.Savebackup.title,
                                                                subtitle: Localizable.Waves.General.Tost.Savebackup.subtitle,
                                                                icon: Images.warning18White.image,
                                                                didTap:
            { [weak self] in
                BackupTostCoordinator.lockMap.append(signedWallet.address)
                self?.showBackup(signedWallet: signedWallet)
        }) {
            BackupTostCoordinator.lockMap.append(signedWallet.address)
        }
    }

    private func hideBackupTost() {
        if let snackBackupSeedKey = self.snackBackupSeedKey {
            self.navigationController?.hideSnack(key: snackBackupSeedKey)
        }
    }

    private func showBackup(signedWallet: DomainLayer.DTO.SignedWallet) {

        guard let navigationController = self.navigationController else { return }

        let seed = signedWallet.seedWords
        let backup = BackupCoordinator(navigationController: navigationController, seed: seed) { [weak self] isBackedUp in

            guard let owner = self else { return }

            if isBackedUp == false {
                self?.navigationController?.popViewController(animated: true)
                return
            }

            let wallet = signedWallet.wallet.mutate {
                $0.isBackedUp = isBackedUp
            }

            owner
                .authorization
                .changeWallet(wallet)
                .subscribe(onNext: { [weak self] (wallet) in
                    self?.navigationController?.popViewController(animated: true)
                    self?.hideBackupTost()
                })
                .disposed(by: owner.disposeBag)
        }
        addChildCoordinatorAndStart(childCoordinator: backup)
    }

    deinit {
        hideBackupTost()
    }
}
