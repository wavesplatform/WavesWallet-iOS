//
//  NewAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import IdentityImg

private struct Avatar {
    let key: String
    let index: Int
}

enum NewAccount {
    enum DTO {
        struct Account {
            let seed: String
            let hash: String
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

    private let identity: Identity = Identity(options: Identity.defaultOptions)
    private var currentAvatar: Avatar?
    weak var output: NewAccountModuleOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.keyboardDismissMode = .onDrag
        title = Localizable.NewAccount.Main.Navigation.title

        setupTextField()
        setupBigNavigationBar()
        setupTopBarLine()
        setupAvatarsView()
        createBackButton()

        ifNeedDisableButtonContinue()
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
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
        accountNameInput.update(with: NewAccountInputTextField.Model(title: "Account name", kind: .text))
        passwordInput.update(with: NewAccountInputTextField.Model(title: "Create a password", kind: .password))
        confirmPasswordInput.update(with: NewAccountInputTextField.Model(title: "Confirm password", kind: .password))

//        accountNameInput.valueValidator = { value in
//            if value?.count == 0 {
//                return "at least 8 characters"
//            } else {
//                return nil
//            }
//        }
//
//        passwordInput.valueValidator = { value in
//            if (value?.count ?? 0) < 8 {
//                return "at least 8 characters"
//            } else {
//                return nil
//            }
//        }
//
//        confirmPasswordInput.valueValidator = { [weak self] value in
//            if self?.passwordInput.value != value {
//                return "Differnt password"
//            }
//
//            return nil
//        }
//
//        let changedValue: ((Bool,String?) -> Void) = { [weak self] _,_ in
//            self?.ifNeedDisableButtonContinue()
//        }
//
//        accountNameInput.changedValue = changedValue
//        passwordInput.changedValue = changedValue
//        confirmPasswordInput.changedValue = changedValue
//
//        accountNameInput.returnKey = .next
//        passwordInput.returnKey = .next
//        confirmPasswordInput.returnKey = .done
//
//        accountNameInput.textFieldShouldReturn = { [weak self] _ in
//            self?.passwordInput.becomeFirstResponder()
//        }
//
//        passwordInput.textFieldShouldReturn = { [weak self] _ in
//            self?.confirmPasswordInput.becomeFirstResponder()
//        }
    }

    private func setupAvatarsView() {

        for object in avatars.enumerated() {

            let index = object.offset
            let view = object.element
            let key = WordList.generatePhrase()
            let decoded = Base58.decode(key)

            view.avatarDidTap = { [weak self] view, key in
                self?.currentAvatar = Avatar(key: key, index: index)
                self?.avatars.enumerated().filter { $0.offset != index }.forEach { $0.element.state = .unselected }
            }

            let image = identity.createImage(by: key, size: view.iconSize) ?? UIImage()
            view.update(with: .init(icon: image, key: key))
            view.state = .none
        }

        if let currentAvatar = currentAvatar, let key = avatars[currentAvatar.index].key {
            self.currentAvatar = Avatar(key: key, index: currentAvatar.index)
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

    @objc func keyboardWillHide() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    @IBAction func continueTapped(_ sender: Any) {
        guard isValidData else { return }


//        output?.userCompletedCreateAccount(
//        let controller = storyboard?.instantiateViewController(withIdentifier: "NewAccountSecretPhraseViewController") as! NewAccountSecretPhraseViewController
//        navigationController?.pushViewControllerAndSetLast(controller)
    }

    private var isValidData: Bool {
        return accountNameInput.isValidValue
            && passwordInput.isValidValue
            && confirmPasswordInput.isValidValue
            && currentAvatar != nil
    }

    private func ifNeedDisableButtonContinue() {

        if isValidData {
            buttonContinue.setupButtonActiveState()
        } else {
            buttonContinue.setupButtonDeactivateState()
        }
    }
}

extension NewAccountViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
