//
//  AddAddressBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let buttonSaveBottomEditModeOffset: CGFloat = 95
}

final class AddAddressBookViewController: UIViewController {

    @IBOutlet private weak var textFieldAddress: AddAddressTextField!
    @IBOutlet private weak var textFieldName: BaseInputTextField!
    @IBOutlet private weak var buttonSave: HighlightedButton!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonSaveBottomOffset: NSLayoutConstraint!
    
    var user: DomainLayer.DTO.User?
    
    private var isValidInput: Bool {
        return textFieldAddress.trimmingText.count > 0 &&
        textFieldName.trimmingText.count > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = user != nil ? Localizable.AddAddressBook.Label.edit : Localizable.AddAddressBook.Label.add
        createBackButton()
        setupNavBarUI()
        setupTextFields()
        setupEditUserMode()
        setupButtonSaveState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backgroundImage = nil
    }
}

//MARK: - Actions

private extension AddAddressBookViewController {
    
    @IBAction func saveTapped(_ sender: Any) {
    
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
    
        let controller = UIAlertController(title: Localizable.AddAddressBook.Button.deleteAddress, message: Localizable.AddAddressBook.Label.deleteAlertMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: Localizable.AddAddressBook.Button.cancel, style: .cancel, handler: nil)
        let delete = UIAlertAction(title: Localizable.AddAddressBook.Button.delete, style: .destructive) { (action) in
            
        }
        controller.addAction(cancel)
        controller.addAction(delete)
        present(controller, animated: true, completion: nil)
    }
}

//MARK: - AddAddressTextFieldDelegate
extension AddAddressBookViewController: AddAddressTextFieldDelegate {
    
    func addAddressTextField(_ textField: AddAddressTextField, didChange text: String) {
        setupButtonSaveState()
    }
}

//MARK: - BaseInputTextFieldDelegate
extension AddAddressBookViewController: BaseInputTextFieldDelegate {

    func baseInputTextField(_ textField: BaseInputTextField, didChange text: String) {
        setupButtonSaveState()
    }
}

private extension AddAddressBookViewController {
    
    func setupButtonSaveState() {
        buttonSave.backgroundColor = isValidInput ? .submit400 : .submit200
        buttonSave.isUserInteractionEnabled = isValidInput ? true : false
    }
    
    func setupTextFields() {
        textFieldName.delegate = self
        textFieldAddress.delegate = self
        textFieldName.setupPlaceholder(Localizable.AddAddressBook.Label.name)
    }
    
    func setupLocalization() {
        buttonDelete.setTitle(Localizable.AddAddressBook.Button.deleteAddress, for: .normal)
        buttonSave.setTitle(Localizable.AddAddressBook.Button.save, for: .normal)
    }
    
    func setupNavBarUI() {
        navigationItem.backgroundImage = UIImage()
        setupBigNavigationBar()
        hideTopBarLine()
    }
    
    func setupEditUserMode() {
        
        buttonDelete.isHidden = user == nil
        
        if let user = self.user {
            textFieldName.setupText(user.name)
            textFieldAddress.text = user.address
            buttonSaveBottomOffset.constant = Constants.buttonSaveBottomEditModeOffset
        }
    }
}
