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
        static var barTintColor = "barTintColor"
        static var tintColor = "tintColor"
        static var isNavigationBarHidden = "isNavigationBarHidden"
        static var titleTextAttributes = "titleTextAttributes"
        static var isTranslucent = "isTranslucent"
        static var backIndicatorImage = "backIndicatorImage"
        static var backIndicatorTransitionMaskImage = "backIndicatorTransitionMaskImage"
        static var largeTitleTextAttributes = "largeTitleTextAttributes"
    }

    @objc var largeTitleTextAttributes: [NSAttributedStringKey : Any]? {
        get {
            return associatedObject(for: &AssociatedKeys.largeTitleTextAttributes)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.largeTitleTextAttributes)
        }
    }

    @objc var backIndicatorImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.backIndicatorImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.backIndicatorImage)
        }
    }
    
    @objc var backIndicatorTransitionMaskImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.backIndicatorTransitionMaskImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.backIndicatorTransitionMaskImage)
        }
    }

    // TODO: COME B
    @objc var titleTextAttributes: [NSAttributedStringKey : Any]? {
        get {
            return associatedObject(for: &AssociatedKeys.titleTextAttributes) ?? nil
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.titleTextAttributes)
        }
    }

    @objc var isNavigationBarHidden: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.isNavigationBarHidden) ?? false
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.isNavigationBarHidden)
        }
    }

    @objc var barTintColor: UIColor? {
        get {
            return associatedObject(for: &AssociatedKeys.barTintColor) ?? nil
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.barTintColor)
        }
    }

    @objc var tintColor: UIColor? {
        get {
            return associatedObject(for: &AssociatedKeys.tintColor) ?? nil
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.tintColor)
        }
    }

    @objc var prefersLargeTitles: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.prefersLargeTitles) ?? false
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.prefersLargeTitles)
        }
    }

    @objc var isTranslucent: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.isTranslucent) ?? true
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.isTranslucent)
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

fileprivate enum Constants {
    static var prefersLargeTitles = "prefersLargeTitles"
    static var backgroundImage = "backgroundImage"
    static var shadowImage = "shadowImage"
    static var barTintColor = "barTintColor"
    static var tintColor = "tintColor"
    static var isNavigationBarHidden = "isNavigationBarHidden"
    static var titleTextAttributes = "titleTextAttributes"
    static var isTranslucent = "isTranslucent"
    static var backIndicatorImage = "backIndicatorImage"
    static var backIndicatorTransitionMaskImage = "backIndicatorTransitionMaskImage"
    static var largeTitleTextAttributes = "largeTitleTextAttributes"
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

    override func popViewController(animated: Bool) -> UIViewController? {

        if viewControllers.count == 2 {
            self.viewControllers.first?.hidesBottomBarWhenPushed = false
        }

        return super.popViewController(animated: animated)
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {

        self.viewControllers.first?.hidesBottomBarWhenPushed = false
        return super.popToRootViewController(animated: animated)
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        return super.popToViewController(viewController, animated: animated)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.viewControllers.first?.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
    }

    private func apperanceNavigationItemProperties(_ viewController: UIViewController, animated: Bool = false) {

        if viewController != topViewController {
            return
        }

        print("apperance \(String(describing: viewController)) top \(String(describing: self.topViewController!))")
        navigationBar.setBackgroundImage(viewController.navigationItem.backgroundImage, for: .default)

        navigationBar.isTranslucent = viewController.navigationItem.isTranslucent
        navigationBar.shadowImage = viewController.navigationItem.shadowImage
        navigationBar.barTintColor = viewController.navigationItem.barTintColor
        navigationBar.tintColor = viewController.navigationItem.tintColor
        navigationBar.titleTextAttributes = viewController.navigationItem.titleTextAttributes
        if #available(iOS 11.0, *) {
            navigationBar.largeTitleTextAttributes = viewController.navigationItem.largeTitleTextAttributes
            navigationBar.prefersLargeTitles = viewController.navigationItem.prefersLargeTitles
        }

        setNavigationBarHidden(viewController.navigationItem.isNavigationBarHidden, animated: animated)
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }

    deinit {
        if let prevViewContoller = prevViewContoller {
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.shadowImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backgroundImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.barTintColor)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.tintColor)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.isNavigationBarHidden)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.titleTextAttributes)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.isTranslucent)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backIndicatorImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backIndicatorTransitionMaskImage)

            if #available(iOS 11.0, *) {
                prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.prefersLargeTitles)
                prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.largeTitleTextAttributes)
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
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.barTintColor)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.tintColor)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.isNavigationBarHidden)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.titleTextAttributes)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.isTranslucent)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backIndicatorImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backIndicatorTransitionMaskImage)

            if #available(iOS 11.0, *) {
                prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.prefersLargeTitles)
                prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.largeTitleTextAttributes)
            }
        }

        prevViewContoller = viewController

        apperanceNavigationItemProperties(viewController, animated: animated)

        viewController.navigationItem.addObserver(self, forKeyPath: Constants.backgroundImage, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.shadowImage, options: [.new, .old], context: nil)

        viewController.navigationItem.addObserver(self, forKeyPath: Constants.barTintColor, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.tintColor, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.isNavigationBarHidden, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.titleTextAttributes, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.isTranslucent, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.backIndicatorImage, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.backIndicatorTransitionMaskImage, options: [.new, .old], context: nil)


        if #available(iOS 11.0, *) {
            viewController.navigationItem.addObserver(self, forKeyPath: Constants.prefersLargeTitles, options: [.new, .old], context: nil)
            viewController.navigationItem.addObserver(self, forKeyPath: Constants.largeTitleTextAttributes, options: [.new, .old], context: nil)
        }

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
