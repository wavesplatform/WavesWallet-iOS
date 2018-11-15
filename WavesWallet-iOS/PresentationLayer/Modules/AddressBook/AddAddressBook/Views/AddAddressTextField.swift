//
//  AddAddressNameTextField.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader


private enum Constansts {
    static let rightButtonOffset: CGFloat = 45
    static let animationDuration: TimeInterval = 0.3
}

protocol AddAddressTextFieldDelegate: AnyObject {
    func addAddressTextField(_ textField: AddAddressTextField, didChange text: String)
    func addressTextFieldTappedNext()
}

final class AddAddressTextField: UIView, NibOwnerLoadable {

    @IBOutlet private weak var addressTextField: InputTextField!
    @IBOutlet private var buttonDelete: UIButton!
    @IBOutlet private var buttonScan: UIButton!
    
    private var isShowDeleteButton = false
    
    weak var delegate: AddAddressTextFieldDelegate?
    
    var text: String {
        set (newValue) {
            addressTextField.value = newValue
            setupButtonsState(animation: false)
        }
        get {
            return addressTextField.value ?? ""
        }
    }

    var isEnabled: Bool = true {
        didSet {
            addressTextField.isEnabled = isEnabled
            buttonDelete.isHidden = !isEnabled
            buttonScan.isHidden = !isEnabled
        }
    }
    
    var trimmingText: String {
        return text.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addressTextField.returnKey = .next

        addressTextField.update(with: .init(title: Localizable.Waves.Addaddressbook.Label.address,
                                            kind: .text,
                                            placeholder: Localizable.Waves.Addaddressbook.Label.address))

        addressTextField.textFieldShouldReturn = { [weak self] _ in
            self?.delegate?.addressTextFieldTappedNext()
        }

        addressTextField.changedValue = { [weak self] (_, value) in
            guard let owner = self else { return }
            owner.delegate?.addAddressTextField(owner, didChange: value ?? "")
            owner.setupButtonsState(animation: true)
        }

        addressTextField.rightView = buttonScan
        buttonDelete.alpha = 0
        setupButtonsState(animation: false)
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        return addressTextField.becomeFirstResponder()
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
}

//MARK: - Actions

private extension AddAddressTextField {

    
    @IBAction func deleteTapped(_ sender: Any) {
        self.addressTextField.value = nil
        setupButtonsState(animation: true)
        delegate?.addAddressTextField(self, didChange: text)
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        showScanner()
    }
}

private extension AddAddressTextField {
    func setupButtonsState(animation: Bool) {
        
        if text.count > 0 {
            if !isShowDeleteButton {
                isShowDeleteButton = true

                UIView.animate(withDuration: animation ? Constansts.animationDuration : 0) {
                    self.buttonDelete.alpha = 1
                    self.buttonScan.alpha = 0
                    self.addressTextField.rightView = self.buttonDelete
                }
            }
        } else {
            if isShowDeleteButton {
                isShowDeleteButton = false
                UIView.animate(withDuration: animation ? Constansts.animationDuration : 0) {
                    self.buttonDelete.alpha = 0
                    self.buttonScan.alpha = 1
                    self.addressTextField.rightView = self.buttonScan
                }
            }
        }
    }
}

//MARK: - QRCodeReaderViewController

private extension AddAddressTextField {
    
    func showScanner() {
        
        guard QRCodeReader.isAvailable() else { return }
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            if let address = result?.value {
                
                self.addressTextField.value = address
                self.setupButtonsState(animation: true)
                self.delegate?.addAddressTextField(self, didChange: self.text)
            }
            
            self.firstAvailableViewController().dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet

        firstAvailableViewController().present(readerVC, animated: true)
    }
}
