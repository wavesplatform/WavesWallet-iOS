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

final class ImportAccountManuallyViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet private weak var textField: MultilineTextField!
    @IBOutlet private weak var buttonContinue: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet private weak var addressBar: UIView!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var iconImages: UIImageView!
    @IBOutlet private weak var skeletonView: SkeletonView!
    
    
    @IBOutlet weak var textFieldHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var skeletonViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var skeletonViewLeftConstraint: NSLayoutConstraint!
    
    private let identity: Identity = Identity(options: Identity.defaultOptions)
    
    private var currentKeyAccount: PrivateKeyAccount?
    
    weak var delegate: ImportWelcomeBackViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .basic50
        
        containerView.addTableCellShadowStyle()
        addressBar.isHidden = true
        
        setupTextField()
        setupContinueButton()
        setupConstraints()
    }
    
    private func setupConstraints() {
        if Platform.isIphone5 {
            skeletonViewLeftConstraint.constant = 12
            skeletonViewRightConstraint.constant = 12
            containerViewLeftConstraint.constant = 12
            containerViewRightConstraint.constant = 12
        } else {
            skeletonViewLeftConstraint.constant = 14
            skeletonViewRightConstraint.constant = 14
            containerViewLeftConstraint.constant = 16
            containerViewRightConstraint.constant = 16
        }
        
        textFieldHeightConstraint.constant = textField.height
    }
    
    private func setupTextField() {
        textField.delegate = self
        textField.textView.returnKeyType = .done
 
        textField.update(with: MultilineTextField.Model(title: Localizable.Waves.Import.Manually.Label.Address.title,
                                                    placeholder: Localizable.Waves.Import.Manually.Label.Address.placeholder))
        
    }
    
    private func setupContinueButton() {
        buttonContinue.setTitle(Localizable.Waves.Import.Manually.Button.continue, for: .normal)
        buttonContinue.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonContinue.setBackgroundImage(UIColor.submit400.image, for: .normal)
        buttonContinue.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        skeletonView.startAnimation()
    }
    
    // MARK: - Actions
    
    @IBAction func continueTapped(_ sender: Any) {
        completedInput()
    }
    
    // MARK: - Content
    
    private func createAccount(seed: String) {
        
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
    
    func showKeyboard(animated: Bool = true) {
        if animated {
            textField.becomeFirstResponder()
        } else {
            UIView.setAnimationsEnabled(false)
            textField.becomeFirstResponder()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func resignKeyboard(animated: Bool = true) {
        if animated {
            textField.resignFirstResponder()
        } else {
            UIView.setAnimationsEnabled(false)
            textField.resignFirstResponder()
            UIView.setAnimationsEnabled(true)
        }
    }
    
}

extension ImportAccountManuallyViewController: MultilineTextFieldDelegate {
    
    func multilineTextFieldShouldReturn(textField: MultilineTextField) {
        completedInput()
    }
    
    func multilineTextFieldDidChange(textField: MultilineTextField) {
        
        buttonContinue.isEnabled = textField.isValidValue

        if textField.isValidValue {
            addressBar.isHidden = false
            skeletonView.isHidden = true
            skeletonView.stopAnimation()
            createAccount(seed: textField.value)
        } else {
            skeletonView.isHidden = false
            skeletonView.startAnimation()
            addressBar.isHidden = true
        }
        
        if textFieldHeightConstraint.constant != textField.height {
            textFieldHeightConstraint.constant = textField.height
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    func multilineTextField(textField: MultilineTextField, errorTextForValue value: String) -> String? {
        if value.count > ImportTypes.minimumSeedLength {
            return nil
        } else {
            return ""
        }
    }
    
}
