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

protocol AddressInputViewDelegate: AnyObject {
    func addressInputViewDidSelectContactAtIndex(_ index: Int)
    func addressInputViewDidSelectAddressBook()
    func addressInputViewDidChangeAddress(_ address: String)
    func addressInputViewDidTapNext()
    
}

final class AddressInputView: UIView, NibOwnerLoadable {
    
    struct Input {
        let title: String
        let error: String
        let placeHolder: String
        let contacts: [String]
    }
    
    var errorValidation:((String) -> Bool)?
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var inputScrollView: InputScrollButtonsView!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonScan: UIButton!
    @IBOutlet private weak var viewContentTextField: UIView!
    @IBOutlet private weak var labelError: UILabel!
    @IBOutlet private weak var inputScrollViewHeight: NSLayoutConstraint!
    
    weak var delegate: AddressInputViewDelegate?
    private var isHiddenDeleteButton = true
    private var isShowErrorLabel = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        labelError.alpha = 0
        viewContentTextField.addTableCellShadowStyle()
        inputScrollView.inputDelegate = self
        buttonDelete.alpha = 0
        showInputScrollView(animation: false)
    }
    
    
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.showSwitchCameraButton = false
            $0.showTorchButton = true
            $0.reader = QRCodeReader()
            $0.readerView = QRCodeReaderContainer(displayable: ScannerCustomView())
            $0.preferredStatusBarStyle = .lightContent
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    //MARK: - Actions
    @IBAction private func addressDidChange(_ sender: Any) {
        setupButtonsState()
        updateHeight(animation: true)
        
        if let text = textField.text {
            delegate?.addressInputViewDidChangeAddress(text)
        }
        
        showLabelError(isShow: false)
    }
    
    @IBAction private func deleteTapped(_ sender: Any) {
        setupText("", animation: true)
        
        if let text = textField.text {
            delegate?.addressInputViewDidChangeAddress(text)
        }
        
        showLabelError(isShow: false)
    }
    
    @IBAction private func scanTapped(_ sender: Any) {
        showScanner()
    }
}

extension AddressInputView: ViewConfiguration {

    func update(with model: Input) {
        labelTitle.text = model.title
        labelError.text = model.error
        textField.placeholder = model.placeHolder
        inputScrollView.update(with: [Localizable.StartLeasing.Button.chooseFromAddressBook] + model.contacts)
    }
}

//MARK: - Methods
extension AddressInputView {
    
    func setupText(_ text: String, animation: Bool) {
        textField.text = text
        updateHeight(animation: animation)
        setupButtonsState()
    }
    
    func checkIfValidAddress() {
        if let text = textField.text, text.count > 0 {
            var showError = false
            if let validation = errorValidation {
                showError = !validation(text)
            }
            
            showLabelError(isShow: showError)
        }
        else {
            showLabelError(isShow: false)
        }
    }
}

//MARK: - InputScrollButtonsViewDelegate
extension AddressInputView: InputScrollButtonsViewDelegate {
    
    func inputScrollButtonsViewDidTapAt(index: Int) {
        if index == 0 {
            delegate?.addressInputViewDidSelectAddressBook()
        }
        else {
            delegate?.addressInputViewDidSelectContactAtIndex(index - 1)
        }
    }
}


//MARK: - UITextFieldDelegate
extension AddressInputView: UITextFieldDelegate {
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.addressInputViewDidTapNext()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkIfValidAddress()
    }
    
    private func showLabelError(isShow: Bool) {
        guard isShowErrorLabel != isShow else { return }
        isShowErrorLabel = isShow
        UIView.animate(withDuration: Constants.animationDuration) {
            self.labelError.alpha = isShow ? 1 : 0
        }
    }
}


//MARK: - SetupUI

private extension AddressInputView {
    
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

private extension AddressInputView {
    
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

private extension AddressInputView {
    
    func showScanner() {
        
        guard QRCodeReader.isAvailable() else { return }
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            if let address = result?.value {
                
                self.setupText(address, animation: false)
                self.delegate?.addressInputViewDidChangeAddress(address)
            }
            
            self.firstAvailableViewController().dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        firstAvailableViewController().present(readerVC, animated: true)
    }
}
