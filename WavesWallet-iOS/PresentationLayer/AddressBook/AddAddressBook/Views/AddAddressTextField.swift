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
}

final class AddAddressTextField: UIView, NibOwnerLoadable {

    @IBOutlet private weak var addressTextField: BaseInputTextField!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonScan: UIButton!
    
    private var isShowDeleteButton = false
    
    weak var delegate: AddAddressTextFieldDelegate?
    
    var text: String {
        set (newValue) {
            addressTextField.setupText(newValue)
            setupButtonsState(animation: false)
        }
        get {
            return addressTextField.text
        }
    }
    
    var trimmingText: String {
        return addressTextField.trimmingText
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addressTextField.setupTextFieldRightOffset(Constansts.rightButtonOffset)
        addressTextField.setupPlaceholder(Localizable.AddAddressBook.Label.address)
        addressTextField.delegate = self
        buttonDelete.alpha = 0
        setupButtonsState(animation: false)
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
        addressTextField.setupText("", animation: true)
        setupButtonsState(animation: true)
        delegate?.addAddressTextField(self, didChange: text)
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        showScanner()
    }
}

//MARK: - BaseInputTextFieldDelegate
extension AddAddressTextField: BaseInputTextFieldDelegate {
    
    func baseInputTextField(_ textField: BaseInputTextField, didChange text: String) {
        delegate?.addAddressTextField(self, didChange: text)
        setupButtonsState(animation: true)
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
                }
            }
        }
        else {
            if isShowDeleteButton {
                isShowDeleteButton = false
                
                UIView.animate(withDuration: animation ? Constansts.animationDuration : 0) {
                    self.buttonDelete.alpha = 0
                    self.buttonScan.alpha = 1
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
                
                self.addressTextField.setupText(address, animation: true)
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
