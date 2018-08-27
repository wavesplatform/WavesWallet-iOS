//
//  CustomNavigationController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 17/03/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

extension UINavigationItem {

    private enum AssociatedKeys {
        static var prefersLargeTitles = "prefersLargeTitles"
        static var backgroundImage = "backgroundImage"
        static var shadowImage = "shadowImage"
    }

    @objc var prefersLargeTitles: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.prefersLargeTitles) ?? false
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.prefersLargeTitles)
        }
    }

    @objc var backgroundImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.backgroundImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.backgroundImage)
        }
    }

    @objc var shadowImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.shadowImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.shadowImage)
        }
    }
}

private enum Constants {
    static var prefersLargeTitles = "prefersLargeTitles"
    static var backgroundImage = "backgroundImage"
    static var shadowImage = "shadowImage"
}

class CustomNavigationController: UINavigationController {

    private weak var prevViewContoller: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {

        if let prevViewContoller = prevViewContoller {
            apperanceNavigationItemProperties(prevViewContoller)
        }
    }

    private func apperanceNavigationItemProperties(_ viewController: UIViewController) {

        print(nameType(type(of: viewController)))
        navigationBar.setBackgroundImage(viewController.navigationItem.backgroundImage, for: .default)

        if navigationBar.shadowImage != viewController.navigationItem.shadowImage {
            navigationBar.shadowImage = viewController.navigationItem.shadowImage
        }

        if #available(iOS 11.0, *) {
            if navigationBar.prefersLargeTitles != viewController.navigationItem.prefersLargeTitles {
                navigationBar.prefersLargeTitles = viewController.navigationItem.prefersLargeTitles
            }
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension CustomNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UINavigationControllerDelegate

extension CustomNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        if let prevViewContoller = prevViewContoller {
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.shadowImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backgroundImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.prefersLargeTitles)
        }

        prevViewContoller = viewController

        apperanceNavigationItemProperties(viewController)

        viewController.navigationItem.addObserver(self, forKeyPath: Constants.backgroundImage, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.shadowImage, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.prefersLargeTitles, options: [.new, .old], context: nil)

        self.transitionCoordinator?.notifyWhenInteractionEnds({ [weak self] context in
            guard context.isCancelled else { return }
            guard let fromViewController = context.viewController(forKey: .from) else { return }
            self?.navigationController(navigationController, willShow: fromViewController, animated: animated)

            let animationCompletion = context.transitionDuration * Double(context.percentComplete)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animationCompletion, execute: {
                self?.navigationController(navigationController, didShow: fromViewController, animated: animated)
            })

        })
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {}
}
