//
//  ImportWelcomeBackViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import IdentityImg
import IQKeyboardManagerSwift

protocol ImportWelcomeBackViewControllerDelegate: AnyObject {
    func userCompletedInputSeed(_ keyAccount: PrivateKeyAccount)
}

final class ImportWelcomeBackViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet private weak var textField: MultyTextField!
    @IBOutlet private weak var buttonContinue: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var addressBar: UIView!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var iconImages: UIImageView!
    @IBOutlet private weak var skeletonView: SkeletonView!

    private let identity: Identity = Identity(options: Identity.defaultOptions)
    private var currentKeyAccount: PrivateKeyAccount?

    weak var delegate: ImportWelcomeBackViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        addressBar.isHidden = true
        title = Localizable.Import.Welcome.Navigation.title
        createBackButton()
        setupBigNavigationBar()

        buttonContinue.setTitle(Localizable.Import.Welcome.Button.continue, for: .normal)
        buttonContinue.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonContinue.setBackgroundImage(UIColor.submit400.image, for: .normal)

        textField.returnKey = .done
        textField.update(with: MultyTextField.Model(title: Localizable.Import.Welcome.Label.Address.title,
                                                    placeholder: Localizable.Import.Welcome.Label.Address.placeholder))

        textField.valueValidator = { value in
            return value?.count == 0 ? "" : nil
        }

        let changedValue: ((Bool,String?) -> Void) = { [weak self] isValidValue, value in
            self?.buttonContinue.isEnabled = isValidValue
            if let value = value, isValidValue {
                self?.addressBar.isHidden = false
                self?.skeletonView.isHidden = true
                self?.skeletonView.stopAnimation()
                self?.createAccount(seed: value)

            } else {
                self?.skeletonView.isHidden = false
                self?.skeletonView.startAnimation()
                self?.addressBar.isHidden = true
            }
        }
        textField.changedValue = changedValue

        textField.textFieldShouldReturn = { [weak self] _ in
            self?.completedInput()
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        skeletonView.startAnimation()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        textField.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    private func createAccount(seed: String) {

        let seed = WordList.generatePhrase()
        let privateKey = PrivateKeyAccount(seedStr: seed)
        currentKeyAccount = privateKey
        iconImages.image = identity.createImage(by: privateKey.address, size: iconImages.frame.size)
        labelAddress.text = privateKey.address
    }

    private func completedInput() {
        view.endEditing(true)
        if let privateKey = currentKeyAccount {
            delegate?.userCompletedInputSeed(privateKey)
        }
    }

    @IBAction func continueTapped(_ sender: Any) {
        completedInput()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
