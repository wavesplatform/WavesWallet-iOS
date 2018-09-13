//
//  CheckboxCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 10/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class LegalCoordinator {
    
    private lazy var legalViewController: UIViewController = {
        return LegalModuleBuilder(output: self).build(input: self)
    }()
    
    func start() {
        UIApplication.shared.keyWindow!.rootViewController!.present(legalViewController, animated: true, completion: nil)
    }
    
}

extension LegalCoordinator: LegalModuleOutput {
    
    func showViewController(viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        
        legalViewController.present(navigationController, animated: true)
    }
    
}

extension LegalCoordinator: LegalModuleInput {
    
}
