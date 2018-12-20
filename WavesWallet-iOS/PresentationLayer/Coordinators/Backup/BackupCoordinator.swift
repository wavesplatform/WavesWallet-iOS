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

//    private let viewController: UIViewController
    private let navigationRouter: NavigationRouter
    private let modalNavigationRouter: NavigationRouter
    private let completed: ((Bool) -> Void)
    private let seed: [String]
//    private let hasExternalNavigationController: Bool

//    init(viewController: UIViewController, seed: [String], completed: @escaping ((Bool) -> Void)) {
//        self.seed = seed
//        self.viewController = viewController
//        self.completed = completed
//        self.navigationController = CustomNavigationController()
//        self.hasExternalNavigationController = false
//    }

    init(navigationRouter: NavigationRouter, seed: [String], completed: @escaping ((Bool) -> Void)) {
        self.seed = seed
        self.navigationRouter = navigationRouter
        self.completed = completed
        self.modalNavigationRouter = NavigationRouter(navigationController: CustomNavigationController())
    }

    func start()  {

//        if hasExternalNavigationController {
//            userReadedBackupInfo()
//        } else {

        let vc = StoryboardScene.Backup.needBackupViewController.instantiate()
        vc.output = self
        self.modalNavigationRouter.pushViewController(vc, animated: true)
        navigationRouter.present(self.modalNavigationRouter.navigationController)
    }

    private func completedBackup(skipBackup: Bool) {
        removeFromParentCoordinator()
        navigationRouter.dismiss(animated: true)
        completed(!skipBackup)
    }
}

// MARK: PresentationCoordinator

extension BackupCoordinator: PresentationCoordinator {

    enum Display {
        case confirmBackup
        case saveBackupPhrase
        case startBackup
    }

    func showDisplay(_ display: Display) {
        switch display {

        case .confirmBackup:
            let vc = StoryboardScene.Backup.confirmBackupViewController.instantiate()
            vc.input = .init(seed: seed)
            vc.output = self
            modalNavigationRouter.pushViewController(vc)

        case .saveBackupPhrase:
            let vc = StoryboardScene.Backup.saveBackupPhraseViewController.instantiate()
            vc.input = .init(seed: seed, isReadOnly: false)
            vc.output = self
            modalNavigationRouter.pushViewController(vc)

        case .startBackup:
            let vc = StoryboardScene.Backup.backupInfoViewController.instantiate()
            vc.output = self
            modalNavigationRouter.pushViewController(vc)
        }
    }

}

// MARK: NeedBackupModuleOutput

extension BackupCoordinator: NeedBackupModuleOutput {

    func userCompletedInteract(skipBackup: Bool) {

        if skipBackup {
            completedBackup(skipBackup: true)
        } else {
            showDisplay(.startBackup)
        }
    }
}

// MARK: BackupInfoViewModuleOutput

extension BackupCoordinator: BackupInfoViewModuleOutput {
    func userReadedBackupInfo() {
        showDisplay(.saveBackupPhrase)
    }
}

// MARK: SaveBackupPhraseOutput

extension BackupCoordinator: SaveBackupPhraseOutput {
    func userSavedBackupPhrase() {
        showDisplay(.confirmBackup)
    }
}

// MARK: ConfirmBackupOutput

extension BackupCoordinator: ConfirmBackupOutput {

    func userConfirmBackup() {
        completedBackup(skipBackup: false)
    }
}
