//
//  CheckboxCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 10/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class CheckboxCoordinator {
    
    private lazy var checkboxViewController: UIViewController = {
        return CheckboxModuleBuilder(output: self).build(input: self)
    }()
    
    func start() {
        UIApplication.shared.keyWindow!.rootViewController!.present(checkboxViewController, animated: true, completion: nil)
    }
    
}

extension CheckboxCoordinator: CheckboxModuleOutput {
    
    func showViewController(viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        
        checkboxViewController.present(navigationController, animated: true)
    }
    
}

extension CheckboxCoordinator: CheckboxModuleInput {
    
}
