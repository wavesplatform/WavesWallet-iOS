//
//  EditAccountNameViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import IdentityImg

final class EditAccountNameViewController: UIViewController {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var labelAccountName: UILabel!
    @IBOutlet private weak var labelAccountAddress: UILabel!
    
    @IBOutlet private weak var accountImageView: UIImageView!
    
    @IBOutlet private weak var accountNameInput: InputTextField!
    
    @IBOutlet private weak var saveButtonBottomConstraint: NSLayoutConstraint!

    private let authorization: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let disposeBag: DisposeBag = DisposeBag()

    var wallet: DomainLayer.DTO.Wallet!
    private let identity: Identity = Identity(options: Identity.defaultOptions)
    
    fileprivate var keyboardHeight: CGFloat = 0
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .basic50
        
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 42, right: 0)
        scrollView.showsVerticalScrollIndicator = false
        
        setupNavigation()
        setupSaveButton()
        fillLabels()
        
        containerView.addTableCellShadowStyle()
        
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
        saveButton.setTitle(Localizable.Waves.Editaccountname.Button.save, for: .normal)
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
            let trimmedValue = value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
            if trimmedValue.count < GlobalConstants.accountNameMinLimitSymbols {
                return Localizable.Waves.Newaccount.Textfield.Error.atleastcharacters(GlobalConstants.accountNameMinLimitSymbols)
            } else if trimmedValue.count > GlobalConstants.accountNameMaxLimitSymbols {
                return Localizable.Waves.Newaccount.Textfield.Error.charactersmaximum(GlobalConstants.accountNameMaxLimitSymbols)
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
                                               name: UIResponder.keyboardWillChangeFrameNotification,
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

        guard var wallet = self.wallet else { return }
        guard let accountNameInput = self.accountNameInput else { return }
        guard let newName = accountNameInput.value else { return }
        wallet.name = newName
        authorization
            .changeWallet(wallet)
            .subscribeNext(weak: self, { $0.save })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Content
    
    
    private func save(_ wallet: DomainLayer.DTO.Wallet) {
        navigationController?.popViewController(animated: true)
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
        
        let frameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let animationOptions = UIView.AnimationOptions(rawValue: curve << 16)
        
        let insets = layoutInsets
        let keyboardRect = view.convert(frameEnd, from: nil)
        let h = max(view.bounds.height - keyboardRect.origin.y - insets.bottom, 0)
        
        keyboardHeight = h
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: { [weak self] in
           self?.layoutSaveButton()
            }, completion: nil)
    }
    
}
