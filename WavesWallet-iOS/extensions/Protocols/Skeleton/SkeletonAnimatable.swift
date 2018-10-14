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
    static var isHaveListener = "isHaveListener"
}

extension SkeletonAnimatable where Self: UIView {

    fileprivate var direction: SkeletonDirection {

        get {
            return associatedObject(for: &AssociatedKeys.direction) ?? .right
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.direction)
        }
    }

    fileprivate var isHaveListener: Bool {

        get {
            return associatedObject(for: &AssociatedKeys.isHaveListener) ?? false
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.isHaveListener)
        }
    }

    private func startListener() {
        if isHaveListener {
            return
        }

        isHaveListener = true
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
    }

    private func stopListener() {
        isHaveListener = false
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }

    func startAnimation(to dir: SkeletonDirection = .right) {

        stopAnimation()

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

fileprivate extension UIView { 
    @objc fileprivate  func didBecomeActive() {
        if let skeleton = self as? (UIView & SkeletonAnimatable) {
            skeleton.startAnimation(to: skeleton.direction)
        }
    }

    @objc fileprivate  func didEnterBackground() {
        if let skeleton = self as? (UIView & SkeletonAnimatable) {
            skeleton.stopAnimation()
        }
    }
}
