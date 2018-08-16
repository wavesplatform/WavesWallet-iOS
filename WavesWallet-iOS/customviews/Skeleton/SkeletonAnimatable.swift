//
//  SkeletonAnimatable.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Skeleton

enum SkeletonDirection: Int {
    case left
    case right
}

protocol SkeletonAnimatable: GradientsOwner {

    func startAnimation(to dir: SkeletonDirection)
    func stopAnimation()
}

private enum AssociatedKeys {
    static var direction = "direction"
    static var token = "token"
}

extension SkeletonAnimatable where Self: NSObject {

    private var direction: SkeletonDirection {

        get {
            return associatedObject(for: &AssociatedKeys.direction) ?? .right
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.direction)
        }
    }

    private var token: NSObjectProtocol? {

        get {
            return associatedObject(for: &AssociatedKeys.token)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.token)
        }
    }

    private func startListener() {
        self.token = NotificationCenter.default.addObserver(forName: .UIApplicationDidEnterBackground, object: self, queue: OperationQueue.main) { [weak self] _ in
            print("UIApplicationDidEnterBackground")
            guard let owner = self else { return }
            owner.startAnimation(to: owner.direction)
        }
    }

    private func stopListener() {
        self.token = nil
    }

    func startAnimation(to dir: SkeletonDirection = .right) {

//        stopAnimation()

        self.direction = dir
        let direction: Direction = dir == .left ? .left : .right
        slide(to: direction)

        startListener()
    }

    func stopAnimation() {
        stopListener()
        stopSliding()
    }
}
