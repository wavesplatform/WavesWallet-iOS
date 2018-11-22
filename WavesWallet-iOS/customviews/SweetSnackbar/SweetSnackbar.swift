//
//  SweetSnackbar.swift
//  SweetSnackbar
//
//  Created by Prokofev Ruslan on 17/10/2018.
//  Copyright © 2018 Waves. All rights reserved.
//

import UIKit

protocol SweetSnackIconTransformation {

}

protocol SweetSnackAction {
    func didTap(snack: SweetSnack, view: SweetSnackView, bar: SweetSnackbar)
    func didSwipe(snack: SweetSnack, view: SweetSnackView, bar: SweetSnackbar)
}

struct SweetSnack {

    enum BehaviorDismiss {
        case popToLastWihDuration(TimeInterval)
        case popToLast
        case never
    }
    
    let title: String
    let backgroundColor: UIColor
    let behaviorDismiss: BehaviorDismiss
    let subtitle: String?
    let icon: UIImage?
    let isEnabledUserHidden: Bool
    let action: SweetSnackAction?
}

final class SweetSnackbar: NSObject {

    private struct PackageSnack {
        let key: String
        let model: SweetSnack
        let view: SweetSnackView
        weak var viewController: UIViewController?
    }

    private static var _sweetSnackbar: SweetSnackbar?

    static var shared: SweetSnackbar {
        if let sweetSnackbar = SweetSnackbar._sweetSnackbar {
            return sweetSnackbar
        } else {
            let sweetSnackbar = SweetSnackbar()
            SweetSnackbar._sweetSnackbar = sweetSnackbar
            return sweetSnackbar
        }
    }

    private var snackMap: [String: PackageSnack] = [:]
    private var lastSnack: PackageSnack? = nil
    private var neverSnack: PackageSnack? = nil
    private var lastLocation: CGPoint? = nil

    func hideSnack(key: String) {
        guard let snack = snackMap[key] else { return }
        hideSnack(snack, isNewSnack: false)
    }

    @discardableResult func showSnack(_ snack: SweetSnack,
                                      on viewController: UIViewController) -> String {

        let view = SweetSnackView.loadFromNib()
        let key = UUID().uuidString
        let package = PackageSnack(key: key,
                                   model: snack,
                                   view: view,
                                   viewController: viewController)

        return showSnack(by: package, on: viewController)
    }

    @discardableResult private func showSnack(by package: PackageSnack,
                                              on viewController: UIViewController) -> String {

        let pan = UIPanGestureRecognizer(target: self, action: #selector(hanlerPanGesture(pan:)))
        pan.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(hanlerTapGesture(tap:)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(hanlerSwipeGesture(swipe:)))
        swipe.direction = .down

        let snack = package.model
        let key = package.key

        // Initial View
        let view = package.view
        view.translatesAutoresizingMaskIntoConstraints = true
        let bounds = viewController.view.bounds
        view.bounds = bounds
        viewController.view.addSubview(view)
        view.update(model: snack)

        pan.isEnabled = snack.isEnabledUserHidden
        // Setup gesture
        pan.require(toFail: swipe)
        swipe.require(toFail: tap)
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipe)

        // Calculate Height
        view.layoutIfNeeded()
        view.setNeedsLayout()
        let size = view.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        view.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: size.height)

        snackMap[key] = package

        hideLastSnack(isNewSnack: true)
        self.lastSnack = package


