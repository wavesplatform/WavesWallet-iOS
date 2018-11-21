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
    let didTap: ((UIButton) -> Void)?
}

final class SweetSnackbar {

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
    private var lastSnack: PackageSnack?
    private var neverSnack: PackageSnack?

    func hideSnack(key: String) {
        guard let snack = snackMap[key] else { return }
        hideSnack(snack)
    }

    @discardableResult func showSnack(_ snack: SweetSnack,
                                      on viewController: UIViewController) -> String {

        let view = SweetSnackView.loadFromNib()
        view.translatesAutoresizingMaskIntoConstraints = true
        let bounds = viewController.view.bounds
        view.bounds = bounds
        view.update(model: snack)


        let size = view.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        view.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: size.height)

        viewController.view.addSubview(view)

        hideLastSnack()

        let key = UUID().uuidString
        let package = PackageSnack(key: key,
                                   model: snack,
                                   view: view,
                                   viewController: viewController)
        self.lastSnack = package
        snackMap[key] = package

        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseInOut], animations: {
            view.frame = CGRect(x: 0, y: bounds.height - size.height, width: bounds.width, height: size.height)
        }) { _ in

            self.applyBehaviorDismiss(view: view, viewController: viewController, snack: package)
        }
        return key
    }

    private func applyBehaviorDismiss(view: SweetSnackView, viewController: UIViewController, snack: PackageSnack) {

        switch snack.model.behaviorDismiss {
        case .popToLast:
            break

        case .popToLastWihDuration(let duration):
            autoHideSnack(duration: duration)

        case .never:
            self.neverSnack = snack
        }
    }

    private func applyActionDismiss(snack: PackageSnack) {

        switch snack.model.behaviorDismiss {
        case .popToLast:
            break

        case .popToLastWihDuration:
            break

        case .never:
            if let neverSnack = self.neverSnack, neverSnack.key == snack.key {
                self.neverSnack = nil
            }
        }
    }

    private func autoHideSnack(duration: TimeInterval) {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            self.hideLastSnack()
        }
    }

    private func hideLastSnack() {

        guard let snack = self.lastSnack else  { return }
        hideSnack(snack)
        self.lastSnack = nil
    }

    private func hideSnack(_ snack: PackageSnack) {

        guard let viewController = snack.viewController else  { return }
        let view = snack.view

        let bounds = viewController.view.bounds
        let size = view.frame.size

        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseInOut], animations: {
            view.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: size.height)
        }) { _ in
            view.removeFromSuperview()
            self.applyActionDismiss(snack: snack)
        }
    }
}
