//
//  AddAddressBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum Constants {
    static let buttonSaveBottomEditModeOffset: CGFloat = 95
}

final class AddAddressBookViewController: UIViewController {

    @IBOutlet private weak var textFieldAddress: AddAddressTextField!
    @IBOutlet private weak var textFieldName: BaseInputTextField!
    @IBOutlet private weak var buttonSave: HighlightedButton!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonSaveBottomOffset: NSLayoutConstraint!
    
    private let repository = FactoryRepositories.instance.addressBookRepository
    private let authorizationInteractor = FactoryInteractors.instance.authorization
    private let disposeBag: DisposeBag = DisposeBag()

    var contact: DomainLayer.DTO.Contact?
    weak var delegate: AddAddressBookModuleOutput?

    private var isValidInput: Bool {
        return textFieldAddress.trimmingText.count > 0 &&
        textFieldName.trimmingText.count > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = contact != nil ? Localizable.AddAddressBook.Label.edit : Localizable.AddAddressBook.Label.add
        createBackButton()
        setupNavBarUI()
        setupTextFields()
        setupEditUserMode()
        setupButtonSaveState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if textFieldAddress.text.count == 0 {
            textFieldAddress.becomeFirstResponder()
        } else if textFieldName.text.count == 0 {
            textFieldName.becomeFirstResponder()
        }
    }
}

//MARK: - Actions

private extension AddAddressBookViewController {
    
    @IBAction func saveTapped(_ sender: Any) {
    
        let newContact = DomainLayer.DTO.Contact(name: textFieldName.trimmingText, address: textFieldAddress.trimmingText)

        if let contact = self.contact {
            authorizationInteractor
                .authorizedWallet()
                .flatMap { [weak self] wallet -> Observable<Bool> in

                    guard let owner = self else { return Observable.never() }
                    return owner.repository.save(contact: newContact, accountAddress: wallet.wallet.address)
                }
                .subscribe(onNext: { _ in
                    self.delegate?.addAddressBookDidEdit(contact: contact, newContact: newContact)
                })
                .disposed(by: disposeBag)

        }
        else {
            authorizationInteractor
                .authorizedWallet()
                .flatMap { [weak self] wallet -> Observable<Bool> in
                    guard let owner = self else { return Observable.never() }
                    return owner.repository.save(contact: newContact, accountAddress: wallet.wallet.address)
                }
                .subscribe(onNext: { _ in
                    self.delegate?.addAddressBookDidCreate(contact: newContact)
                })
                .disposed(by: disposeBag)
        }

        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
    
        let controller = UIAlertController(title: Localizable.AddAddressBook.Button.deleteAddress, message: Localizable.AddAddressBook.Label.deleteAlertMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: Localizable.AddAddressBook.Button.cancel, style: .cancel, handler: nil)
        let delete = UIAlertAction(title: Localizable.AddAddressBook.Button.delete, style: .destructive) { (action) in
            if let contact = self.contact {
                self.authorizationInteractor
                    .authorizedWallet()
                    .flatMap { [weak self] wallet -> Observable<Bool> in
                        guard let owner = self else { return Observable.never() }
                        return owner.repository.delete(contact: contact, accountAddress: wallet.wallet.address)
                    }
                    .subscribe()
                    .disposed(by: self.disposeBag)
                self.delegate?.addAddressBookDidDelete(contact: contact)
                self.navigationController?.popViewController(animated: true)
            }
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
        if textFieldAddress.text.count == 0 {
            textFieldAddress.becomeFirstResponder()
        } else if textFieldName.text.count == 0 {
            textFieldName.becomeFirstResponder()
        }
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
        
        buttonDelete.isHidden = contact == nil
        
        if let contact = self.contact {
            textFieldName.setupText(contact.name)
            textFieldAddress.text = contact.address
            buttonSaveBottomOffset.constant = Constants.buttonSaveBottomEditModeOffset
        }
    }
}
