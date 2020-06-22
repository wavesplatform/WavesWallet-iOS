//
//  AddAddressBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/23/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import RxSwift
import UIKit

private enum AddAddressError: Error {
    case addressExists
}

private enum Constants {
    static let buttonSaveBottomEditModeOffset: CGFloat = 95
    static let minNameLength = 2
    static let maxNameLength = 24
}

final class AddAddressBookViewController: UIViewController {
    @IBOutlet private weak var textFieldAddress: AddAddressTextField!
    @IBOutlet private weak var textFieldName: InputTextField!
    @IBOutlet private weak var buttonSave: HighlightedButton!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonSaveBottomOffset: NSLayoutConstraint!

    private let repository = UseCasesFactory.instance.repositories.addressBookRepository
    private let authorizationInteractor = UseCasesFactory.instance.authorization
    private let disposeBag = DisposeBag()

    weak var delegate: AddAddressBookModuleOutput?
    var input: AddAddressBook.DTO.Input!

    private var isValidInput: Bool {
        return !textFieldAddress.trimmingText.isEmpty &&
            textFieldName.trimmingText.count >= Constants.minNameLength &&
            textFieldName.trimmingText.count <= Constants.maxNameLength
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = input.isAdd == true ? Localizable.Waves.Addaddressbook.Label.add : Localizable.Waves.Addaddressbook
            .Label.edit

        switch input.kind {
        case let .edit(contact, isMutable):
            textFieldAddress.text = contact.address
            textFieldAddress.isEnabled = isMutable

        case let .add(address, isMutable):
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

        if textFieldAddress.text.isEmpty {
            textFieldAddress.becomeFirstResponder()
        } else if textFieldName.text.isEmpty {
            textFieldName.becomeFirstResponder()
        }
    }
}

// MARK: - Actions

private extension AddAddressBookViewController {
    @IBAction func saveTapped(_: Any) {
        saveAddressBook()
    }

    @IBAction func deleteTapped(_: Any) {
        let controller = UIAlertController(title: Localizable.Waves.Addaddressbook.Button.deleteAddress,
                                           message: Localizable.Waves.Addaddressbook.Label.deleteAlertMessage,
                                           preferredStyle: .alert)
        let cancel = UIAlertAction(title: Localizable.Waves.Addaddressbook.Button.cancel, style: .cancel, handler: nil)
        let delete = UIAlertAction(title: Localizable.Waves.Addaddressbook.Button.delete, style: .destructive) { _ in
            if let contact = self.input.contact {
                self.authorizationInteractor
                    .authorizedWallet()
                    .flatMap { [weak self] wallet -> Observable<Bool> in
                        guard let self = self else { return Observable.never() }
                        return self.repository.delete(contact: contact, accountAddress: wallet.address)
                    }
                    .subscribe()
                    .disposed(by: self.disposeBag)

                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.addressBook(.profileAddressBookDelete))

                self.delegate?.addAddressBookDidDelete(contact: contact)
                // TODO: Move code to coordinator
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
            .flatMap { [weak self] (wallet) -> Observable<Wallet> in
                guard let self = self else { return Observable.never() }

                if self.input.isAdd == true {
                    return self
                        .repository
                        .contact(by: newContact.address, accountAddress: wallet.address)
                        .flatMap { contact -> Observable<Wallet> in
                            if contact == nil {
                                return Observable.just(wallet.wallet)
                            } else {
                                return Observable.error(AddAddressError.addressExists)
                            }
                        }
                }

                return Observable.just(wallet.wallet)
            }
            .flatMap { [weak self] wallet -> Observable<Wallet> in

                guard let self = self else { return Observable.never() }
                return self.repository.save(contact: newContact, accountAddress: wallet.address)
                    .map { _ in wallet }
            }
            .flatMap { [weak self] wallet -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                if let contact = self.input.contact,
                    self.input.isAdd == false, contact.address != newContact.address {
                    return self.repository.delete(contact: contact, accountAddress: wallet.address)
                }

                return Observable.just(true)
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let contact = self.input.contact, self.input.isAdd == false {
                    self.delegate?.addAddressBookDidEdit(contact: contact, newContact: newContact)
                } else {
                    self.delegate?.addAddressBookDidCreate(contact: newContact)
                }
                // TODO: Move code to coordinator
                self.navigationController?.popViewController(animated: true)
            }, onError: { [weak self] _ in
                guard let self = self else { return }
                self.textFieldAddress.error = Localizable.Waves.Addaddressbook.Textfield.Address.Error.addressexist
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AddAddressTextFieldDelegate

extension AddAddressBookViewController: AddAddressTextFieldDelegate {
    func addAddressTextField(_: AddAddressTextField, didChange _: String) {
        textFieldAddress.error = nil
        setupButtonSaveState()
    }

    func addressTextFieldTappedNext() {
        if !textFieldAddress.text.isEmpty {
            textFieldName.becomeFirstResponder()
        }
    }
}

private extension AddAddressBookViewController {
    func setupButtonSaveState() {
        buttonSave.backgroundColor = isValidInput ? .submit400 : .submit200
        buttonSave.isUserInteractionEnabled = isValidInput ? true : false
    }

    func setupTextFields() {
        textFieldAddress.delegate = self

        textFieldName.update(with: .init(title: Localizable.Waves.Addaddressbook.Label.name,
                                         kind: .text,
                                         placeholder: Localizable.Waves.Addaddressbook.Label.name))

        textFieldName.textFieldShouldReturn = { [weak self] _ in
            guard let self = self else { return }
            self.saveAddressBook()
        }

        textFieldName.changedValue = { [weak self] _, _ in
            guard let self = self else { return }
            self.setupButtonSaveState()
        }

        textFieldName.valueValidator = { [weak self] _ in
            guard let self = self else { return nil }

            let text = self.textFieldName.trimmingText

            if text.count > Constants.maxNameLength {
                return Localizable.Waves.Addaddressbook.Error.charactersMaximum(Constants.maxNameLength)
            } else if text.count < Constants.minNameLength {
                return Localizable.Waves.Addaddressbook.Error.charactersMinimum(Constants.minNameLength)
            }
            return nil
        }
    }

    func setupLocalization() {
        buttonDelete.setTitle(Localizable.Waves.Addaddressbook.Button.deleteAddress, for: .normal)
        buttonSave.setTitle(Localizable.Waves.Addaddressbook.Button.save, for: .normal)
    }

    func setupNavBarUI() {
        navigationItem.backgroundImage = UIImage()
        setupBigNavigationBar()
        removeTopBarLine()
    }

    func setupEditUserMode() {
        buttonDelete.isHidden = input.isAdd

        if let contact = input.contact {
            textFieldName.value = contact.name
            textFieldAddress.text = contact.address
            buttonSaveBottomOffset.constant = Constants.buttonSaveBottomEditModeOffset
        }
    }
}