        DispatchQueue.main.async {
            // It code run next loop in runloop
            UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseInOut], animations: { 
                view.frame = CGRect(x: 0, y: bounds.height - size.height, width: bounds.width, height: size.height)
            }) { _ in
                self.applyBehaviorDismiss(view: view, viewController: viewController, snack: package, isNewSnack: false)
            }
        }
        return key
    }

    private func applyBehaviorDismiss(view: SweetSnackView, viewController: UIViewController, snack: PackageSnack, isNewSnack: Bool) {

        switch snack.model.behaviorDismiss {
        case .popToLast:
            break

        case .popToLastWihDuration(let duration):
            autoHideSnack(snack: snack, duration: duration, isNewSnack: isNewSnack)

        case .never:
            self.neverSnack = snack
        }
    }

    private func applyActionDismiss(snack: PackageSnack, isNewSnack: Bool) {

        switch snack.model.behaviorDismiss {
        case .popToLast, .popToLastWihDuration:
            if let neverSnack = self.neverSnack, isNewSnack == false, self.lastSnack?.key != self.neverSnack?.key {
                guard let viewController = snack.viewController else { return }
                self.showSnack(by: neverSnack, on: viewController)
            }

        case .never:
            if let neverSnack = self.neverSnack,
                neverSnack.key == snack.key && isNewSnack == false {
                self.neverSnack = nil
            }
        }
    }

    private func autoHideSnack(snack: PackageSnack, duration: TimeInterval, isNewSnack: Bool) {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            if self.lastSnack?.key == snack.key {
                self.hideSnack(snack, isNewSnack: isNewSnack)
            }
        }
    }

    private func hideLastSnack(isNewSnack: Bool) {

        guard let snack = self.lastSnack else  { return }
        hideSnack(snack, isNewSnack: isNewSnack)
        self.lastSnack = nil
    }

    private func hideSnack(_ snack: PackageSnack, isNewSnack: Bool) {

        guard let viewController = snack.viewController else  { return }
        let view = snack.view
        self.snackMap.removeValue(forKey: snack.key)

        let bounds = viewController.view.bounds
        let size = view.frame.size

        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseInOut], animations: {
            view.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: size.height)
        }) { _ in
            view.removeFromSuperview()
            self.applyActionDismiss(snack: snack, isNewSnack: isNewSnack)
        }
    }
}

extension SweetSnackbar: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func hanlerPanGesture(pan: UIPanGestureRecognizer) {

        guard let snack = self.lastSnack else  { return }
        guard let viewController = snack.viewController else  { return }
        let view = snack.view

        let bounds = viewController.view.bounds
        let size = view.frame.size

        let location = pan.location(in: view)

        let minY = bounds.height - size.height
        let maxY = bounds.height - viewController.layoutInsets.bottom
        switch pan.state {
        case .began:
            lastLocation = location
        case .changed:
            let offset = location.y - (lastLocation?.y ?? location.y)
            var y = view.frame.origin.y + offset            
            y = max(y, minY)
            y = min(y, maxY)

            view.frame = CGRect(x: 0, y: y, width: bounds.width, height: size.height)
        case .cancelled, .ended:
            var percent = (view.frame.origin.y - minY) / (maxY - minY)
            percent = max(percent, 0)
            percent = min(percent, 1)
            if percent > 0.3 {
                hideSnack(snack, isNewSnack: false)
                snack.model.action?.didSwipe(snack: snack.model, view: snack.view, bar: self)
            } else {
                UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseInOut], animations: {
                    view.frame = CGRect(x: 0, y: bounds.height - size.height, width: bounds.width, height: size.height)
                }) { _ in }
            }
        case .possible:
            break
        case .failed:
            break
        }
    }

    @objc func hanlerSwipeGesture(swipe: UISwipeGestureRecognizer) {

        guard let lastSnack = self.lastSnack else { return }
        lastSnack.model.action?.didSwipe(snack: lastSnack.model, view: lastSnack.view, bar: self)

        if self.lastSnack?.model.isEnabledUserHidden == false {
            return
        }
        hideLastSnack(isNewSnack: false)
    }

    @objc func hanlerTapGesture(tap: UITapGestureRecognizer) {

        guard let lastSnack = self.lastSnack else { return }
        lastSnack.model.action?.didTap(snack: lastSnack.model, view: lastSnack.view, bar: self)

        if self.lastSnack?.model.isEnabledUserHidden == false {
            return
        }

        hideLastSnack(isNewSnack: false)
    }
}
