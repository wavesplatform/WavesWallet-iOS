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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
//        let vc = StoryboardScene.NewAccount.newAccountViewController.instantiate()
//        vc.output = self
        let vc = StoryboardScene.NewAccount.newAccountPasscodeViewController.instantiate()
        vc.presenter = NewAccountPasscodePresenter()
//        navigationController.pushViewControllerAndSetLast(vc)
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


    }
}


//        let controller = storyboard?.instantiateViewController(withIdentifier: "NewAccountSecretPhraseViewController") as! NewAccountSecretPhraseViewController
//        navigationController?.pushViewControllerAndSetLast(controller)





//func showPassCode() {
//    outlet
//
//    //        let controller = StoryboardManager.ProfileStoryboard().instantiateViewController(withIdentifier: "PasscodeViewController") as! PasscodeViewController
//    //        controller.isCreatePasswordMode = true
//    //        navigationController?.pushViewController(controller, animated: true)
//    //        let controller = storyboard?.instantiateViewController(withIdentifier: "NewAccountBackupInfoViewController") as! NewAccountBackupInfoViewController
//    //        navigationController?.pushViewController(controller, animated: true)
//}
//    
