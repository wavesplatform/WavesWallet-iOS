//
//  NewAccountCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 17/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit


final class NewAccountCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationController: UINavigationController
    private var account: NewAccountTypes.DTO.Account?

    private let completed: ((NewAccountTypes.DTO.Account,Bool) -> Void)

    init(navigationController: UINavigationController, completed: @escaping ((NewAccountTypes.DTO.Account,Bool) -> Void)) {
        self.completed = completed
        self.navigationController = navigationController
    }

    func start() {
        let vc = StoryboardScene.NewAccount.newAccountViewController.instantiate()
        vc.output = self
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: NewAccountModuleOutput
extension NewAccountCoordinator: NewAccountModuleOutput {
    func userCompletedCreateAccount(_ account: NewAccountTypes.DTO.Account) {

        self.account = account
        showBackupCoordinator()
    }
}

// MARK: NewAccountModuleOutput
extension NewAccountCoordinator: NeedBackupModuleOutput {
    func userCompletedInteract(skipBackup: Bool) {

        if skipBackup {
            beginRegistration(needBackup: false)
        } else {
            beginRegistration(needBackup: true)
        }
    }
}

// MARK: Logic
extension NewAccountCoordinator {

    private func showBackupCoordinator() {
        guard let account = account else { return }
        let backup = BackupCoordinator(viewController: navigationController, seed: account.privateKey.words, completed: { [weak self] needBackup in
            self?.beginRegistration(needBackup: needBackup)
        })
        addChildCoordinator(childCoordinator: backup)
        backup.start()
    }

    private func beginRegistration(needBackup: Bool) {
        guard let account = account else { return }
        completed(account, needBackup)
    }
}
