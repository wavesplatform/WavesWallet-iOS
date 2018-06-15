//
//  StartLeasingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation

class StartLeasingViewController: BaseAmountViewController, UIScrollViewDelegate {

    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var scrollViewGenerator: UIScrollView!
    @IBOutlet weak var viewGenerator: UIView!
    @IBOutlet weak var buttonStartLease: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var heightScrollGenerator: NSLayoutConstraint!
    
    @IBOutlet weak var buttonDeleteAddress: UIButton!
    @IBOutlet weak var buttonScan: UIButton!
    
    let addresses = ["Choose from Address book", "Mike Node", "Roman", "Peter Ivanov"]
    
    var isValidAmount = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Start Leasing"
        createBackButton()
        hideTopBarLine()

        viewGenerator.addTableCellShadowStyle()
        textFieldAddress.addTarget(self, action: #selector(addressDidChange), for: .editingChanged)
        buttonDeleteAddress.alpha = 0
        setupScrollAddress()
        setupButtonStartLease()
    }
  
    func addressDidChange() {
        setupButtonStartLease()
    }
    
    func setupButtonStartLease() {
        if isValidAmount && textFieldAddress.text!.count > 0 {
            buttonStartLease.isUserInteractionEnabled = true
            buttonStartLease.backgroundColor = .submit400
        }
        else {
            buttonStartLease.isUserInteractionEnabled = false
            buttonStartLease.backgroundColor = .submit200
        }
    }
    
    @IBAction func startLeasingTapped(_ sender: Any) {
    
        textFieldAddress.shakeView()
    }
    
    override func amountTapped(_ sender: UIButton) {
        super.amountTapped(sender)
        
        isValidAmount = false
        if let value = Double(textFieldAmount.text!) {
            if value > 0 {
                isValidAmount = true
            }
        }
        
        setupButtonStartLease()
    }
    
    override func amountChange() {
        super.amountChange()
        
        isValidAmount = false
        if let value = Double(textFieldAmount.text!) {
            if value > 0 {
                isValidAmount = true
            }
        }
        
        setupButtonStartLease()
    }
 
    @IBAction func deleteAddressTapped(_ sender: Any) {
        textFieldAddress.text = nil
        
        heightScrollGenerator.constant = 30
        textFieldAddress.isEnabled = true
        UIView.animate(withDuration: 0.3) {
            self.buttonScan.alpha = 1
            self.buttonDeleteAddress.alpha = 0
            self.scrollViewGenerator.alpha = 1
            self.view.layoutIfNeeded()
        }
        
        setupButtonStartLease()
    }

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.showSwitchCameraButton = false
            $0.showTorchButton = true
            $0.reader = QRCodeReader()
            $0.readerView = QRCodeReaderContainer(displayable: ScannerCustomView())
        }

        return QRCodeReaderViewController(builder: builder)
    }()

    @IBAction func scanTapped(_ sender: Any) {
        guard QRCodeReader.isAvailable() else { return }
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            UIApplication.shared.setStatusBarStyle(.default, animated: true)

            if let address = result?.value {
                self.textFieldAddress.text = address
                self.updateAddressState()
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true) {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
    }
    
    func updateAddressState() {
        heightScrollGenerator.constant = 0
        textFieldAddress.isEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.buttonScan.alpha = 0
            self.buttonDeleteAddress.alpha = 1
            self.scrollViewGenerator.alpha = 0
            self.view.layoutIfNeeded()
        }
        
        setupButtonStartLease()
    }
    
    func addresesTapped(_ sender: UIButton) {
        
        let index = sender.tag
        
        if index == 0 {
            
        }
        else {
            let value = addresses[index]
            textFieldAddress.text = value
            updateAddressState()
        }
    }
    
    override func keyboardWillHide() {
        super.keyboardWillHide()
        scrollView.setContentOffset(CGPoint(x: 0, y: -0.5), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    //MARK: - UITextFieldDelegate
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupScrollAddress() {
        
        let offset : CGFloat = 8
        
        var scrollWidth : CGFloat = 0
        for (index, value) in addresses.enumerated() {
            let button = ScrollButton(title: value)
            button.addTarget(self, action: #selector(addresesTapped(_:)), for: .touchUpInside)
            button.tag = index
            button.frame.origin.x = scrollWidth
            scrollViewGenerator.addSubview(button)
            scrollWidth += button.frame.size.width + offset
        }
        scrollViewGenerator.contentSize.width = scrollWidth + offset
    }
}
