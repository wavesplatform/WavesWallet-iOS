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

        labelAddress.text = address

        createBackButton()
        setupBigNavigationBar()
        hideTopBarLine()

        setupTextField()
        setupButtonContinue()
        
        accountTextField.changedValue = { [weak self] (_, _) in
            self?.setupButtonContinue()
        }
        passwordTextField.changedValue = { [weak self] (_, _) in
            self?.setupButtonContinue()
        }
        confirmPasswordTextField.changedValue = { [weak self] (_, _) in
            self?.setupButtonContinue()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageIcon.image = identity.createImage(by: address ?? "", size: imageIcon.frame.size)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        accountTextField.becomeFirstResponder()
    }

    private func setupButtonContinue() {
        buttonContinue.isEnabled = isValidData
        buttonContinue.setTitle(Localizable.Waves.Import.Password.Button.continue, for: .normal)
        buttonContinue.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonContinue.setBackgroundImage(UIColor.submit400.image, for: .normal)
    }

    @IBAction func continueTapped(_ sender: Any) {
        continueCreateAccount()
    }
    
}

extension ImportAccountPasswordViewController {

    private func setupTextField() {

        accountTextField.autocapitalizationType = .words
        passwordTextField.autocapitalizationType = .none
        confirmPasswordTextField.autocapitalizationType = .none

        accountTextField.update(with: InputTextField.Model(title: Localizable.Waves.Newaccount.Textfield.Accountname.title,
                                                           kind: .text,
                                                           placeholder: Localizable.Waves.Newaccount.Textfield.Accountname.title))
        passwordTextField.update(with: InputTextField.Model(title: Localizable.Waves.Newaccount.Textfield.Createpassword.title,
                                                        kind: .password,
                                                        placeholder: Localizable.Waves.Newaccount.Textfield.Createpassword.title))
        confirmPasswordTextField.update(with: InputTextField.Model(title: Localizable.Waves.Newaccount.Textfield.Confirmpassword.title,
                                                               kind: .newPassword,
                                                               placeholder: Localizable.Waves.Newaccount.Textfield.Confirmpassword.title))

        accountTextField.valueValidator = { value in
            let count = value?.trimmingCharacters(in: .whitespaces).count ?? 0

            if count < GlobalConstants.accountNameMinLimitSymbols {
                return Localizable.Waves.Newaccount.Textfield.Error.atleastcharacters(GlobalConstants.accountNameMinLimitSymbols)
            }
            else if count > GlobalConstants.accountNameMaxLimitSymbols {
                return Localizable.Waves.Newaccount.Textfield.Error.maximumcharacters(GlobalConstants.accountNameMaxLimitSymbols)
            }
            else {
                return nil
            }
        }

        passwordTextField.valueValidator = { value in
            if (value?.count ?? 0) < GlobalConstants.minLengthPassword {
                return Localizable.Waves.Newaccount.Textfield.Error.atleastcharacters(GlobalConstants.minLengthPassword)
            } else {
                return nil
            }
        }

        confirmPasswordTextField.valueValidator = { [weak self] value in
            if self?.passwordTextField.value != value {
                return Localizable.Waves.Newaccount.Textfield.Error.passwordnotmatch
            }

            return nil
        }

        accountTextField.returnKey = .next
        passwordTextField.returnKey = .next
        confirmPasswordTextField.returnKey = .done

        accountTextField.textFieldShouldReturn = { [weak self] _ in
            self?.nextInput()
        }

        passwordTextField.textFieldShouldReturn = { [weak self] _ in
            self?.nextInput()
        }

        confirmPasswordTextField.textFieldShouldReturn = { [weak self] _ in
            self?.nextInput()
        }
    }

    private func nextInput() {
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
}

extension ImportAccountPasswordViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
