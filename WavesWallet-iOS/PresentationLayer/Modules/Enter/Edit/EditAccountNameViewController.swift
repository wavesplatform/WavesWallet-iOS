//
//  EditAccountNameViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import IdentityImg

private enum Constants {
    
    static let shadowOptions = ShadowOptions(offset: CGSize(width: 0, height: 4),
                                             color: .black,
                                             opacity: 0.1,
                                             shadowRadius: 4,
                                             shouldRasterize: true)
    
}

class EditAccountNameViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var labelAccountName: UILabel!
    @IBOutlet weak var labelAccountAddress: UILabel!
    
    @IBOutlet weak var accountImageView: UIImageView!
    
    @IBOutlet weak var accountNameInput: InputTextField!
    
   @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    
    var wallet: DomainLayer.DTO.Wallet!
    private let identity: Identity = Identity(options: Identity.defaultOptions)
    
    var keyboardHeight: CGFloat = 0
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .basic50
        
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 42, right: 0)
        
        setupNavigation()
        setupSaveButton()
        fillLabels()
        
        containerView.setupShadow(options: Constants.shadowOptions)
        containerView.cornerRadius = 2
        
        setupTextField()
        setupKeyboard()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setups

    private func setupNavigation() {
        navigationItem.title = Localizable.Waves.Editaccountname.Navigation.title
        setupBigNavigationBar()
        createBackButton()
        hideTopBarLine()
    }
    
    private func setupSaveButton() {
        saveButton.setupButtonDeactivateState()
    }
    
    private func fillLabels() {
        labelAccountName.text = wallet.name
        labelAccountAddress.text = wallet.address
        
        accountImageView.image = identity.createImage(by: wallet.address, size: accountImageView.frame.size)   
    }
    
    private func setupTextField() {
        accountNameInput.autocapitalizationType = .words
        accountNameInput.update(with: InputTextField.Model(title: Localizable.Waves.Editaccountname.Label.newName,
                                                           kind: .text,
                                                           placeholder: Localizable.Waves.Editaccountname.Label.newName))
        
        accountNameInput.valueValidator = { value in
            if (value?.count ?? 0) < GlobalConstants.accountNameMinLimitSymbols {
                return Localizable.Waves.Newaccount.Textfield.Error.atleastcharacters(GlobalConstants.accountNameMinLimitSymbols)
            } else {
                return nil
            }
        }
        
        accountNameInput.changedValue = { (isValidValue, value) in
            if isValidValue {
                self.saveButton.setupButtonActiveState()
            } else {
                self.saveButton.setupButtonDeactivateState()
            }
        }
        
        accountNameInput.returnKey = .done
    }
    
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    // MARK: - Layout
    
    fileprivate func layoutSaveButton() {
        
        saveButtonBottomConstraint.constant = keyboardHeight
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @IBAction func saveTapped(_ sender: Any) {
        save()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Content
    
    
    private func save() {
        
    }
    
}

extension EditAccountNameViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
}

extension EditAccountNameViewController {
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let animationOptions = UIViewAnimationOptions(rawValue: curve << 16)
        
        let keyboardRect = view.convert(frameEnd, from: nil)
        let h = max(view.bounds.height - keyboardRect.origin.y, 0)
        
//        let diff = h - keyboardHeight
        keyboardHeight = h
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: { [weak self] in
//            self?.adjustCollectionViewInsets(withScrollDifference: diff)
           self?.layoutSaveButton()
//            self?.layoutIfNeeded()
            }, completion: nil)
    }
    
}

//if textField.text!.count > 0 {
//    buttonSave.setupButtonActiveState()
//}
//else {
//    buttonSave.setupButtonDeactivateState()
//}
