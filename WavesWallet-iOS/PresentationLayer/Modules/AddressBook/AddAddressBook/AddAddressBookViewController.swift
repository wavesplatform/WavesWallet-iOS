//
//  AddAddressBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum AddAddressError: Error {
    case addressExists
}
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

    weak var delegate: AddAddressBookModuleOutput?
    var input: AddAddressBook.DTO.Input!
    
    private var isValidInput: Bool {
        return textFieldAddress.trimmingText.count > 0 &&
        textFieldName.trimmingText.count > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = input.isAdd == true ? Localizable.Waves.Addaddressbook.Label.add : Localizable.Waves.Addaddressbook.Label.edit

        switch input.kind {
        case .edit(let contact, let isMutable):
            textFieldAddress.text = contact.address
            textFieldAddress.isEnabled = isMutable

        case .add(let address, let isMutable):
            textFieldAddress.text = address ?? ""
            textFieldAddress.isEnabled = isMutable
        }

        createBackButton()
        setupLocalization()
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
        saveAddressBook()
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
    
        let controller = UIAlertController(title: Localizable.Waves.Addaddressbook.Button.deleteAddress, message: Localizable.Waves.Addaddressbook.Label.deleteAlertMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: Localizable.Waves.Addaddressbook.Button.cancel, style: .cancel, handler: nil)
        let delete = UIAlertAction(title: Localizable.Waves.Addaddressbook.Button.delete, style: .destructive) { (action) in
            if let contact = self.input.contact {
                self.authorizationInteractor
                    .authorizedWallet()
                    .flatMap { [weak self] wallet -> Observable<Bool> in
                        guard let owner = self else { return Observable.never() }
                        return owner.repository.delete(contact: contact, accountAddress: wallet.address)
                    }
                    .subscribe()
                    .disposed(by: self.disposeBag)
                self.delegate?.addAddressBookDidDelete(contact: contact)
                //TODO: Move code to coordinator
                self.navigationController?.popViewController(animated: true)
            }
        }
        controller.addAction(cancel)
        controller.addAction(delete)
        present(controller, animated: true, completion: nil)
    }


    private func saveAddressBook() {

        if isValidInput == false {
            return
        }

        
        let newContact = DomainLayer.DTO.Contact(name: textFieldName.trimmingText,
                                                 address: textFieldAddress.trimmingText)

        authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<DomainLayer.DTO.Wallet>  in
                guard let owner = self else { return Observable.never() }

                if self?.input.isAdd == true {
                    return owner
                        .repository
                        .contact(by: newContact.address, accountAddress: wallet.address)
                        .flatMap({ contact -> Observable<DomainLayer.DTO.Wallet> in
                            if contact == nil {
                                return Observable.just(wallet.wallet)
                            } else {
                                return Observable.error(AddAddressError.addressExists)
                            }
                        })
                }

                return Observable.just(wallet.wallet)
            })
            .flatMap { [weak self] wallet -> Observable<DomainLayer.DTO.Wallet> in

                guard let owner = self else { return Observable.never() }
                return owner.repository.save(contact: newContact, accountAddress: wallet.address)
                    .map { _ in wallet }
            }
            .flatMap({ [weak self] wallet  -> Observable<Bool> in
                guard let owner = self else { return Observable.never() }
                if let contact = owner.input.contact,
                    self?.input.isAdd == false && contact.address != newContact.address {
                    return owner.repository.delete(contact: contact, accountAddress: wallet.address)
                }

                return Observable.just(true)
            })
            .subscribe(onNext: { [weak self] _ in

                if let contact = self?.input.contact, self?.input.isAdd == false {
                    self?.delegate?.addAddressBookDidEdit(contact: contact, newContact: newContact)
                } else {
                    self?.delegate?.addAddressBookDidCreate(contact: newContact)
                }
                //TODO: Move code to coordinator
                self?.navigationController?.popViewController(animated: true)
            }, onError: { [weak self] error in
                self?.textFieldAddress.error = Localizable.Waves.Addaddressbook.Textfield.Address.Error.addressexist
            })
            .disposed(by: disposeBag)
    }

}

//MARK: - AddAddressTextFieldDelegate
extension AddAddressBookViewController: AddAddressTextFieldDelegate {
    
    func addAddressTextField(_ textField: AddAddressTextField, didChange text: String) {
        textFieldAddress.error = nil
        setupButtonSaveState()
    }

    func addressTextFieldTappedNext() {
        if textFieldAddress.text.count > 0 {
            textFieldName.becomeFirstResponder()
        }
    }
}

//MARK: - BaseInputTextFieldDelegate
extension AddAddressBookViewController: BaseInputTextFieldDelegate {

    func baseInputTextField(_ textField: BaseInputTextField, didChange text: String) {
        setupButtonSaveState()
    }

    func baseInputTextFieldHandlerTextFieldReturn(_ textField: BaseInputTextField) -> Bool {

        saveAddressBook()
        return true
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
        textFieldName.setupPlaceholder(Localizable.Waves.Addaddressbook.Label.name)
    }
    
    func setupLocalization() {
        buttonDelete.setTitle(Localizable.Waves.Addaddressbook.Button.deleteAddress, for: .normal)
        buttonSave.setTitle(Localizable.Waves.Addaddressbook.Button.save, for: .normal)
    }
    
    func setupNavBarUI() {
        navigationItem.backgroundImage = UIImage()
        setupBigNavigationBar()
        hideTopBarLine()
    }
    
    func setupEditUserMode() {
        
        buttonDelete.isHidden = input.isAdd

        if let contact = input.contact {
            textFieldName.setupText(contact.name)
            textFieldAddress.text = contact.address
            buttonSaveBottomOffset.constant = Constants.buttonSaveBottomEditModeOffset
        }
    }
}
