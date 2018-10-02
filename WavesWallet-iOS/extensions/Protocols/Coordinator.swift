//
//  Coordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol Coordinator: AnyObject {

    var childCoordinators: [Coordinator] { get set }

    /**
     It variable need marked to weak
     */
    var parent: Coordinator? { get set }

    func start()
}

extension Coordinator {

    func addChildCoordinator(childCoordinator: Coordinator) {
        self.childCoordinators.append(childCoordinator)
        childCoordinator.parent = self
    }

    func removeChildCoordinator(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter { $0 !== childCoordinator }
        childCoordinator.parent = nil
    }

    func removeFromParentCoordinator() {
        parent?.removeChildCoordinator(childCoordinator: self)
    }
}
