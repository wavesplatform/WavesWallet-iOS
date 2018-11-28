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
    static let messageDuration: TimeInterval = 2
}

// MARK: - Internet
extension UIViewController {

    @discardableResult func showWithoutInternetSnack(didTap: @escaping (() -> Void)) -> String {

        let error = SweetSnack.init(title: Localizable.Waves.General.Error.Title.noconnectiontotheinternet,

                                    backgroundColor: UIColor.disabled666.withAlphaComponent(Constants.withoutInternetSnackAlpha),
                                    behaviorDismiss: .popToLast,
                                    subtitle: nil,
                                    icon: Images.refresh18White.image,
                                    isEnabledUserHidden: false,
                                    action: SweetSnackError(didTap: didTap))
        return SweetSnackbar.shared.showSnack(error, on: self)
    }

    @discardableResult func showWithoutInternetSnackWithoutAction() -> String {

        let error = SweetSnack.init(title: Localizable.Waves.General.Error.Title.noconnectiontotheinternet,
                                    backgroundColor: UIColor.disabled666.withAlphaComponent(Constants.withoutInternetSnackAlpha),
                                    behaviorDismiss: .popToLast,
                                    subtitle: nil,
                                    icon: Images.refresh18White.image,
                                    isEnabledUserHidden: false,
                                    action: nil)
        return SweetSnackbar.shared.showSnack(error, on: self)
    }

    @discardableResult func showMessageSnack(title: String, didTap: (() -> Void)? = nil) -> String {

        let error = SweetSnack.init(title: title,
                                    backgroundColor: UIColor.error400.withAlphaComponent(Constants.snackAlpha),
                                    behaviorDismiss: .popToLastWihDuration(Constants.messageDuration),
                                    subtitle: nil,
                                    icon: nil,
                                    isEnabledUserHidden: true,
                                    action: SweetSnackCustonAction(didTap: didTap, didSwipe: nil))
        return SweetSnackbar.shared.showSnack(error, on: self)
    }
}

// MARK: - -  Error Snack

extension UIViewController {

    @discardableResult func showErrorSnackWithoutAction(tille: String, duration: TimeInterval) -> String {


        let error = SweetSnack.init(title: tille,
                                    backgroundColor: UIColor.error400.withAlphaComponent(Constants.snackAlpha),
                                    behaviorDismiss: .popToLastWihDuration(duration),
                                    subtitle: nil,
                                    icon: nil,
                                    isEnabledUserHidden: false,
                                    action: nil)
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

    @discardableResult func showErrorSnackWithoutAction(tille: String) -> String {

        let error = SweetSnack.init(title: tille,
                                    backgroundColor: UIColor.error400.withAlphaComponent(Constants.snackAlpha),
                                    behaviorDismiss: .popToLast,
                                    subtitle: nil,
                                    icon: nil,
                                    isEnabledUserHidden: false,
                                    action: nil)
        return SweetSnackbar.shared.showSnack(error, on: self)
    }
}

// MARK: - -  Error Not Found Snack

extension UIViewController {

    @discardableResult func showErrorNotFoundSnackWithoutAction() -> String {

        let error = SweetSnack.init(title: Localizable.Waves.General.Error.Title.notfound,
                                    backgroundColor: UIColor.error400.withAlphaComponent(Constants.snackAlpha),
                                    behaviorDismiss: .popToLast,
                                    subtitle: Localizable.Waves.General.Error.Subtitle.notfound,
                                    icon: nil,
                                    isEnabledUserHidden: false,
                                    action: nil)
        return SweetSnackbar.shared.showSnack(error, on: self)
    }

    @discardableResult func showErrorNotFoundSnack(didTap: (() -> Void)? = nil) -> String {

        let error = SweetSnack.init(title: Localizable.Waves.General.Error.Title.notfound,
                                    backgroundColor: UIColor.error400.withAlphaComponent(Constants.snackAlpha),
                                    behaviorDismiss: .popToLast,
                                    subtitle: Localizable.Waves.General.Error.Subtitle.notfound,
                                    icon: Images.refresh18White.image,
                                    isEnabledUserHidden: false,
                                    action: SweetSnackError(didTap: didTap))
        return SweetSnackbar.shared.showSnack(error, on: self)
    }
}

// MARK: - -  Warning

extension UIViewController {

    @discardableResult func showWarningSnack(title: String, subtitle: String, icon: UIImage = Images.refresh18White.image, didTap: @escaping (() -> Void), didSwipe: @escaping (() -> Void)) -> String {

        let error = SweetSnack.init(title: title,
                                    backgroundColor: UIColor.error400.withAlphaComponent(Constants.snackAlpha),
                                    behaviorDismiss: .never,
                                    subtitle: subtitle,
                                    icon: icon,
                                    isEnabledUserHidden: true,
                                    action: SweetSnackCustonAction(didTap: didTap, didSwipe: didSwipe))
        return SweetSnackbar.shared.showSnack(error, on: self)
    }
}

// MARK: - -  Success

extension UIViewController {

    @discardableResult func showSuccesSnack(title: String) -> String {


        let success = SweetSnack.init(title: title,
                                      backgroundColor:  UIColor.success400.withAlphaComponent(Constants.snackAlpha),
                                      behaviorDismiss: .popToLastWihDuration(Constants.successDuration),
                                      subtitle: nil,
                                      icon: nil,
                                      isEnabledUserHidden: true,
                                      action: nil)
        return SweetSnackbar.shared.showSnack(success, on: self)
    }

    func hideSnack(key: String) {
         SweetSnackbar.shared.hideSnack(key: key)
    }
}

class SweetSnackError: SweetSnackAction {

    var didTap: (() -> Void)?
    private var isIgnoreTap: Bool = false

    init(didTap: (() -> Void)?) {
        self.didTap = didTap
    }
    
    func didTap(snack: SweetSnack, view: SweetSnackView, bar: SweetSnackbar) {
        view.startAnimationIcon()
        if isIgnoreTap == false {
            isIgnoreTap = true
            didTap?()
        }
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
