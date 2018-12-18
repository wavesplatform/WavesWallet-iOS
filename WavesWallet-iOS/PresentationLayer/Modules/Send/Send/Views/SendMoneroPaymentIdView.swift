//
//  SendMoneroPaymentId.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader

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
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonScan: UIButton!
    
    private var isShowError = false
    private var hasErrorFromServer = false
    private var isHiddenDeleteButton = true

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
        buttonDelete.alpha = 0
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
        updateUI(animation: true)
    }
    
    @IBAction private func deleteTapped(_ sender: Any) {
        textField.text = ""
        updateUI(animation: true)
    }
    
    @IBAction private func scanTapped(_ sender: Any) {

        CameraAccess.requestAccess(success: { [weak self] in
            self?.showScanner()
        }, failure: { [weak self] in
                let alert = CameraAccess.alertController
            self?.firstAvailableViewController().present(alert, animated: true, completion: nil)
        })
    }
    
    private lazy var readerVC: QRCodeReaderViewController = QRCodeReaderFactory.deffaultCodeReader
}

//MARK: - UITextFieldDelegate
extension SendMoneroPaymentIdView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapNext?()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateError(animation: true)
    }
    
    private func validateError(animation: Bool) {
        let isShow = (paymentID.count != Constants.paymentIdLength && paymentID.count > 0) || hasErrorFromServer
        
        if isShow {
            showError(animation: animation)
        }
        else {
            hideError(animation: animation)
        }
    }
}

//MARK: - UI
private extension SendMoneroPaymentIdView {
    
    func updateUI(animation: Bool) {
        hasErrorFromServer = false
        paymentIdDidChange?(paymentID)
        
        if !textField.isFirstResponder {
            validateError(animation: animation)
        }
        else {
            hideError(animation: animation)
        }
        
        let text = textField.text ?? ""
        
        if text.count > 0 {
            if isHiddenDeleteButton {
                isHiddenDeleteButton = false
                
                if animation {
                    UIView.animate(withDuration: Constants.animationDuration) {
                        self.buttonDelete.alpha = 1
                        self.buttonScan.alpha = 0
                    }
                }
                else {
                    self.buttonDelete.alpha = 1
                    self.buttonScan.alpha = 0
                }
            }
        }
        else {
            if !isHiddenDeleteButton {
                isHiddenDeleteButton = true
                
                if animation {
                    UIView.animate(withDuration: Constants.animationDuration) {
                        self.buttonDelete.alpha = 0
                        self.buttonScan.alpha = 1
                    }
                }
                else {
                    self.buttonDelete.alpha = 0
                    self.buttonScan.alpha = 1
                }
            }
        }
    }
    
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
        labelError.text = Localizable.Waves.Send.Label.Error.invalidId
        labelMoneroPayment.text = Localizable.Waves.Send.Label.moneroPaymentId
        textField.placeholder = Localizable.Waves.Send.Textfield.placeholderPaymentId
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

private extension SendMoneroPaymentIdView {
    
    func showScanner() {
        
        guard QRCodeReader.isAvailable() else { return }
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            if let value = result?.value {
                
                self.textField.text = value
                self.updateUI(animation: false)
            }
            
            self.firstAvailableViewController().dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        firstAvailableViewController().present(readerVC, animated: true)
    }
}
