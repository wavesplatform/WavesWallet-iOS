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
    var parent: Coordinator?

    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
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
    func userCompletedCreateAccount(_ account: NewAccount.DTO.Account) {

        let vc = StoryboardScene.Backup.needBackupViewController.instantiate()
        vc.output = self
        let custom = CustomNavigationController(rootViewController: vc)
        navigationController.present(custom, animated: true, completion: nil)
    }
}

// MARK: NewAccountModuleOutput
extension NewAccountCoordinator: NeedBackupModuleOutput {
    func userCompletedInteract(skipBackup: Bool) {

//        if skipBackup {
//
//        } else {
//            navigationController.dismiss(animated: true, completion: nil)
            let vc = StoryboardScene.Backup.backupInfoViewController.instantiate()
            let custom = CustomNavigationController(rootViewController: vc)
            navigationController.present(custom, animated: true, completion: nil)
//        }
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
