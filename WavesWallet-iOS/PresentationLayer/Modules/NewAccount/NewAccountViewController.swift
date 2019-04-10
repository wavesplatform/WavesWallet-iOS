//
//  NewAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import IdentityImg
import IQKeyboardManagerSwift
import WavesSDKExtension
import WavesSDKCrypto

private struct Avatar {
    let address: String
    let privateKey: PrivateKeyAccount
    let index: Int
}

protocol NewAccountModuleOutput: AnyObject {
    func userCompletedCreateAccount(_ account: NewAccountTypes.DTO.Account)
}

final class NewAccountViewController: UIViewController {

    @IBOutlet private var avatars: [NewAccountAvatarView]!
    @IBOutlet private weak var labelAccountName: UILabel!
    @IBOutlet private weak var accountNameInput: InputTextField!
    @IBOutlet private weak var passwordInput: InputTextField!
    @IBOutlet private weak var confirmPasswordInput: InputTextField!
    @IBOutlet private weak var buttonContinue: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var avatarTitleLabel: UILabel!
    @IBOutlet private weak var avatarDetailLabel: UILabel!

    private let identity: Identity = Identity(options: Identity.defaultOptions)
    private var currentAvatar: Avatar? = nil

    weak var output: NewAccountModuleOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.keyboardDismissMode = .onDrag
        title = Localizable.Waves.Newaccount.Main.Navigation.title
        avatarTitleLabel.text = Localizable.Waves.Newaccount.Avatar.title
        avatarDetailLabel.text = Localizable.Waves.Newaccount.Avatar.detail

        buttonContinue.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonContinue.setBackgroundImage(UIColor.submit400.image, for: .normal)

        setupTextField()
        setupBigNavigationBar()
        setupTopBarLine()
        setupAvatarsView()
        createBackButton()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override var canBecomeFirstResponder: Bool { return true }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            return
        }

        setupAvatarsView()
    }

    private func setupTextField() {

        accountNameInput.autocapitalizationType = .words
        passwordInput.autocapitalizationType = .none
        confirmPasswordInput.autocapitalizationType = .none
        
        accountNameInput.update(with: InputTextField.Model(title: Localizable.Waves.Newaccount.Textfield.Accountname.title,
                                                           kind: .text,
                                                           placeholder: Localizable.Waves.Newaccount.Textfield.Accountname.title))
        passwordInput.update(with: InputTextField.Model(title: Localizable.Waves.Newaccount.Textfield.Createpassword.title,
                                                        kind: .password,
                                                        placeholder: Localizable.Waves.Newaccount.Textfield.Createpassword.title))
        confirmPasswordInput.update(with: InputTextField.Model(title: Localizable.Waves.Newaccount.Textfield.Confirmpassword.title,
                                                               kind: .newPassword,
                                                               placeholder: Localizable.Waves.Newaccount.Textfield.Confirmpassword.title))

        accountNameInput.valueValidator = { value in
            let count = value?.trimmingCharacters(in: .whitespaces).count ?? 0
            if count < UIGlobalConstants.accountNameMinLimitSymbols {
                return Localizable.Waves.Newaccount.Textfield.Error.atleastcharacters(UIGlobalConstants.accountNameMinLimitSymbols)
            } else if count > UIGlobalConstants.accountNameMaxLimitSymbols {
                return Localizable.Waves.Newaccount.Textfield.Error.maximumcharacters(UIGlobalConstants.accountNameMaxLimitSymbols)
            } else {
                return nil
            }
        }

        passwordInput.valueValidator = { value in
            if (value?.count ?? 0) < UIGlobalConstants.minLengthPassword {
                return Localizable.Waves.Newaccount.Textfield.Error.atleastcharacters(UIGlobalConstants.minLengthPassword)
            } else {
                return nil
            }
        }

        confirmPasswordInput.valueValidator = { [weak self] value in

            if self?.passwordInput.value != value {
                return Localizable.Waves.Newaccount.Textfield.Error.passwordnotmatch
            } else {
                return nil
            }
        }

        accountNameInput.returnKey = .next
        passwordInput.returnKey = .next
        confirmPasswordInput.returnKey = .done

        accountNameInput.textFieldShouldReturn = { [weak self] _ in

            guard let self = self else { return }

            if self.accountNameInput.isValidValue == true {
                self.passwordInput.becomeFirstResponder()
            }
        }

        passwordInput.textFieldShouldReturn = { [weak self] _ in
            guard let self = self else { return }
            if self.passwordInput.isValidValue == true {
                self.confirmPasswordInput.becomeFirstResponder()
            }
        }

        confirmPasswordInput.textFieldShouldReturn = { [weak self] _ in
            guard let self = self else { return }
            self.nextInputAfterChoiceAvatar()
        }
    }

    private func setupAvatarsView() {

        for object in avatars.enumerated() {

            let index = object.offset
            let view = object.element
            let seed = WordList.generatePhrase()
            let privateKey = PrivateKeyAccount(seedStr: seed)

            view.avatarDidTap = { [weak self] view, address in
                guard let self = self else { return }
                self.currentAvatar = Avatar(address: address, privateKey: privateKey, index: index)
                self.avatars.enumerated().filter { $0.offset != index }.forEach { $0.element.state = .unselected }
            }

            let image = identity.createImage(by: privateKey.address, size: view.iconSize) ?? UIImage()
            view.update(with: .init(icon: image, key: privateKey.address))
            view.state = .none
        }

        if let currentAvatar = currentAvatar, let address = avatars[currentAvatar.index].key {
            self.currentAvatar = Avatar(address: address, privateKey: currentAvatar.privateKey, index: currentAvatar.index)
            self.avatars.enumerated().forEach {
                if $0.offset != currentAvatar.index {
                    $0.element.state = .unselected
                } else {
                    $0.element.state = .selected
                }
            }
        } else {
            self.currentAvatar = nil
        }
    }

    private func nextInputAfterChoiceAvatar() {
        if accountNameInput.isValidValue == false {
            accountNameInput.becomeFirstResponder()
        } else if passwordInput.isValidValue == false {
            passwordInput.becomeFirstResponder()
        } else if confirmPasswordInput.isValidValue == false {
            confirmPasswordInput.becomeFirstResponder()
        } else if currentAvatar == nil {
            self.view.endEditing(true)
            self.avatars.forEach { $0.shake() }
            showMessageSnack(title: Localizable.Waves.Newaccount.Error.noavatarselected)
        } else {
            continueCreateAccount()
        }
    }

    private func continueCreateAccount() {
        guard isValidData else {
            return
        }

        guard let name = accountNameInput.value?.value?.trimmingCharacters(in: .whitespaces) else { return }
        guard let password = passwordInput.value?.value?.trimmingCharacters(in: .whitespaces) else { return }
        guard let avatar = currentAvatar else { return }
        
        let account = NewAccountTypes.DTO.Account(privateKey: avatar.privateKey, password: password, name: name)
        output?.userCompletedCreateAccount(account)
    }

    private var isValidData: Bool {
        return accountNameInput.isValidValue
            && passwordInput.isValidValue
            && confirmPasswordInput.isValidValue
            && currentAvatar != nil
    }

    // MARK: Actions

    @objc func keyboardWillHide() {

        //        scrollView.setContentOffset(CGPoint(x: 0, y: -0.5), animated: true)
    }

    @IBAction func continueTapped(_ sender: Any) {
        nextInputAfterChoiceAvatar()
    }
}

extension NewAccountViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
