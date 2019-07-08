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

    private let navigationRouter: NavigationRouter
    private var account: NewAccountTypes.DTO.Account?

    private let completed: ((NewAccountTypes.DTO.Account, _ isSkipBackup: Bool) -> Void)

    init(navigationRouter: NavigationRouter, completed: @escaping ((NewAccountTypes.DTO.Account,Bool) -> Void)) {
        self.completed = completed
        self.navigationRouter = navigationRouter
    }

    func start() {
        let vc = StoryboardScene.NewAccount.newAccountViewController.instantiate()
        vc.output = self
        self.navigationRouter.pushViewController(vc, animated: true) { [weak self] in
            guard let self = self else { return }
            self.removeFromParentCoordinator()
        }
    }
}

// MARK: PresentationCoordinator

extension NewAccountCoordinator: PresentationCoordinator {

    enum Display {
        case backup
    }

    func showDisplay(_ display: Display) {
        switch display {
        case .backup:
            showBackupCoordinator()
        }
    }
}

// MARK: NewAccountModuleOutput
extension NewAccountCoordinator: NewAccountModuleOutput {
    func userCompletedCreateAccount(_ account: NewAccountTypes.DTO.Account) {

        self.account = account
        showDisplay(.backup)
    }
}

// MARK: NewAccountModuleOutput
extension NewAccountCoordinator: NeedBackupModuleOutput {
    func userCompletedInteract(skipBackup: Bool) {
        beginRegistration(isSkipBackup: skipBackup)
    }
}

private extension NewAccountCoordinator {

    private func showBackupCoordinator() {
        guard let account = account else { return }
        let backup = BackupCoordinator(seed: account.privateKey.words,
                                       behaviorPresentation: .modal(navigationRouter),
                                       hasShowNeedBackupView: true,
                                       completed: { [weak self] isSkipBackup in
                                        guard let self = self else { return }
                                        self.beginRegistration(isSkipBackup: isSkipBackup)
        })
        addChildCoordinatorAndStart(childCoordinator: backup)
    }

    private func beginRegistration(isSkipBackup: Bool) {
        guard let account = account else { return }
        completed(account, isSkipBackup)
    }
}
