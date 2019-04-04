//
//  AccountPasswordViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxFeedback
import RxSwift
import IdentityImg
import IQKeyboardManagerSwift

protocol AccountPasswordViewControllerDelegate: class {
    func accountPasswordViewControllerDidSuccessEnter()
}

final class AccountPasswordViewController: UIViewController {

    fileprivate typealias Types = AccountPasswordTypes

    @IBOutlet private weak var buttonSignIn: UIButton!
    @IBOutlet private weak var passwordTextField: InputTextField!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!

    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()
    private let identity: Identity = Identity(options: Identity.defaultOptions)

    var presenter: AccountPasswordPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        setupSmallNavigationBar()
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()

        setupTextField()
        setupSystem()

        buttonSignIn.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonSignIn.setBackgroundImage(UIColor.submit400.image, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passwordTextField.becomeFirstResponder()
    }

    @IBAction func signInTapped(_ sender: Any) {
        completedInput()
    }

    private func completedInput() {
        view.endEditing(true)
        
        if let value = passwordTextField.value?.value  {
            eventInput.onNext(.tapLogIn(password: value))
        }
    }

    private func setupTextField() {
        passwordTextField.returnKey = .done
        passwordTextField.update(with: .init(title: Localizable.Waves.Accountpassword.Textfield.Password.placeholder,
                                             kind: .password,
                                             placeholder: Localizable.Waves.Accountpassword.Textfield.Password.placeholder))

        let changedValue: ((Bool,String?) -> Void) = { [weak self] isValidValue, value in
            guard let self = self else { return }
            self.passwordTextField.error = nil
            self.buttonSignIn.isEnabled = (value?.trimmingCharacters(in: CharacterSet.whitespaces).count ?? 0) >= GlobalConstants.minLengthPassword
        }

        passwordTextField.changedValue = changedValue

        passwordTextField.textFieldShouldReturn = { [weak self] _ in
            guard let self = self else { return }
            self.completedInput()
        }
    }
}

// MARK: RxFeedback

private extension AccountPasswordViewController {

    func setupSystem() {

        let uiFeedback: AccountPasswordPresenter.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())            
        }

        presenter.system(feedbacks: [uiFeedback])
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

        nameLabel.text = state.name
        addressLabel.text = state.address
        if state.isLoading {
            indicatorView.startAnimating()
            buttonSignIn.isEnabled = false
            buttonSignIn.setTitleWithoutAnimated(nil, for: .normal)
        } else {
            indicatorView.stopAnimating()
            buttonSignIn.isEnabled = passwordTextField.isValidValue
            buttonSignIn.setTitleWithoutAnimated(Localizable.Waves.Accountpassword.Button.Signin.title, for: .normal)
        }

        imageView.image = identity.createImage(by: state.address, size: imageView.frame.size)

        if let error = state.error {
            switch error {
            case .incorrectPassword:
                passwordTextField.error = Localizable.Waves.Accountpassword.Error.wrongpassword
            }
        } else {
            passwordTextField.error = nil
        }
    }
}
