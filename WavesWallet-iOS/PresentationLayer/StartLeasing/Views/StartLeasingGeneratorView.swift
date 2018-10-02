//
//  StartLeasingGeneratorView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
}

protocol StartLeasingGeneratorViewDelegate: AnyObject {
    func startLeasingGeneratorViewDidSelectAddressBook()
    func startLeasingGeneratorViewDidChangeAddress(_ address: String)
}

final class StartLeasingGeneratorView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var inputScrollView: InputScrollButtonsView!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonScan: UIButton!
    @IBOutlet private weak var viewContentTextField: UIView!
    @IBOutlet private weak var labelError: UILabel!
    @IBOutlet private weak var inputScrollViewHeight: NSLayoutConstraint!
    
    weak var delegate: StartLeasingGeneratorViewDelegate?
    private var lastContacts: [DomainLayer.DTO.Contact] = []
    private var isHiddenDeleteButton = true
    private var isShowErrorLabel = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelTitle.text = Localizable.StartLeasing.Label.generator
        labelError.text = Localizable.StartLeasing.Label.addressIsNotValid
        labelError.alpha = 0
        textField.placeholder = Localizable.StartLeasing.Label.nodeAddress
        viewContentTextField.addTableCellShadowStyle()
        inputScrollView.inputDelegate = self
        buttonDelete.alpha = 0
        showInputScrollView(animation: false)
        inputScrollView.update(with: [Localizable.StartLeasing.Button.chooseFromAddressBook])
    }
    
    
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.showSwitchCameraButton = false
            $0.showTorchButton = true
            $0.reader = QRCodeReader()
            $0.readerView = QRCodeReaderContainer(displayable: ScannerCustomView())
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
}

//MARK: - Methods
extension StartLeasingGeneratorView {
    
    func setupText(_ text: String, animation: Bool) {
        textField.text = text
        updateHeight(animation: animation)
        setupButtonsState()
    }
}

//MARK: - InputScrollButtonsViewDelegate
extension StartLeasingGeneratorView: InputScrollButtonsViewDelegate {
    
    func inputScrollButtonsViewDidTapAt(index: Int) {
        delegate?.startLeasingGeneratorViewDidSelectAddressBook()
    }
}


//MARK: - UITextFieldDelegate
extension StartLeasingGeneratorView: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.count > 0 {
            showLabelError(isShow: !Address.isValidAddress(address: text))
        }
        else {
            showLabelError(isShow: false)
        }
    }
    
    private func showLabelError(isShow: Bool) {
        guard isShowErrorLabel != isShow else { return }
        isShowErrorLabel = isShow
        UIView.animate(withDuration: Constants.animationDuration) {
            self.labelError.alpha = isShow ? 1 : 0
        }
    }
}

//MARK: - Actions
private extension StartLeasingGeneratorView {
    
    @IBAction func addressDidChange(_ sender: Any) {
        setupButtonsState()
        updateHeight(animation: true)
        
        if let text = textField.text {
            delegate?.startLeasingGeneratorViewDidChangeAddress(text)
        }
        
        showLabelError(isShow: false)
    }
   
    @IBAction func deleteTapped(_ sender: Any) {
        setupText("", animation: true)
        
        if let text = textField.text {
            delegate?.startLeasingGeneratorViewDidChangeAddress(text)
        }
        
        showLabelError(isShow: false)
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        showScanner()
    }
}

//MARK: - SetupUI

private extension StartLeasingGeneratorView {
    
    func setupButtonsState() {
        if textField.text?.count ?? 0 > 0 {
            
            if isHiddenDeleteButton {
               isHiddenDeleteButton = false
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.buttonDelete.alpha = 1
                    self.buttonScan.alpha = 0
                }
                
                hideInputScrollView(animation: true)
            }
        }
        else {
            if !isHiddenDeleteButton {
                isHiddenDeleteButton = true
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.buttonDelete.alpha = 0
                    self.buttonScan.alpha = 1
                }
                
                showInputScrollView(animation: true)
            }
        }
    }
}

//MARK: - Change frame

private extension StartLeasingGeneratorView {
    
    func updateHeight(animation: Bool) {
        
        if textField.text?.count ?? 0 > 0 {
            hideInputScrollView(animation: animation)
        }
        else {
            showInputScrollView(animation: animation)
        }
    }
    
    func showInputScrollView(animation: Bool) {
        
        let height = inputScrollView.frame.origin.y + inputScrollView.frame.size.height
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        updateWithAnimationIfNeed(animation: animation, isShowInputScrollView: true)
    }
    
    func hideInputScrollView(animation: Bool) {

        let height = viewContentTextField.frame.origin.y + viewContentTextField.frame.size.height
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        updateWithAnimationIfNeed(animation: animation, isShowInputScrollView: false)
    }
    
    func updateWithAnimationIfNeed(animation: Bool, isShowInputScrollView: Bool) {
        if animation {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.firstAvailableViewController().view.layoutIfNeeded()
                self.inputScrollView.alpha = isShowInputScrollView ? 1 : 0
            }
        }
        else {
            inputScrollView.alpha = isShowInputScrollView ? 1 : 0
        }
    }
    
    var heightConstraint: NSLayoutConstraint {
        
        if let constraint = constraints.first(where: {$0.firstAttribute == .height}) {
            return constraint
        }
        return NSLayoutConstraint()
    }
}

//MARK: - QRCodeReader

private extension StartLeasingGeneratorView {

    func showScanner() {
        
        guard QRCodeReader.isAvailable() else { return }
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
            
            if let address = result?.value {
                
                self.setupText(address, animation: false)
                self.delegate?.startLeasingGeneratorViewDidChangeAddress(address)
            }
            
            self.firstAvailableViewController().dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        firstAvailableViewController().present(readerVC, animated: true) {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
    }
}
