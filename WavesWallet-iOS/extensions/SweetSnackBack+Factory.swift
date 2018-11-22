//
//  SweetSnackBack+Factory.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let withoutInternetSnackAlpha: CGFloat = 0.74
    static let snackAlpha: CGFloat = 0.94
    static let successDuration: TimeInterval = 1.3
}

extension UIViewController {

    @discardableResult func showWithoutInternetSnack(didTap: @escaping (() -> Void)) -> String {


        let error = SweetSnack.init(title: "No connection to the Internet",
                                    backgroundColor: UIColor.disabled666.withAlphaComponent(Constants.withoutInternetSnackAlpha),
                                    behaviorDismiss: .popToLast,
                                    subtitle: nil,
                                    icon: Images.refresh18White.image,
                                    isEnabledUserHidden: false,
                                    action: SweetSnackError(didTap: didTap))
        return SweetSnackbar.shared.showSnack(error, on: self)
    }

    @discardableResult func showMessageSnack(tille: String, didTap: (() -> Void)? = nil) -> String {


        let error = SweetSnack.init(title: tille,
                                    backgroundColor: UIColor.error400.withAlphaComponent(Constants.snackAlpha),
                                    behaviorDismiss: .popToLast,
                                    subtitle: nil,
                                    icon: nil,
                                    isEnabledUserHidden: true,
                                    action: SweetSnackCustonAction(didTap: didTap, didSwipe: nil))
        return SweetSnackbar.shared.showSnack(error, on: self)
    }

    @discardableResult func showErrorSnack(tille: String, didTap: (() -> Void)? = nil) -> String {


        let error = SweetSnack.init(title: tille,
                                    backgroundColor: UIColor.error400.withAlphaComponent(Constants.snackAlpha),
                                    behaviorDismiss: .popToLast,
                                    subtitle: nil,
                                    icon: Images.refresh18White.image,
                                    isEnabledUserHidden: false,
                                    action: SweetSnackError(didTap: didTap))
        return SweetSnackbar.shared.showSnack(error, on: self)
    }

    @discardableResult func showWarningSnack(tille: String, subtitle: String, didTap: @escaping (() -> Void), didSwipe: @escaping (() -> Void)) -> String {


        let error = SweetSnack.init(title: tille,
                                    backgroundColor: UIColor.error400.withAlphaComponent(Constants.snackAlpha),
                                    behaviorDismiss: .never,
                                    subtitle: subtitle,
                                    icon: Images.refresh18White.image,
                                    isEnabledUserHidden: true,
                                    action: SweetSnackCustonAction(didTap: didTap, didSwipe: didSwipe))
        return SweetSnackbar.shared.showSnack(error, on: self)
    }


    @discardableResult func showSuccesSnack(tille: String) -> String {


        let success = SweetSnack.init(title: tille,
                                      backgroundColor:  UIColor.success400.withAlphaComponent(Constants.snackAlpha),
                                      behaviorDismiss: .popToLastWihDuration(Constants.successDuration),
                                      subtitle: nil,
                                      icon: nil,
                                      isEnabledUserHidden: true,
                                      action: nil)
        return SweetSnackbar.shared.showSnack(success, on: self)
    }
}

struct SweetSnackError: SweetSnackAction {

    var didTap: (() -> Void)?

    func didTap(snack: SweetSnack, view: SweetSnackView, bar: SweetSnackbar) {
        view.startAnimationIcon()
        view.isUserInteractionEnabled = false
        didTap?()
    }

    func didSwipe(snack: SweetSnack, view: SweetSnackView, bar: SweetSnackbar) {}
}

struct SweetSnackCustonAction: SweetSnackAction {

    var didTap: (() -> Void)?
    var didSwipe: (() -> Void)?

    func didTap(snack: SweetSnack, view: SweetSnackView, bar: SweetSnackbar) {
        didTap?()
    }

    func didSwipe(snack: SweetSnack, view: SweetSnackView, bar: SweetSnackbar) {
        didSwipe?()
    }
}
