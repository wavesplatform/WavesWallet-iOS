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
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var viewFee: TransactionFeeView!
    
    private var order: StartLeasingTypes.DTO.Order!
    weak var output: StartLeasingModuleOutput?
    
    private let disposeBag = DisposeBag()
    private let interactor: StartLeasingInteractorProtocol = StartLeasingInteractor()
    private var errorSnackKey: String?
    
    var totalBalance: Money! {
        didSet {
            order = StartLeasingTypes.DTO.Order(recipient: "",
                                                amount: Money(0, totalBalance.decimals),
                                                fee: Money(0, 0))
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
        loadFee()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        hideTopBarLine()
    }
 
    @IBAction private func startLeaseTapped(_ sender: Any) {
        if order.fee.isZero {
            return
        }
        
        let vc = StartLeasingConfirmModuleBuilder(output: output, errorDelegate: self).build(input: .send(order))
        navigationController?.pushViewController(vc, animated: true)
        
        AnalyticManager.trackEvent(.leasing(.leasingSendTap))
    }
}


//MARK: - StartLeasingErrorDelegate
extension StartLeasingViewController: StartLeasingErrorDelegate {
    func startLeasingDidFail(error: NetworkError) {
        
        switch error {
        case .scriptError:
            TransactionScriptErrorView.show()
        default:
            showNetworkErrorSnack(error: error)
        }
    }
}

//MARK: - Setup
private extension StartLeasingViewController {
    
    func loadFee() {
        viewFee.showLoadingState()

        interactor
            .getFee()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (fee) in
                guard let self = self else { return }
                self.updateFee(fee)
                self.setupData()
            }, onError: { [weak self] (error) in
                guard let self = self else { return }
                if let error = error as? TransactionsInteractorError, error == .commissionReceiving {
                    self.showFeeError(DisplayError.message(Localizable.Waves.Transaction.Error.Commission.receiving))
                } else {
                    self.showFeeError(DisplayError(error: error))
                }

            })
            .disposed(by: disposeBag)
    }
    
    func showFeeError(_ error: DisplayError) {
        
        switch error {
        case .globalError(let isInternetNotWorking):
            
            if isInternetNotWorking {
                errorSnackKey = showWithoutInternetSnack { [weak self] in
                    self?.loadFee()
                }
            } else {
                errorSnackKey = showErrorNotFoundSnack(didTap: { [weak self] in
                    self?.loadFee()
                })
            }
        case .internetNotWorking:
            errorSnackKey = showWithoutInternetSnack { [weak self] in
                self?.loadFee()
            }
            
        case .message(let text):
            errorSnackKey = showErrorSnack(title: text, didTap: { [weak self] in
                self?.loadFee()
            })
            
        case .notFound, .scriptError:
            errorSnackKey = showErrorNotFoundSnack(didTap: { [weak self] in
                self?.loadFee()
            })
        }
    }
    
    func updateFee(_ fee: Money) {
        
        if let errorSnackKey = errorSnackKey {
            hideSnack(key: errorSnackKey)
        }
        
        viewFee.update(with: .init(fee: fee, assetName: nil))
        viewFee.hideLoadingState()
        order.fee = fee
        setupData()
        setupButtonState()
    }
    
    var isValidOrder: Bool {
        return order.recipient.count > 0
            && !isNotEnoughAmount
            && order.amount.amount > 0
            && order.fee.amount > 0
            && (Address.isValidAddress(address: order.recipient) || Address.isValidAlias(alias: order.recipient))
    }
    
    var isNotEnoughAmount: Bool {
        return order.amount.decimalValue > availableBalance.decimalValue && order.amount.amount > 0
    }
    
    func setupLocalization() {
        title = Localizable.Waves.Startleasing.Label.startLeasing
        labelBalanceTitle.text = Localizable.Waves.Startleasing.Label.balance
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
        
        if availableBalance.amount > 0 {
            
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
                                                       contacts: [],
                                                       canChangeAsset: false)
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
