//
//  CheckboxCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 10/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol LegalCoordinatorDelegate: AnyObject {

    func legalConfirm()
}

final class LegalCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private weak var viewController: UIViewController?

    private lazy var legalViewController: UIViewController = {
        return LegalModuleBuilder(output: self).build(input: self)
    }()

    weak var delegate: LegalCoordinatorDelegate?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func start() {
        viewController?.present(legalViewController, animated: true, completion: nil)
    }
    
}

extension LegalCoordinator: LegalModuleOutput {

    //TODO Change name method
    func showViewController(viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        legalViewController.present(navigationController, animated: true)
    }

    func legalConfirm() {
        removeFromParentCoordinator()
        delegate?.legalConfirm()
    }
}

extension LegalCoordinator: LegalModuleInput {
    
}
