//
//  BackupCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 18/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class BackupCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    let viewController: UIViewController
    let navigationController: CustomNavigationController
    let completed: ((Bool) -> Void)
    let seed: [String]
    
    init(viewController: UIViewController, seed: [String], completed: @escaping ((Bool) -> Void)) {
        self.seed = seed
        self.viewController = viewController
        self.completed = completed
        navigationController = CustomNavigationController()
    }

    func start()  {

        let vc = StoryboardScene.Backup.needBackupViewController.instantiate()
        vc.output = self

        navigationController.viewControllers = [vc]
        viewController.present(navigationController, animated: true, completion: nil)
    }

    private func startBackup() {
        let vc = StoryboardScene.Backup.backupInfoViewController.instantiate()
        vc.output = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: NeedBackupModuleOutput

extension BackupCoordinator: NeedBackupModuleOutput {

    func userCompletedInteract(skipBackup: Bool) {

        if skipBackup {
            viewController.dismiss(animated: true) { [weak self] in
                self?.completed(true)
            }
        } else {
            startBackup()
        }
    }
}

// MARK: BackupInfoViewModuleOutput

extension BackupCoordinator: BackupInfoViewModuleOutput {
    func userReadedBackupInfo() {
        let vc = StoryboardScene.Backup.saveBackupPhraseViewController.instantiate()
        vc.input = .init(seed: seed)
        vc.output = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: SaveBackupPhraseOutput

extension BackupCoordinator: SaveBackupPhraseOutput {
    func userSavedBackupPhrase() {
        let vc = StoryboardScene.Backup.confirmBackupViewController.instantiate()
        vc.input = .init(seed: seed)
        vc.output = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: ConfirmBackupOutput

extension BackupCoordinator: ConfirmBackupOutput {

    func userConfirmBackup() {
        viewController.dismiss(animated: true) { [weak self] in
        }
        completed(false)
    }
}
