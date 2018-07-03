//
//  HistoryEditAddressViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/31/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader


protocol AddAddressViewControllerDelegate: class {
    
    func addAddressViewControllerDidBack()
}

class AddAddressViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    var delegate: AddAddressViewControllerDelegate?
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelTextFieldName: UILabel!
    @IBOutlet weak var textFieldAddress: UITextField!
    
    @IBOutlet weak var buttonSaveBottomOffset: NSLayoutConstraint!
    
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    
    var isAddMode = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addressRightOffset: NSLayoutConstraint!
    @IBOutlet weak var buttonDeleteAddress: UIButton!
    @IBOutlet weak var buttonScan: UIButton!
    
    // UI cases
    var showTabBarOnBack = false

    var isTransactionHistory = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        setupBigNavigationBar()
        navigationController?.navigationBar.barTintColor = .white
        createBackButton()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if isTransactionHistory {
            textFieldAddress.isUserInteractionEnabled = false
            buttonScan.isHidden = true
            buttonDeleteAddress.isHidden = true
        }
        else {
            addressRightOffset.constant = 30
        }
        
        title = isAddMode ? "Add" : "Edit"
        
        textFieldName.addTarget(self, action: #selector(textFieldNameDidChange), for: .editingChanged)
        textFieldAddress.addTarget(self, action: #selector(textFieldAddressDidChange), for: .editingChanged)

        if isAddMode {
            buttonDelete.isHidden = true
            labelTextFieldName.alpha = 0
            labelAddress.alpha = 0
            buttonDeleteAddress.alpha = 0
        }
        else {
            buttonSaveBottomOffset.constant = 96
            textFieldName.text = "Mr. Big Mike"
            textFieldAddress.text = "3PCjZftzzhtY4ZLLBfsyvNxw8RwAgXZ"
            buttonScan.alpha = 0
        }
        setupButtonSave()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillHide() {
        scrollView.setContentOffset(CGPoint(x: 0, y: -0.5), animated: true)
    }
    
    @IBAction func deleteAddressTapped(_ sender: Any) {
        textFieldAddress.text = nil
        textFieldAddressDidChange()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
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
                self.buttonDeleteAddress.alpha = 1
                self.buttonScan.alpha = 0
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true) {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
    }
    
    
    @IBAction func saveTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
    
        let controller = UIAlertController(title: "Do you really want to delete the address?", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
        }
        controller.addAction(cancel)
        controller.addAction(delete)
        present(controller, animated: true, completion: nil)
    }
    
    func setupButtonSave () {
        if textFieldName.text!.count > 0 && textFieldAddress.text!.count > 0{
            buttonSave.setupButtonActiveState()
        }
        else {
            buttonSave.setupButtonDeactivateState()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldAddressDidChange() {
        
        if textFieldAddress.text!.count > 0 {
            if buttonDeleteAddress.alpha == 0 {
                UIView.animate(withDuration: 0.3) {
                    self.buttonDeleteAddress.alpha = 1
                    self.buttonScan.alpha = 0
                }
            }
        }
        else {
            if buttonDeleteAddress.alpha == 1 {
                UIView.animate(withDuration: 0.3) {
                    self.buttonDeleteAddress.alpha = 0
                    self.buttonScan.alpha = 1
                }
            }
        }
        
        DataManager.setupTextFieldLabel(textField: textFieldAddress, placeHolderLabel: labelAddress)
        setupButtonSave()
    }
    
    func textFieldNameDidChange() {
        
        DataManager.setupTextFieldLabel(textField: textFieldName, placeHolderLabel: labelTextFieldName)
        setupButtonSave()
    }
    
    override func backTapped() {
        delegate?.addAddressViewControllerDidBack()
        
        if showTabBarOnBack {
            rdv_tabBarController.setTabBarHidden(false, animated: true)
        }
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
