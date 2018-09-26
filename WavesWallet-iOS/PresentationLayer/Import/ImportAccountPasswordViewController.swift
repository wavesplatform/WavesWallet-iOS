//
//  ImportAccountPasswordViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import IdentityImg

fileprivate enum Constants {
    static let accountNameMinLimitSymbols: Int = 2
}

protocol ImportAccountPasswordViewControllerDelegate: AnyObject  {
    func userCompletedInputAccountData(password: String, name: String)
}

final class ImportAccountPasswordViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonContinue: UIButton!
    
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var labelAddress: UILabel!
    
    @IBOutlet private weak var accountTextField: InputTextField!
    @IBOutlet private weak var passwordTextField: InputTextField!
    @IBOutlet private weak var confirmPasswordTextField: InputTextField!

    private let identity: Identity = Identity(options: Identity.defaultOptions)

    var address: String?
    weak var delegate: ImportAccountPasswordViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Import.Welcome.Navigation.title
        labelAddress.text = address

        createBackButton()
        setupBigNavigationBar()
        hideTopBarLine()

        setupTextField()
        setupButtonContinue()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageIcon.image = identity.createImage(by: address ?? "", size: imageIcon.frame.size)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        accountTextField.becomeFirstResponder()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    private func setupButtonContinue() {
        buttonContinue.setTitle(Localizable.Import.Welcome.Button.continue, for: .normal)
        buttonContinue.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonContinue.setBackgroundImage(UIColor.submit400.image, for: .normal)
    }

    @IBAction func continueTapped(_ sender: Any) {
        continueCreateAccount()
    }
}

extension ImportAccountPasswordViewController {

    private func setupTextField() {
        accountTextField.update(with: InputTextField.Model(title: Localizable.NewAccount.Textfield.Accountname.title,
                                                           kind: .text,
                                                           placeholder: Localizable.NewAccount.Textfield.Accountname.title))
        passwordTextField.update(with: InputTextField.Model(title: Localizable.NewAccount.Textfield.Createpassword.title,
                                                        kind: .password,
                                                        placeholder: Localizable.NewAccount.Textfield.Createpassword.title))
        confirmPasswordTextField.update(with: InputTextField.Model(title: Localizable.NewAccount.Textfield.Confirmpassword.title,
                                                               kind: .newPassword,
                                                               placeholder: Localizable.NewAccount.Textfield.Confirmpassword.title))

        accountTextField.valueValidator = { value in
            if (value?.count ?? 0) < Constants.accountNameMinLimitSymbols {
                return Localizable.NewAccount.Textfield.Error.atleastcharacters(Constants.accountNameMinLimitSymbols)
            } else {
                return nil
            }
        }

        passwordTextField.valueValidator = { value in
            if (value?.count ?? 0) < Settings.minLengthPassword {
                return Localizable.NewAccount.Textfield.Error.atleastcharacters(Settings.minLengthPassword)
            } else {
                return nil
            }
        }

        confirmPasswordTextField.valueValidator = { [weak self] value in
            if self?.passwordTextField.value != value {
                return Localizable.NewAccount.Textfield.Error.passwordnotmatch
            }

            return nil
        }

//        let changedValue: ((Bool,String?) -> Void) = { [weak self] _,_ in
//            self?.ifNeedDisableButtonContinue()
//        }
//
//        accountTextField.changedValue = changedValue
//        passwordTextField.changedValue = changedValue
//        confirmPasswordTextField.changedValue = changedValue

        accountTextField.returnKey = .next
        passwordTextField.returnKey = .next
        confirmPasswordTextField.returnKey = .done

        accountTextField.textFieldShouldReturn = { [weak self] _ in
            self?.nextInputAfterChoiceAvatar()
        }

        passwordTextField.textFieldShouldReturn = { [weak self] _ in
            self?.nextInputAfterChoiceAvatar()
        }

        confirmPasswordTextField.textFieldShouldReturn = { [weak self] _ in
            self?.nextInputAfterChoiceAvatar()
        }
    }

    private func nextInputAfterChoiceAvatar() {
        if accountTextField.isValidValue == false {
            accountTextField.becomeFirstResponder()
        } else if passwordTextField.isValidValue == false {
            passwordTextField.becomeFirstResponder()
        } else if confirmPasswordTextField.isValidValue == false {
            confirmPasswordTextField.becomeFirstResponder()
        }  else {
            continueCreateAccount()
        }
    }

    private func continueCreateAccount() {
        guard isValidData else {
            return
        }

        guard let name = accountTextField.value?.value, let password = passwordTextField.value?.value else { return }
        delegate?.userCompletedInputAccountData(password: password, name: name)
    }

    private var isValidData: Bool {
        return accountTextField.isValidValue
            && passwordTextField.isValidValue
            && confirmPasswordTextField.isValidValue
    }
//
//    private func ifNeedDisableButtonContinue() {
//        //        buttonContinue.isEnabled = isValidData
//    }
}

extension ImportAccountPasswordViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
