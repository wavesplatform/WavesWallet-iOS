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

private enum Constants {
    static let minimumLength = 25
}

final class ImportAccountManuallyViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet private weak var textField: MultyTextField!
    @IBOutlet private weak var buttonContinue: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet private weak var addressBar: UIView!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var iconImages: UIImageView!
    @IBOutlet private weak var skeletonView: SkeletonView!
    
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
        
        setupConstraints()
        setupContinueButton()
        setupTextField()
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
    }
    
    private func setupTextField() {
        textField.returnKey = .done
        
        textField.valueValidator = { value in
            guard let value = value else { return "" }
            
            if value.count > Constants.minimumLength {
                return nil
            } else {
                return ""
            }
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
        
        textField.update(with: MultyTextField.Model(title: Localizable.Waves.Import.Manually.Label.Address.title,
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
    
    func resignKeyboard() {
        textField.resignFirstResponder()
    }
    
}
