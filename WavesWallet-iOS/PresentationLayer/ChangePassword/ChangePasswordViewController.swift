//
//  ChangePasswordViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxFeedback
import RxSwift

final class ChangePasswordViewController: UIViewController {

    fileprivate typealias Types = ChangePasswordTypes

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var buttonConfirm: UIButton!
    @IBOutlet private weak var oldPasswordInput: PasswordTextField!
    @IBOutlet private weak var passwordInput: PasswordTextField!
    @IBOutlet private weak var confirmPasswordInput: PasswordTextField!

    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    var presenter: ChangePasswordPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonConfirm.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonConfirm.setBackgroundImage(UIColor.submit400.image, for: .normal)
        buttonConfirm.setTitle(Localizable.ChangePassword.Button.Confirm.title, for: .normal)

        navigationItem.title = Localizable.ChangePassword.Navigation.title
        navigationItem.barTintColor = .white
        createBackButton()
        setupBigNavigationBar()
        setupTextField()
        setupSystem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        oldPasswordInput.becomeFirstResponder()
    }

    private func setupTextField() {
        oldPasswordInput.update(with: PasswordTextField.Model(title: Localizable.ChangePassword.Textfield.Oldpassword.title,
                                                              kind: .password,
                                                              placeholder: Localizable.ChangePassword.Textfield.Oldpassword.title))
        passwordInput.update(with: PasswordTextField.Model(title: Localizable.ChangePassword.Textfield.Createpassword.title,
                                                           kind: .password,
                                                           placeholder: Localizable.ChangePassword.Textfield.Createpassword.title))
        confirmPasswordInput.update(with: PasswordTextField.Model(title: Localizable.ChangePassword.Textfield.Confirmpassword.title,
                                                                  kind: .newPassword,
                                                                  placeholder: Localizable.ChangePassword.Textfield.Confirmpassword.title))

        oldPasswordInput.returnKey = .next
        passwordInput.returnKey = .next
        confirmPasswordInput.returnKey = .done

        oldPasswordInput.textFieldShouldReturn = { [weak self] _ in
            self?.passwordInput.becomeFirstResponder()
        }

        passwordInput.textFieldShouldReturn = { [weak self] _ in
            self?.confirmPasswordInput.becomeFirstResponder()
        }

        confirmPasswordInput.textFieldShouldReturn = { [weak self] _ in
            self?.continueChangePassword()
        }

        oldPasswordInput.changedValue = { [weak self] isValidData, text in
            self?.eventInput.onNext(.input(.oldPassword, text))
        }
        passwordInput.changedValue = { [weak self] isValidData, text in
            self?.eventInput.onNext(.input(.newPassword, text))
        }
        confirmPasswordInput.changedValue = { [weak self] isValidData, text in
            self?.eventInput.onNext(.input(.confirmPassword, text))
        }
    }

    private func continueChangePassword() {
        eventInput.onNext(.tapContinue)
    }

    @IBAction func handlerConfirmButton() {
        continueChangePassword()
    }
}

// MARK: RxFeedback

private extension ChangePasswordViewController {

    func setupSystem() {

        let uiFeedback: ChangePasswordPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: ChangePasswordPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .rx
                .viewWillAppear
                .asObservable()
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.readyView }
        }

        presenter.system(feedbacks: [uiFeedback, readyViewFeedback])
    }

    func events() -> [Signal<Types.Event>] {
        return [eventInput.asSignal(onErrorSignalWith: Signal.empty())]
    }

    func subscriptions(state: Driver<Types.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let strongSelf = self else { return }

            strongSelf.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {

        if let textFiled = state.textFields[.oldPassword] {
            oldPasswordInput.setError(textFiled.error)
        } else {
            oldPasswordInput.setError(nil)
        }

        if let textFiled = state.textFields[.newPassword] {
            passwordInput.setError(textFiled.error)
        } else {
            passwordInput.setError(nil)
        }

        if let textFiled = state.textFields[.confirmPassword] {
            confirmPasswordInput.setError(textFiled.error)
        } else {
            confirmPasswordInput.setError(nil)
        }

        buttonConfirm.isEnabled = state.isEnabledConfirmButton
    }
}

// MARK: UIScrollViewDelegate
extension ChangePasswordViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
