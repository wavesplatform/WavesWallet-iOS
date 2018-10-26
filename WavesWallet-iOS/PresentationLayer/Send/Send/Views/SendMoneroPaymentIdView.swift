//
//  SendMoneroPaymentId.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let paymentIdLength = 64
    static let animationDuration: TimeInterval = 0.3
    static let viewHeight: CGFloat = 98
}


final class SendMoneroPaymentIdView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelMoneroPayment: UILabel!
    @IBOutlet private weak var labelError: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var textField: UITextField!
    
    private var isShowError = false
    private var hasErrorFromServer = false
    
    var didTapNext:(() -> Void)?
    var paymentIdDidChange:((String) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelError.alpha = 0
        setupLocalization()
        viewContainer.addTableCellShadowStyle()
        setupDefaultHeight(animation: false)
    }
  
    var isVisible: Bool {
        return heightConstraint.constant > 0
    }
    
    func setupDefaultHeight(animation: Bool) {
        heightConstraint.constant = Constants.viewHeight
        
        if animation {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.firstAvailableViewController().view.layoutIfNeeded()
            }
        }
    }
    
    func setupZeroHeight(animation: Bool) {
        hideError(animation: animation)
        heightConstraint.constant = 0
        if animation {
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.firstAvailableViewController().view.layoutIfNeeded()
            }) { (_) in
                self.textField.text = nil
            }
        }
        else {
            textField.text = nil
        }
    }
    
    func activateTextField() {
        textField.becomeFirstResponder()
    }
    
    var paymentID: String {
        return textField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    }
    
    var isValidPaymentID: Bool {
        return paymentID.count == Constants.paymentIdLength && !hasErrorFromServer
    }
    
    func showErrorFromServer() {
        hasErrorFromServer = true
        showError(animation: true)
    }
    
    @IBAction private func textFieldDidChange(_ sender: Any) {
        
        hasErrorFromServer = false
        paymentIdDidChange?(paymentID)
        hideError(animation: true)
    }
    
}

//MARK: - UITextFieldDelegate
extension SendMoneroPaymentIdView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapNext?()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isShow = (paymentID.count != Constants.paymentIdLength && paymentID.count > 0) || hasErrorFromServer
        
        if isShow {
            showError(animation: true)
        }
        else {
            hideError(animation: true)
        }
    }
}

//MARK: - UI
private extension SendMoneroPaymentIdView {
    
    func showError(animation: Bool) {
        if !isShowError {
            isShowError = true
            if animation {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.labelError.alpha = 1
                }
            }
            else {
                self.labelError.alpha = 1
            }
        }
    }
    
    func hideError(animation: Bool) {
        if isShowError {
            isShowError = false
            if animation {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.labelError.alpha = 0
                }
            }
            else {
                self.labelError.alpha = 0
            }
        }
          
    }
    
    func setupLocalization() {
        labelError.text = Localizable.Send.Label.Error.invalidId
        labelMoneroPayment.text = Localizable.Send.Label.moneroPaymentId
        textField.placeholder = Localizable.Send.Textfield.placeholderPaymentId
    }
}

//MARK: - NSLayoutConstraint

private extension SendMoneroPaymentIdView {
    
    var heightConstraint: NSLayoutConstraint {
        
        if let constraint = constraints.first(where: {$0.firstAttribute == .height}) {
            return constraint
        }
        return NSLayoutConstraint()
    }
}
