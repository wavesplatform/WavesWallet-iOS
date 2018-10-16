//
//  ChangePasswordViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var buttonConfirm: UIButton!
    
    @IBOutlet private weak var oldPasswordInput: PasswordTextField!
    @IBOutlet private weak var passwordInput: PasswordTextField!
    @IBOutlet private weak var confirmPasswordInput: PasswordTextField!
    @IBOutlet private weak var scrollView: UIScrollView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Change password"
        createBackButton()
        setupBigNavigationBar()        
        navigationController?.navigationBar.barTintColor = .white

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
//            navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
    }

    
    private func setupTextField() {
        oldPasswordInput.update(with: PasswordTextField.Model(title: Localizable.NewAccount.Textfield.Accountname.title,
                                                              kind: .text,
                                                              placeholder: Localizable.NewAccount.Textfield.Accountname.title))
        passwordInput.update(with: PasswordTextField.Model(title: Localizable.NewAccount.Textfield.Createpassword.title,
                                                           kind: .password,
                                                           placeholder: Localizable.NewAccount.Textfield.Createpassword.title))
        confirmPasswordInput.update(with: PasswordTextField.Model(title: Localizable.NewAccount.Textfield.Confirmpassword.title,
                                                                  kind: .newPassword,
                                                                  placeholder: Localizable.NewAccount.Textfield.Confirmpassword.title))

        oldPasswordInput.valueValidator = { value in
//            if (value?.count ?? 0) < Constants.accountNameMinLimitSymbols {
//                return Localizable.NewAccount.Textfield.Error.atleastcharacters(Constants.accountNameMinLimitSymbols)
//            } else {
//                return nil
//            }
            return nil
        }

        passwordInput.valueValidator = { value in
            if (value?.count ?? 0) < Settings.minLengthPassword {
                return Localizable.NewAccount.Textfield.Error.atleastcharacters(Settings.minLengthPassword)
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

        oldPasswordInput.returnKey = .next
        passwordInput.returnKey = .next
        confirmPasswordInput.returnKey = .done

        oldPasswordInput.textFieldShouldReturn = { [weak self] _ in

        }

        passwordInput.textFieldShouldReturn = { [weak self] _ in

        }

        confirmPasswordInput.textFieldShouldReturn = { [weak self] _ in

        }
    }

}


// MARK: UIScrollViewDelegate
extension ChangePasswordViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

//        targetContentOffset.pointee = CGPoint(x: 0, y: -1)
    }
}
