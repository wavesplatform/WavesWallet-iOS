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

    private let completed: ((NewAccountTypes.DTO.Account) -> Void)

    init(navigationController: UINavigationController, completed: @escaping ((NewAccountTypes.DTO.Account) -> Void)) {
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
        let vc = StoryboardScene.Backup.needBackupViewController.instantiate()
        vc.output = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: NewAccountModuleOutput
extension NewAccountCoordinator: NeedBackupModuleOutput {
    func userCompletedInteract(skipBackup: Bool) {

        if skipBackup {
            beginRegistration()
        } else {
            showBackupCoordinator()
        }
    }
}

// MARK: Logic
extension NewAccountCoordinator {

    private func showBackupCoordinator() {
        guard let account = account else { return }
        let backup = BackupCoordinator(viewController: navigationController, seed: account.privateKey.words, completed: { [weak self] in
            self?.beginRegistration()
        })
        addChildCoordinator(childCoordinator: backup)
        backup.start()
    }

    private func beginRegistration() {
        guard let account = account else { return }
        completed(account)
    }
}

extension NewAccountCoordinator: PasscodeOutput {

}
