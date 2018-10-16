//
//  SendViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class SendViewController: UIViewController {

    @IBOutlet private weak var assetView: AssetSelectView!
   
    @IBOutlet private weak var recipientAddressView: AddressInputView!
    private var selectedAsset: DomainLayer.DTO.AssetBalance?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Send.Label.send
        createBackButton()
        setupRecipientAddress()
        assetView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
    }
}

extension SendViewController: AssetListModuleOutput {
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.AssetBalance) {
        selectedAsset = asset
        assetView.update(with: asset)
    }
}

//MARK: - AssetSelectViewDelegate
extension SendViewController: AssetSelectViewDelegate {
   
    func assetViewDidTapChangeAsset() {
        let assetInput = AssetList.DTO.Input(filters: [.all], selectedAsset: selectedAsset)
        
        let vc = AssetListModuleBuilder(output: self).build(input: assetInput)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UI
private extension SendViewController {
    
    func setupRecipientAddress() {
        
        let input = AddressInputView.Input(title: Localizable.Send.Label.recipient,
                                           error: Localizable.Send.Label.addressNotValid,
                                           placeHolder: Localizable.Send.Label.recipientAddress,
                                           contacts: [])
        recipientAddressView.update(with: input)
        recipientAddressView.delegate = self
        recipientAddressView.errorValidation = { text in
            return Address.isValidAddress(address: text)
        }
    }
}

extension SendViewController: AddressInputViewDelegate {
    func addressInputViewDidTapNext() {
        
    }
    
    func addressInputViewDidSelectAddressBook() {
        let controller = AddressBookModuleBuilder(output: self).build(input: .init(isEditMode: false))
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func addressInputViewDidChangeAddress(_ address: String) {
//        order.recipient = address
//        setupButtonState()
//        sendEvent.accept(.updateInputOrder(order))
    }
    
    func addressInputViewDidSelectContactAtIndex(_ index: Int) {
        
    }
}

extension SendViewController: AddressBookModuleOutput {
    func addressBookDidSelectContact(_ contact: DomainLayer.DTO.Contact) {
        
        let recipient = contact.address
//        order.recipient = recipient
        recipientAddressView.setupText(recipient, animation: false)
//        setupButtonState()
//        sendEvent.accept(.updateInputOrder(order))
    }
}

//MARK: - UIScrollViewDelegate
extension SendViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
