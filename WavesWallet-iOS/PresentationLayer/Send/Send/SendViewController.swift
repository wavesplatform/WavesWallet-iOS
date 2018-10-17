//
//  SendViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxFeedback
import RxCocoa


final class SendViewController: UIViewController {

    @IBOutlet private weak var assetView: AssetSelectView!
    @IBOutlet private weak var viewWarning: UIView!
    @IBOutlet private weak var labelWarningTitle: UILabel!
    @IBOutlet private weak var labelWarningSubtitle: UILabel!
    @IBOutlet private weak var labelWarningDescription: UILabel!
    @IBOutlet private weak var amountView: AmountInputView!
    @IBOutlet private weak var recipientAddressView: AddressInputView!
    @IBOutlet private weak var buttonContinue: HighlightedButton!
    @IBOutlet private weak var labelTransactionFee: UILabel!
    
    private var selectedAsset: DomainLayer.DTO.AssetBalance?
    private var amount: Money?
    
    private let sendEvent: PublishRelay<Send.Event> = PublishRelay<Send.Event>()
    var presenter: SendPresenterProtocol!

    var input: AssetList.DTO.Input!
    private var gatewayInfo: Send.DTO.GatewayInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Send.Label.send
        createBackButton()
        setupRecipientAddress()
        setupLocalization()
        setupButtonState()
        assetView.delegate = self
        amountView.delegate = self
        
        if let asset = input.selectedAsset {
            assetView.isSelectedAssetMode = false
            setupAssetInfo(asset)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
    }
    
    private func isValidAddress(_ address: String) -> Bool {
        guard let asset = selectedAsset?.asset else { return true }
        return Address.isValidAddress(address: address)
    }
    
    private func calculateAmount() {
        
        //TODO: need update calculation
        amountView.setupRightLabelText("≈" + "0" + Localizable.Send.Label.dollar)
    }
    
    private func setupAssetInfo(_ asset: DomainLayer.DTO.AssetBalance) {
        selectedAsset = asset
        assetView.update(with: asset)
        amountView.setDecimals(asset.asset?.precision ?? 0, forceUpdateMoney: false)
    }

    @IBAction private func continueTapped(_ sender: Any) {
    
    }
}

//MARK: - MoneyTextFieldDelegate
extension SendViewController: AmountInputViewDelegate {
    
    func amountInputView(didChangeValue value: Money) {
        amount = value
        calculateAmount()
    }
}

//MARK: - AssetListModuleOutput
extension SendViewController: AssetListModuleOutput {
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.AssetBalance) {
        setupAssetInfo(asset)
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
    
    func setupButtonState() {
        let canContinueAction = gatewayInfo != nil
        buttonContinue.isUserInteractionEnabled = canContinueAction
        buttonContinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    func setupLocalization() {
        buttonContinue.setTitle(Localizable.Send.Button.continue, for: .normal)
        labelTransactionFee.text = Localizable.Send.Label.transactionFee
    }
    
    func setupRecipientAddress() {
        
        let input = AddressInputView.Input(title: Localizable.Send.Label.recipient,
                                           error: Localizable.Send.Label.addressNotValid,
                                           placeHolder: Localizable.Send.Label.recipientAddress,
                                           contacts: [])
        recipientAddressView.update(with: input)
        recipientAddressView.delegate = self
        recipientAddressView.errorValidation = { [weak self] text in
            return self?.isValidAddress(text) ?? false
        }
    }
}

//MARK: - AddressInputViewDelegate

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


//MARK: - AddressBookModuleOutput

extension SendViewController: AddressBookModuleOutput {
    func addressBookDidSelectContact(_ contact: DomainLayer.DTO.Contact) {
        
        let recipient = contact.address
//        order.recipient = recipient
        recipientAddressView.setupText(recipient, animation: false)
//        setupButtonState()
//        sendEvent.accept(.updateInputOrder(order))
        recipientAddressView.checkIfValidAddress()
    }
}

//MARK: - UIScrollViewDelegate
extension SendViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
