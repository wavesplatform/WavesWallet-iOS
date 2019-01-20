//
//  BackupCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 18/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class BackupCoordinator: Coordinator {

    enum BehaviorPresentation {
        case push(NavigationRouter)
        case modal(Router)

        var isPush: Bool {
            switch self {
            case .push:
                return true

            default:
                return false
            }
        }
    }

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let mainNavigationRouter: NavigationRouter
    private let hasShowNeedBackupView: Bool
    private let completed: ((_ isSkipBackup: Bool) -> Void)
    private let seed: [String]
    private let behaviorPresentation: BehaviorPresentation

    init(seed: [String],
         behaviorPresentation: BehaviorPresentation,
         hasShowNeedBackupView: Bool,
         completed: @escaping ((Bool) -> Void)) {

        self.seed = seed
        self.completed = completed
        self.hasShowNeedBackupView = hasShowNeedBackupView
        self.behaviorPresentation = behaviorPresentation

        switch behaviorPresentation {
        case .modal:
            mainNavigationRouter = NavigationRouter(navigationController: CustomNavigationController())

        case .push(let router):
            mainNavigationRouter = router
        }
    }

    func start()  {

        let firstViewController: UIViewController!

        if hasShowNeedBackupView {
            let needBackupViewController = StoryboardScene.Backup.needBackupViewController.instantiate()
            needBackupViewController.output = self
            firstViewController = needBackupViewController
        } else {
            let saveBackupPhraseViewController = StoryboardScene.Backup.saveBackupPhraseViewController.instantiate()
            saveBackupPhraseViewController.input = .init(seed: seed, isReadOnly: false)
            saveBackupPhraseViewController.output = self
            firstViewController = saveBackupPhraseViewController
        }

        switch behaviorPresentation {
        case .modal(let router):

            self.mainNavigationRouter.pushViewController(firstViewController)
            router.present(self.mainNavigationRouter.navigationController)

        case .push:
            mainNavigationRouter.pushViewController(firstViewController, animated: true) { [weak self] in
                self?.removeFromParentCoordinator()
            }
        }
    }

    private func completedBackup(isSkipBackup: Bool) {

        switch behaviorPresentation {
        case .modal:
            mainNavigationRouter.dismiss(animated: true)

        case .push:
            mainNavigationRouter.navigationController.popToRootViewController(animated: true)
        }
        completed(isSkipBackup)

        removeFromParentCoordinator()
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
            mainNavigationRouter.pushViewController(vc)

        case .saveBackupPhrase:
            let vc = StoryboardScene.Backup.saveBackupPhraseViewController.instantiate()
            vc.input = .init(seed: seed, isReadOnly: false)
            vc.output = self
            mainNavigationRouter.pushViewController(vc)

        case .startBackup:
            let vc = StoryboardScene.Backup.backupInfoViewController.instantiate()
            vc.output = self
            mainNavigationRouter.pushViewController(vc)
        }
    }

}

// MARK: NeedBackupModuleOutput

extension BackupCoordinator: NeedBackupModuleOutput {

    func userCompletedInteract(skipBackup: Bool) {

        if skipBackup {
            completedBackup(isSkipBackup: true)
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
        completedBackup(isSkipBackup: false)
    }
}
