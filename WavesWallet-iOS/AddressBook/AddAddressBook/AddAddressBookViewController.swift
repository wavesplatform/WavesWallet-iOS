//
//  AddAddressBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AddAddressBookViewController: UIViewController {

    @IBOutlet private weak var textFieldAddress: AddAddressTextField!
    @IBOutlet private weak var textFieldName: BaseInputTextField!
    @IBOutlet private weak var buttonSave: HighlightedButton!
    @IBOutlet private weak var buttonDelete: UIButton!
   
    
    var user: AddressBook.DTO.User?
    
    private var isValidInput: Bool {
        return textFieldAddress.trimmingText.count > 0 &&
        textFieldName.trimmingText.count > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBackButton()
        title = Localizable.AddAddressBook.Label.add
        setupNavBarUI()
        setupTextFields()
        
        textFieldAddress.text = "dasd"
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
    
    }
}

//MARK: - AddAddressTextFieldDelegate
extension AddAddressBookViewController: AddAddressTextFieldDelegate {
    
    func addAddressTextField(_ textField: AddAddressTextField, didChange text: String) {
        print(text)
        setupButtonSaveState()
    }
}

//MARK: - BaseInputTextFieldDelegate
extension AddAddressBookViewController: BaseInputTextFieldDelegate {

    func baseInputTextField(_ textField: BaseInputTextField, didChange text: String) {
        print(text)
        setupButtonSaveState()
    }
}

private extension AddAddressBookViewController {
    
    func setupButtonSaveState() {
        buttonSave.backgroundColor = isValidInput ? .submit400 : .submit200
    }
    
    func setupTextFields() {
        textFieldName.delegate = self
        textFieldAddress.delegate = self
        textFieldName.setupPlaceholder(Localizable.AddAddressBook.Label.name)
    }
    
    func setupLocalization() {
        buttonSave.setTitle(Localizable.AddAddressBook.Button.save, for: .normal)
        
    }
    func setupNavBarUI() {
        navigationItem.backgroundImage = UIImage()
        setupBigNavigationBar()
        hideTopBarLine()
    }
}
