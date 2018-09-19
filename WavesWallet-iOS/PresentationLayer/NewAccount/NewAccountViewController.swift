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

private enum Constants {
    static let accountNameMinLimitSymbols: Int = 2
    static let passwordMinLimitSymbols: Int = 2
}

private struct Avatar {
    let address: String
    let privateKey: PrivateKeyAccount
    let index: Int
}

enum NewAccount {
    enum DTO {
        struct Account {
            let privateKey: PrivateKeyAccount
            let password: String
            let name: String
        }
    }
}

protocol NewAccountModuleOutput: AnyObject {
    func userCompletedCreateAccount(_ account: NewAccount.DTO.Account)
}

final class NewAccountViewController: UIViewController {

    @IBOutlet private var avatars: [NewAccountAvatarView]!
    @IBOutlet private weak var labelAccountName: UILabel!
    @IBOutlet private weak var accountNameInput: NewAccountInputTextField!
    @IBOutlet private weak var passwordInput: NewAccountInputTextField!
    @IBOutlet private weak var confirmPasswordInput: NewAccountInputTextField!
    @IBOutlet private weak var buttonContinue: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var avatarTitleLabel: UILabel!
    @IBOutlet private weak var avatarDetailLabel: UILabel!

    private let identity: Identity = Identity(options: Identity.defaultOptions)
    private var isFirstChoiceAvatar: Bool = false
    private var currentAvatar: Avatar? = nil

    weak var output: NewAccountModuleOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.keyboardDismissMode = .onDrag
        title = Localizable.NewAccount.Main.Navigation.title
        avatarTitleLabel.text = Localizable.NewAccount.Avatar.title
        avatarDetailLabel.text = Localizable.NewAccount.Avatar.detail

        buttonContinue.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonContinue.setBackgroundImage(UIColor.submit400.image, for: .normal)

        setupTextField()
        setupBigNavigationBar()
        setupTopBarLine()
        setupAvatarsView()
        createBackButton()

        ifNeedDisableButtonContinue()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    // TODO: Shake

    override var canBecomeFirstResponder: Bool { return true }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            return
        }

        setupAvatarsView()
    }

    private func setupTextField() {
        accountNameInput.update(with: NewAccountInputTextField.Model(title: Localizable.NewAccount.Textfield.Accountname.title, kind: .text))
        passwordInput.update(with: NewAccountInputTextField.Model(title: Localizable.NewAccount.Textfield.Createpassword.title, kind: .password))
        confirmPasswordInput.update(with: NewAccountInputTextField.Model(title: Localizable.NewAccount.Textfield.Confirmpassword.title, kind: .newPassword))

        accountNameInput.valueValidator = { value in
            if (value?.count ?? 0) < Constants.accountNameMinLimitSymbols {
                return Localizable.NewAccount.Textfield.Error.atleastcharacters(Constants.accountNameMinLimitSymbols)
            } else {
                return nil
            }
        }

        passwordInput.valueValidator = { value in
            if (value?.count ?? 0) < Constants.passwordMinLimitSymbols {
                return Localizable.NewAccount.Textfield.Error.atleastcharacters(Constants.passwordMinLimitSymbols)
            } else {
                return nil
            }
        }

        confirmPasswordInput.valueValidator = { [weak self] value in
            if self?.passwordInput.value != value {
                return Localizable.NewAccount.Textfield.Error.passwordnotmatch
            }

            return nil
        }

        let changedValue: ((Bool,String?) -> Void) = { [weak self] _,_ in
            self?.ifNeedDisableButtonContinue()
        }

        accountNameInput.changedValue = changedValue
        passwordInput.changedValue = changedValue
        confirmPasswordInput.changedValue = changedValue

        accountNameInput.returnKey = .next
        passwordInput.returnKey = .next
        confirmPasswordInput.returnKey = .done

        accountNameInput.textFieldShouldReturn = { [weak self] _ in
            self?.nextInputAfterChoiceAvatar()
        }

        passwordInput.textFieldShouldReturn = { [weak self] _ in
            self?.nextInputAfterChoiceAvatar()
        }

        confirmPasswordInput.textFieldShouldReturn = { [weak self] _ in    
            self?.nextInputAfterChoiceAvatar()
        }
    }

    private func setupAvatarsView() {

        for object in avatars.enumerated() {

            let index = object.offset
            let view = object.element
            let seed = WordList.generatePhrase()
            let privateKey = PrivateKeyAccount(seedStr: seed)

            view.avatarDidTap = { [weak self] view, address in

                self?.currentAvatar = Avatar(address: address, privateKey: privateKey, index: index)
                self?.avatars.enumerated().filter { $0.offset != index }.forEach { $0.element.state = .unselected }
                self?.ifNeedDisableButtonContinue()

                if self?.isFirstChoiceAvatar == false {
                    self?.isFirstChoiceAvatar = true
                    self?.nextInputAfterChoiceAvatar()
                }
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
            ifNeedDisableButtonContinue()
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
        } else {
            continueCreateAccount()
        }
    }

    private func continueCreateAccount() {
        guard isValidData else {
            return
        }
        guard let name = accountNameInput.value,
            let password = passwordInput.value,
            let avatar = currentAvatar else { return }

        let account = NewAccount.DTO.Account(privateKey: avatar.privateKey, password: password, name: name)
        output?.userCompletedCreateAccount(account)
    }

    private var isValidData: Bool {
        return accountNameInput.isValidValue
            && passwordInput.isValidValue
            && confirmPasswordInput.isValidValue
            && currentAvatar != nil
    }

    private func ifNeedDisableButtonContinue() {
//        buttonContinue.isEnabled = isValidData
    }

    // MARK: Actions

    @objc func keyboardWillHide() {
        ifNeedDisableButtonContinue()
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
