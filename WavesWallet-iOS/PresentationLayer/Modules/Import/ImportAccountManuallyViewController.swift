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
import RxSwift

protocol ImportWelcomeBackViewControllerDelegate: AnyObject {
    func userCompletedInputSeed(_ keyAccount: PrivateKeyAccount)
}

private enum Constants {
    static let skeletonDelay: TimeInterval = 0.75
}

final class ImportAccountManuallyViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet private weak var textField: MultilineTextField!
    @IBOutlet private weak var buttonContinue: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet private weak var addressBar: UIView!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var iconImages: UIImageView!
    @IBOutlet private weak var skeletonView: SkeletonView!
    @IBOutlet private weak var skeletonEmpty: UIView!
    
    @IBOutlet weak var textFieldHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var skeletonViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var skeletonViewLeftConstraint: NSLayoutConstraint!

    private let disposeBag: DisposeBag = DisposeBag()
    private let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

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
        hideSkeletonAnimation()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textFieldHeightConstraint.constant = textField.height
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

        guard let currentKeyAccount = currentKeyAccount else { return }

        auth
            .existWallet(by: currentKeyAccount.getPublicKeyStr())
            .subscribe(onNext: { [weak self] wallet in
                self?.textField.error = Localizable.Waves.Import.General.Error.alreadyinuse
            }, onError: { [weak self] _ in
                self?.delegate?.userCompletedInputSeed(currentKeyAccount)

            })
            .disposed(by: disposeBag)
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
    
    private func showSkeletonAnimation() {
        if skeletonView.isHidden {
            skeletonView.isHidden = false
            skeletonView.startAnimation()
        }
        skeletonEmpty.isHidden = true
    }
    
    @objc private func hideSkeletonAnimation() {
        skeletonView.isHidden = true
        skeletonView.stopAnimation()
        skeletonEmpty.isHidden = textField.isValidValue
    }
}

extension ImportAccountManuallyViewController: MultilineTextFieldDelegate {
    
    func multilineTextFieldShouldReturn(textField: MultilineTextField) {
        completedInput()
    }
    
    func multilineTextFieldDidChange(textField: MultilineTextField) {
        
        buttonContinue.isEnabled = textField.isValidValue
        textField.error = nil

        if textField.isValidValue {
            addressBar.isHidden = false
            createAccount(seed: textField.value)
            hideSkeletonAnimation()
        } else {
            showSkeletonAnimation()
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideSkeletonAnimation), object: nil)
            perform(#selector(hideSkeletonAnimation), with: nil, afterDelay: Constants.skeletonDelay)
            addressBar.isHidden = true
        }
        
        if textFieldHeightConstraint.constant != textField.height {
            textFieldHeightConstraint.constant = textField.height

            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    func multilineTextField(textField: MultilineTextField, errorTextForValue value: String) -> String? {
        if value.count >= GlobalConstants.minimumSeedLength {
            return nil
        } else {
            return ""
        }
    }
    
}
