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
    @IBOutlet private weak var oldPasswordInput: InputTextField!
    @IBOutlet private weak var passwordInput: InputTextField!
    @IBOutlet private weak var confirmPasswordInput: InputTextField!

    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    var presenter: ChangePasswordPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonConfirm.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonConfirm.setBackgroundImage(UIColor.submit400.image, for: .normal)
        buttonConfirm.setTitle(Localizable.Waves.Changepassword.Button.Confirm.title, for: .normal)

        navigationItem.title = Localizable.Waves.Changepassword.Navigation.title
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

        oldPasswordInput.autocapitalizationType = .none
        passwordInput.autocapitalizationType = .none
        confirmPasswordInput.autocapitalizationType = .none

        oldPasswordInput.update(with: InputTextField.Model(title: Localizable.Waves.Changepassword.Textfield.Oldpassword.title,
                                                              kind: .password,
                                                              placeholder: Localizable.Waves.Changepassword.Textfield.Oldpassword.title))
        passwordInput.update(with: InputTextField.Model(title: Localizable.Waves.Changepassword.Textfield.Createpassword.title,
                                                           kind: .password,
                                                           placeholder: Localizable.Waves.Changepassword.Textfield.Createpassword.title))
        confirmPasswordInput.update(with: InputTextField.Model(title: Localizable.Waves.Changepassword.Textfield.Confirmpassword.title,
                                                                  kind: .newPassword,
                                                                  placeholder: Localizable.Waves.Changepassword.Textfield.Confirmpassword.title))

        oldPasswordInput.returnKey = .next
        passwordInput.returnKey = .next
        confirmPasswordInput.returnKey = .done

        oldPasswordInput.textFieldShouldReturn = { [weak self] _ in

            guard let self = self else { return }

            self.passwordInput.becomeFirstResponder()
        }

        passwordInput.textFieldShouldReturn = { [weak self] _ in

            guard let self = self else { return }
            self.confirmPasswordInput.becomeFirstResponder()
        }

        confirmPasswordInput.textFieldShouldReturn = { [weak self] _ in

            guard let self = self else { return }
            self.continueChangePassword()
        }

        oldPasswordInput.changedValue = { [weak self] isValidData, text in
            guard let self = self else { return }
            self.eventInput.onNext(.input(.oldPassword, text))
        }
        passwordInput.changedValue = { [weak self] isValidData, text in
            guard let self = self else { return }
            self.eventInput.onNext(.input(.newPassword, text))
        }
        confirmPasswordInput.changedValue = { [weak self] isValidData, text in
            guard let self = self else { return }
            self.eventInput.onNext(.input(.confirmPassword, text))
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
            guard let self = self else { return Signal.empty() }

            return self
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

            guard let self = self else { return }

            self.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {

        if let textFiled = state.textFields[.oldPassword] {
            oldPasswordInput.error = textFiled.error
        } else {
            oldPasswordInput.error = nil
        }

        if let textFiled = state.textFields[.newPassword] {
            passwordInput.error = textFiled.error
        } else {
            passwordInput.error = nil
        }

        if let textFiled = state.textFields[.confirmPassword] {
            confirmPasswordInput.error = textFiled.error
        } else {
            confirmPasswordInput.error = nil
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
