//
//  PasscodeCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol PasscodeCoordinatorDelegate: AnyObject {
    func userAuthorizationCompleted()
}

final class PasscodeCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let viewController: UIViewController
    private let navigationController: UINavigationController

    private let kind: PasscodeTypes.DTO.Kind
    private let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    
    weak var delegate: PasscodeCoordinatorDelegate?

    init(viewController: UIViewController, kind: PasscodeTypes.DTO.Kind) {
        self.viewController = viewController
        self.navigationController = CustomNavigationController()
        self.kind = kind
    }


    func start() {
        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: kind))
        navigationController.pushViewController(vc, animated: true)

        if let presentedViewController = viewController.presentedViewController {
            presentedViewController.present(navigationController, animated: true, completion: nil)
        } else {
            viewController.present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: PasscodeOutput
extension PasscodeCoordinator: PasscodeOutput {

    func authorizationCompleted() -> Void {

//        if let presentedViewController = viewController.presentedViewController {
//            ыудаю
//        } else {
//            viewController.present(navigationController, animated: true, completion: nil)
//        }
        self.viewController.dismiss(animated: true, completion: nil)
        removeFromParentCoordinator()
        delegate?.userAuthorizationCompleted()
    }
}
