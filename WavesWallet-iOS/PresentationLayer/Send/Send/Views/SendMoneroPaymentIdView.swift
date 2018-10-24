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
}


final class SendMoneroPaymentIdView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelMoneroPayment: UILabel!
    @IBOutlet private weak var labelError: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var textField: UITextField!
    
    private var isShowError = false
    
    var didChangePaymentId:((String) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelError.alpha = 0
        setupLocalization()
        viewContainer.addTableCellShadowStyle()
        setupDefaultHeight()
    }
    
    @IBAction private func textFieldDidChange(_ sender: Any) {
        
        guard let text = textField.text else { return }
        didChangePaymentId?(text)
        
        showError(text.count != Constants.paymentIdLength, animation: true)
    }
    
    func setupDefaultHeight() {
        heightConstraint.constant = viewContainer.frame.origin.y + viewContainer.frame.size.height
    }
    
    func setupZeroHeight() {
        heightConstraint.constant = 0
    }
    
    private func showError(_ isShow: Bool, animation: Bool) {
        
        if isShow {
            if !isShowError {
                isShowError = true
                if animation {
                    UIView.animate(withDuration: Constants.animationDuration) {
                        self.labelError.alpha = 1
                    }
                }
                else {
                    labelError.alpha = 1
                }
            }
        }
        else {
            if isShowError {
                isShowError = false
                if animation {
                    UIView.animate(withDuration: Constants.animationDuration) {
                        self.labelError.alpha = 0
                    }
                }
                else {
                    labelError.alpha = 0
                }
            }
        }
    }
    
    private func setupLocalization() {
        labelError.text = Localizable.Send.Label.Error.invalidId
        labelMoneroPayment.text = Localizable.Send.Label.moneroPaymentId
        textField.placeholder = Localizable.Send.Textfield.placeholderPaymentId
    }
}

private extension SendMoneroPaymentIdView {
    
    var heightConstraint: NSLayoutConstraint {
        
        if let constraint = constraints.first(where: {$0.firstAttribute == .height}) {
            return constraint
        }
        return NSLayoutConstraint()
    }
}
