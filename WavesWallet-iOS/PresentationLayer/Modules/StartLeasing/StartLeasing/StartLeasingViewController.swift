//
//  StartLeasingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/27/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

private enum Constants {
    static let borderWidth: CGFloat = 0.5
    static let assetBgViewCorner: CGFloat = 2

    static let percent50 = 50
    static let percent10 = 10
    static let percent5 = 5
}


final class StartLeasingViewController: UIViewController {
    
    @IBOutlet private weak var labelBalanceTitle: UILabel!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var iconAssetBalance: UIImageView!
    @IBOutlet private weak var labelAssetAmount: UILabel!
    @IBOutlet private weak var iconFavourite: UIImageView!
    @IBOutlet private weak var addressGeneratorView: AddressInputView!
    @IBOutlet private weak var assetBgView: UIView!
    @IBOutlet private weak var amountView: AmountInputView!
    @IBOutlet private weak var buttonStartLease: HighlightedButton!
    @IBOutlet private weak var labelTransactionFee: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private var order: StartLeasingTypes.DTO.Order!
    weak var output: StartLeasingModuleOutput?
    
    var totalBalance: Money! {
        didSet {
            order = StartLeasingTypes.DTO.Order(recipient: "",
                                           amount: Money(0, totalBalance.decimals))
        }
    }
    
    private var availableBalance: Money {
        if !totalBalance.isZero {
            return Money(totalBalance.amount - order.fee.amount, totalBalance.decimals)
        }
        return totalBalance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        createBackButton()
        setupUI()
        setupData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        hideTopBarLine()
    }
 
    @IBAction private func startLeaseTapped(_ sender: Any) {
        let vc = StartLeasingConfirmModuleBuilder(output: output).build(input: .send(order))
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Setup
private extension StartLeasingViewController {
    
    var isValidOrder: Bool {
        return order.recipient.count > 0
            && !isNotEnoughAmount
            && order.amount.amount > 0
            && (Address.isValidAddress(address: order.recipient) || Address.isValidAlias(alias: order.recipient))
    }
    
    var isNotEnoughAmount: Bool {
        return order.amount.decimalValue > availableBalance.decimalValue
    }
    
    func setupLocalization() {
        title = Localizable.Waves.Startleasing.Label.startLeasing
        labelBalanceTitle.text = Localizable.Waves.Startleasing.Label.balance
        
        labelTransactionFee.text = Localizable.Waves.Startleasing.Label.transactionFee + " " + order.fee.displayText + " WAVES"
        amountView.setupRightLabelText("WAVES")
    }
    
    var inputAmountValues: [Money] {
        var values: [Money] = []
        if !availableBalance.isZero {
        
            values.append(availableBalance)
            values.append(Money(value: availableBalance.decimalValue * Decimal(Constants.percent50) / 100,
                                availableBalance.decimals))
            values.append(Money(value: availableBalance.decimalValue * Decimal(Constants.percent10) / 100,
                                availableBalance.decimals))
            values.append(Money(value: availableBalance.decimalValue * Decimal(Constants.percent5) / 100,
                                availableBalance.decimals))
        }
        return values
    }
    
    func setupData() {
        
        labelAssetAmount.text = totalBalance.displayText
        
        var fields: [String] = []
        
        if !availableBalance.isZero {
            
            fields.append(contentsOf: [Localizable.Waves.Dexcreateorder.Button.useTotalBalanace,
                                      String(Constants.percent50) + "%",
                                      String(Constants.percent10) + "%",
                                      String(Constants.percent5) + "%"])
        }
     
        amountView.update(with: fields)
        amountView.input = { [weak self] in
            return self?.inputAmountValues ?? []
        }
        addressGeneratorView.decimals = totalBalance.decimals
    }
    
    func setupUI() {
        scrollView.keyboardDismissMode = .onDrag
        addressGeneratorView.delegate = self
        amountView.delegate = self
        amountView.setDecimals(availableBalance.decimals, forceUpdateMoney: false)
        iconAssetBalance.layer.cornerRadius = iconAssetBalance.frame.size.width / 2
        iconAssetBalance.layer.borderWidth = Constants.borderWidth
        iconAssetBalance.layer.borderColor = UIColor.overlayDark.cgColor
        
        assetBgView.layer.cornerRadius = Constants.assetBgViewCorner
        assetBgView.layer.borderWidth = Constants.borderWidth
        assetBgView.layer.borderColor = UIColor.overlayDark.cgColor
        
        let addressInput = AddressInputView.Input.init(title: Localizable.Waves.Startleasing.Label.generator,
                                                       error: Localizable.Waves.Startleasing.Label.addressIsNotValid,
                                                       placeHolder: Localizable.Waves.Startleasing.Label.nodeAddress,
                                                       contacts: [])
        addressGeneratorView.update(with: addressInput)
        addressGeneratorView.errorValidation = { text in
            return Address.isValidAddress(address: text) || Address.isValidAlias(alias: text)
        }
        setupButtonState()
    }
    
    func setupButtonState() {

        buttonStartLease.isUserInteractionEnabled = isValidOrder
        buttonStartLease.backgroundColor = isValidOrder ? .submit400 : .submit200
        
        let buttonTitle = Localizable.Waves.Startleasing.Button.startLease
        buttonStartLease.setTitle(buttonTitle, for: .normal)
    }
}

//MARK: - StartLeasingAmountViewDelegate
extension StartLeasingViewController: AmountInputViewDelegate {
    
    func amountInputView(didChangeValue value: Money) {
        order.amount = value
        setupButtonState()
        amountView.showErrorMessage(message: Localizable.Waves.Startleasing.Label.insufficientFunds, isShow: isNotEnoughAmount)
    }
}

//MARK: - StartLeasingGeneratorViewDelegate
extension StartLeasingViewController: AddressInputViewDelegate {

    func addressInputViewDidSelectContactAtIndex(_ index: Int) {
        
    }
    
    func addressInputViewDidEndEditing() {
        addressGeneratorView.checkIfValidAddress()
    }
    
    func addressInputViewDidSelectAddressBook() {
        let controller = AddressBookModuleBuilder(output: self).build(input: .init(isEditMode: false))
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func addressInputViewDidDeleteAddress() {
        acceptAddress("", amount: nil)
    }
    
    func addressInputViewDidScanAddress(_ address: String, amount: Money?, assetID: String?) {
        acceptAddress(address, amount: amount)
    }
    
    func addressInputViewDidChangeAddress(_ address: String) {
        acceptAddress(address, amount: nil)
    }
    
    func addressInputViewDidTapNext() {
        amountView.activateTextField()
    }
    
    private func acceptAddress(_ address: String, amount: Money?) {
        order.recipient = address
        
        if let amount = amount {
            order.amount = amount
            amountView.setAmount(amount)
            amountView.showErrorMessage(message: Localizable.Waves.Startleasing.Label.insufficientFunds, isShow: isNotEnoughAmount)
        }
        
        setupButtonState()
    }
}

//MARK: - AddressBookModuleBuilderOutput
extension StartLeasingViewController: AddressBookModuleOutput {
    func addressBookDidSelectContact(_ contact: DomainLayer.DTO.Contact) {
        order.recipient = contact.address
        addressGeneratorView.setupText(order.recipient, animation: false)
        setupButtonState()
        addressGeneratorView.checkIfValidAddress()
    }
}

//MARK: - UIScrollViewDelegate
extension StartLeasingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
