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

protocol SendResultDelegate: AnyObject {
    func sendResultDidFail(_ error: NetworkError)
}

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    
    static let percent50 = 50
    static let percent10 = 10
    static let percent5 = 5
}

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
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var activityIndicatorButton: UIActivityIndicatorView!
    @IBOutlet private weak var viewAmountError: UIView!
    @IBOutlet private weak var labelAmountError: UILabel!
    @IBOutlet private weak var moneroPaymentIdView: SendMoneroPaymentIdView!
    
    private var selectedAsset: DomainLayer.DTO.SmartAssetBalance?
    private var amount: Money?
    private let wavesFee = GlobalConstants.WavesTransactionFee
    
    private let sendEvent: PublishRelay<Send.Event> = PublishRelay<Send.Event>()
    var presenter: SendPresenterProtocol!
    
    var inputModel: Send.DTO.InputModel!
    
    private var isValidAlias: Bool = false
    private var gateWayInfo: Send.DTO.GatewayInfo?
    private var wavesAsset: DomainLayer.DTO.SmartAssetBalance?
    private var moneroAddress: String = ""
    private var isLoadingAssetBalanceAfterScan = false
    
    var availableBalance: Money {
        
        guard let asset = selectedAsset else { return Money(0, 0)}
        
        var balance: Int64 = 0
        if asset.asset.isWaves == true {
            balance = asset.avaliableBalance - wavesFee.amount
        }
        else if isValidCryptocyrrencyAddress {
            balance = asset.avaliableBalance - (gateWayInfo?.fee.amount ?? 0)
        }
        else {
            balance = asset.avaliableBalance
        }
        return Money(balance, asset.asset.precision)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Waves.Send.Label.send
        createBackButton()
        setupRecipientAddress()
        setupLocalization()
        setupFeedBack()
        hideGatewayInfo(animation: false)
        updateAmountError(animation: false)
        amountView.input = { [weak self] in
            return self?.inputAmountValues ?? []
        }
        assetView.delegate = self
        amountView.delegate = self
        amountView.setupRightLabelText("")
        moneroPaymentIdView.setupZeroHeight(animation: false)
        moneroPaymentIdView.didTapNext = { [weak self] in
            self?.amountView.activateTextField()
        }
        moneroPaymentIdView.paymentIdDidChange = { [weak self] paymentID in
            self?.setupButtonState()
            self?.moneroAddress = ""
        }
        
        switch inputModel! {
        case .selectedAsset(let asset):
            assetView.isSelectedAssetMode = false
            
            //TODO: need refactor code to correct initial state
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.setupAssetInfo(asset)
                self.amountView.setDecimals(asset.asset.precision, forceUpdateMoney: false)
            }
            
        case .resendTransaction(let tx):
            updateAmountData()
            recipientAddressView.setupText(tx.address, animation: false)
            amount = tx.amount
            amountView.setAmount(tx.amount)
            assetView.showLoadingState()
            
            //TODO: need refactor code to correct initial state
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.sendEvent.accept(.getAssetById(tx.asset.id))
                self.acceptAddress(tx.address)
                if !self.isValidAddress(self.recipientAddressView.text) {
                    self.validateAddress()
                }
            }

        case .empty:
            updateAmountData()
        }
        
        setupButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
    }
    
    private func setupAssetInfo(_ assetBalance: DomainLayer.DTO.SmartAssetBalance) {
        gateWayInfo = nil
        
        selectedAsset = assetBalance
        assetView.update(with: .init(assetBalance: assetBalance, isOnlyBlockMode: inputModel.selectedAsset != nil))
        setupButtonState()

        let loadGateway = self.isValidCryptocyrrencyAddress && !self.isValidLocalAddress
        sendEvent.accept(.didSelectAsset(assetBalance, loadGatewayInfo: loadGateway))
        if loadGateway {
            showLoadingGatewayInfo()
        }
        else {
            hideGatewayInfo(animation: false)
        }
        
        updateAmountData()
        updateMoneraPaymentView(animation: false)
        recipientAddressView.decimals = selectedAsset?.asset.precision ?? 0
    }
    
    private func showConfirmScreen() {
        guard let amountWithoutFee = self.amount else { return }
        guard let asset = selectedAsset?.asset else { return }
        
        var address = recipientAddressView.text
        var amount = amountWithoutFee
        var isGateway = false
        var attachment = ""
        
        if let gateWay = gateWayInfo, isValidCryptocyrrencyAddress {
            address = gateWay.address
            isGateway = true
            attachment = gateWay.attachment
            
            //Coinomate take fee from transaction
            //in 'availableBalance' I substract fee from coinomate that user can input valid amount with fee.
            amount = Money(amount.amount + gateWay.fee.amount, amount.decimals)
        }
        
        
        let vc = StoryboardScene.Send.sendConfirmationViewController.instantiate()
        vc.resultDelegate = self
        vc.input = .init(asset: asset,
                         address: address,
                         displayAddress: recipientAddressView.text,
                         fee: wavesFee,
                         amount: amount,
                         amountWithoutFee: amountWithoutFee,
                         isAlias: isValidAlias,
                         attachment: attachment,
                         isGateway: isGateway)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
    
        if isNeedGenerateMoneroAddress {
            showLoadingButtonState()
            sendEvent.accept(.didChangeMoneroPaymentID(moneroPaymentIdView.paymentID))
        }
        else {
            showConfirmScreen()
        }
    }
}


//MARK: - SendResultDelegate
extension SendViewController: SendResultDelegate {
    func sendResultDidFail(_ error: NetworkError) {
        
        navigationController?.popToViewController(self, animated: true)
        showNetworkErrorSnack(error: error)
    }
}

//MARK: - FeedBack
private extension SendViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<Send.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), mutations: owner.events())
        }
        
        presenter.system(feedbacks: [feedback])
    }
    
    func events() -> [Signal<Send.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<Send.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let owner = self else { return }
                switch state.action {
                case .none:
                    return
                default:
                    break
                }
                
                switch state.action {
                
                case .didGetAssetBalance(let assetBalance):
                    
                    owner.hideLoadingAssetState(isLoadAsset: assetBalance != nil)
                    
                    if let asset = assetBalance {
                        owner.setupAssetInfo(asset)
                        owner.amountView.setDecimals(asset.asset.precision, forceUpdateMoney: true)
                    }
                    
                    
                case .didFailInfo(let error):
                    
                    owner.showNetworkErrorSnack(error: error)
                    owner.hideGatewayInfo(animation: true)

                case .didGetInfo(let info):
                    owner.showGatewayInfo(info: info)
                    owner.updateAmountData()
                    
                case .aliasDidFinishCheckValidation(let isValidAlias):
                    owner.hideCheckingAliasState(isValidAlias: isValidAlias)
                    owner.setupButtonState()

                case .didGetWavesAsset(let asset):
                    owner.wavesAsset = asset
                    owner.updateAmountError(animation: true)
                    
                case .didFailGenerateMoneroAddress(let error):
                    
                    owner.showNetworkErrorSnack(error: error)
                    owner.hideButtonLoadingButtonsState()
                    owner.moneroPaymentIdView.showErrorFromServer()
                    owner.setupButtonState()

                case .didGenerateMoneroAddress(let info):
                    owner.moneroAddress = info.address
                    owner.gateWayInfo = info
                    owner.hideButtonLoadingButtonsState()
                    owner.setupButtonState()
                    owner.showConfirmScreen()

                default:
                    break
                }
                
                
            })
        
        return [subscriptionSections]
    }
}

//MARK: - MoneyTextFieldDelegate
extension SendViewController: AmountInputViewDelegate {
    
    func amountInputView(didChangeValue value: Money) {
        amount = value
        updateAmountError(animation: true)
        setupButtonState()
    }
}

//MARK: - AssetListModuleOutput
extension SendViewController: AssetListModuleOutput {
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.SmartAssetBalance) {
        setupAssetInfo(asset)
        amountView.setDecimals(asset.asset.precision, forceUpdateMoney: true)
        validateAddress()
    }
}

//MARK: - AssetSelectViewDelegate
extension SendViewController: AssetSelectViewDelegate {
   
    func assetViewDidTapChangeAsset() {
        let assetInput = AssetList.DTO.Input(filters: [.all],
                                             selectedAsset: selectedAsset,
                                             showAllList: false)
        
        let vc = AssetListModuleBuilder(output: self).build(input: assetInput)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Data
private extension SendViewController {
    var inputAmountValues: [Money] {
        
        var values: [Money] = []
        if availableBalance.amount > 0 {
            
            values.append(availableBalance)
            
            let n5 = Decimal(availableBalance.amount) * (Decimal(Constants.percent5) / 100.0)
            let n10 = Decimal(availableBalance.amount) * (Decimal(Constants.percent10) / 100.0)
            let n50 = Decimal(availableBalance.amount) * (Decimal(Constants.percent50) / 100.0)
            
            values.append(Money(n50.int64Value, availableBalance.decimals))
            values.append(Money(n10.int64Value, availableBalance.decimals))
            values.append(Money(n5.int64Value, availableBalance.decimals))
        }
        
        return values
    }
    
    func updateAmountData() {
        
        var fields: [String] = []
        
        if availableBalance.amount > 0 {
            fields.append(contentsOf: [Localizable.Waves.Send.Button.useTotalBalanace,
                                       String(Constants.percent50) + "%",
                                       String(Constants.percent10) + "%",
                                       String(Constants.percent5) + "%"])
        }
        
        amountView.update(with: fields)
    }
}

//MARK: - UI
private extension SendViewController {

    func showLoadingAssetState(isLoadingAmount: Bool) {
        isLoadingAssetBalanceAfterScan = true
        assetView.isSelectedAssetMode = false
        recipientAddressView.isBlockAddressMode = true        
        setupButtonState()
        assetView.showLoadingState()
        amountView.isBlockMode = isLoadingAmount
        if isLoadingAmount {
            amountView.showAnimation()
        }
    }
    
    func hideLoadingAssetState(isLoadAsset: Bool) {
     
        assetView.hideLoadingState(isLoadAsset: isLoadAsset)
        isLoadingAssetBalanceAfterScan = false
        setupButtonState()
    }
    
    func updateAmountError(animation: Bool) {
        
        let isShow = selectedAsset != nil && !isValidAmount && (amount?.amount ?? 0) > 0
        
        if isShow {
            if viewAmountError.isHidden {
                viewAmountError.isHidden = false
                viewAmountError.alpha = animation ? 0 : 1

                if animation {
                    UIView.animate(withDuration: Constants.animationDuration) {
                        self.viewAmountError.alpha = 1
                    }
                }
            }
            
            if let gateWayInfo = gateWayInfo, isValidCryptocyrrencyAddress {
                let wavesFeeText = wavesFee.displayText + " WAVES"
                let gateWayFee = gateWayInfo.fee.displayText + " " + gateWayInfo.assetShortName
                labelAmountError.text = Localizable.Waves.Send.Label.Error.notFundsFeeGateway(wavesFeeText, gateWayFee)
            }
            else {
                labelAmountError.text = Localizable.Waves.Send.Label.Error.notFundsFee
            }
        }
        else {
            //TODO: can be bug. Multiple times call UIView.animationWithDuration...
            
            if !viewAmountError.isHidden {
                if animation {
                    UIView.animate(withDuration: Constants.animationDuration, animations: {
                        self.viewAmountError.alpha = 0
                        
                    }) { (complete) in
                        self.viewAmountError.isHidden = true
                    }
                }
                else {
                    viewAmountError.isHidden = true
                }
               
            }
        }
        amountView.showErrorMessage(message: Localizable.Waves.Send.Label.Error.insufficientFunds, isShow: isShow)
    }
    
    func showLoadingButtonState() {
        view.isUserInteractionEnabled = false
        buttonContinue.backgroundColor = .submit200
        buttonContinue.setTitle("", for: .normal)
        activityIndicatorButton.isHidden = false
        activityIndicatorButton.startAnimating()
    }
    
    func hideButtonLoadingButtonsState() {
        view.isUserInteractionEnabled = true
        setupButtonState()
        setupLocalization()
        activityIndicatorButton.stopAnimating()
    }
    
    func setupButtonState() {
        
        var isValidateGateway = true
        if isValidCryptocyrrencyAddress && gateWayInfo == nil {
            isValidateGateway = false
        }
        let canContinueAction = isValidateGateway &&
            isValidAddress(recipientAddressView.text) &&
            selectedAsset != nil &&
            isValidAmount &&
            (amount?.amount ?? 0) > 0 &&
            isValidMinMaxGatewayAmount &&
            isValidPaymentMoneroID &&
            !isLoadingAssetBalanceAfterScan
        
        buttonContinue.isUserInteractionEnabled = canContinueAction
        buttonContinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    func showLoadingGatewayInfo() {
        viewWarning.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideGatewayInfo(animation: Bool) {
        updateAmountError(animation: animation)
        activityIndicatorView.stopAnimating()

        if viewWarning.isHidden {
            return
        }
        viewWarning.isHidden = true
        if animation {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func hideCheckingAliasState(isValidAlias: Bool) {
        self.isValidAlias = isValidAlias
        recipientAddressView.checkIfValidAddress()
        recipientAddressView.hideLoadingState()
    }
    
    func showGatewayInfo(info: Send.DTO.GatewayInfo) {
        
        gateWayInfo = info
        
        labelWarningTitle.text = Localizable.Waves.Send.Label.gatewayFee + " " + info.fee.displayText + " " + info.assetShortName
        
        let min = info.minAmount.displayText + " " + info.assetShortName
        let max = info.maxAmount.displayText + " " + info.assetShortName

        labelWarningSubtitle.text = Localizable.Waves.Send.Label.Warning.subtitle(info.assetName, min, max)
        labelWarningDescription.text = Localizable.Waves.Send.Label.Warning.description(info.assetName)
        
        viewWarning.isHidden = false
        viewWarning.alpha = 0
        activityIndicatorView.stopAnimating()
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.viewWarning.alpha = 1
            self.view.layoutIfNeeded()
        })
        setupButtonState()
        updateAmountError(animation: true)
        updateMoneraPaymentView(animation: true)
    }
    
    func updateMoneraPaymentView(animation: Bool) {
        if selectedAsset?.asset.isMonero == true && isValidCryptocyrrencyAddress {
            moneroPaymentIdView.setupDefaultHeight(animation: animation)
        }
        else {
            moneroAddress = ""
            moneroPaymentIdView.setupZeroHeight(animation: animation)
        }
    }
    
    func setupLocalization() {
        buttonContinue.setTitle(Localizable.Waves.Send.Button.continue, for: .normal)
        labelTransactionFee.text = Localizable.Waves.Send.Label.transactionFee + " " + wavesFee.displayText + " WAVES"
    }
    
    func setupRecipientAddress() {
        
        let input = AddressInputView.Input(title: Localizable.Waves.Send.Label.recipient,
                                           error: Localizable.Waves.Send.Label.addressNotValid,
                                           placeHolder: Localizable.Waves.Send.Label.recipientAddress,
                                           contacts: [],
                                           canChangeAsset: self.inputModel.selectedAsset == nil)
        recipientAddressView.update(with: input)
        recipientAddressView.delegate = self
        recipientAddressView.errorValidation = { [weak self] text in
            return self?.isValidAddress(text) ?? false
        }
    }
}

//MARK: - AddressInputViewDelegate

extension SendViewController: AddressInputViewDelegate {
  
    func addressInputViewDidRemoveBlockMode() {
        
        if !assetView.isOnlyBlockMode {
            selectedAsset = nil
            assetView.isSelectedAssetMode = true
            assetView.removeSelectedAssetState()
            recipientAddressView.decimals = 0
        }
        
        if amountView.isBlockMode {
            amountView.isBlockMode = false
            amountView.clearMoney()
            updateAmountData()
        }
        
        setupButtonState()
        sendEvent.accept(.cancelGetingAsset)
    }
    
    func addressInputViewDidTapNext() {
        
        if moneroPaymentIdView.isVisible {
            moneroPaymentIdView.activateTextField()
        }
        else {
            amountView.activateTextField()
        }
    }
    
    func addressInputViewDidEndEditing() {
        validateAddress()
        if isValidCryptocyrrencyAddress {
            if let info = gateWayInfo, viewWarning.isHidden {
                showGatewayInfo(info: info)
            }
        }
        else {
            hideGatewayInfo(animation: true)
        }
    }
    
    func addressInputViewDidSelectAddressBook() {
        let controller = AddressBookModuleBuilder(output: self).build(input: .init(isEditMode: false))
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func addressInputViewDidScanAddress(_ address: String, amount: Money?, assetID: String?) {
        
        if assetID != nil {
            recipientAddressView.isBlockAddressMode = true
            assetView.isSelectedAssetMode = false
            amountView.isBlockMode = amount?.isZero == false
        }
        
        if let asset = assetID, selectedAsset?.assetId != asset, inputModel.selectedAsset == nil {
            sendEvent.accept(.getAssetById(asset))
            showLoadingAssetState(isLoadingAmount: amount != nil)
        }
        
        amountView.hideAnimation()
        if let amount = amount {
            if !amount.isZero {
                self.amount = amount
                amountView.setAmount(amount)
            }
            updateAmountData()
            updateAmountError(animation: false)
        }
        
        acceptAddress(address)
        if !recipientAddressView.isKeyboardShow {
            validateAddress()
        }
        clearGatewayAndUpdateInputAmount()
    }
    
    func addressInputViewDidDeleteAddress() {
        acceptAddress("")
        
        if !recipientAddressView.isKeyboardShow {
            hideGatewayInfo(animation: true)
        }
        clearGatewayAndUpdateInputAmount()
    }
    
    func addressInputViewDidChangeAddress(_ address: String) {
        acceptAddress(address)
        clearGatewayAndUpdateInputAmount()
    }
    
    func addressInputViewDidSelectContactAtIndex(_ index: Int) {
        
    }
    
    private func acceptAddress(_ address: String) {
        isValidAlias = false
        setupButtonState()
        sendEvent.accept(.didChangeRecipient(address))
    }
    
    private func clearGatewayAndUpdateInputAmount() {
        if gateWayInfo != nil {
            gateWayInfo = nil
            updateAmountData()
            updateMoneraPaymentView(animation: true)
        }
    }
    
    func addressInputViewDidStartLoadingInfo() {
        showLoadingAssetState(isLoadingAmount: true)
    }
}


//MARK: - AddressBookModuleOutput

extension SendViewController: AddressBookModuleOutput {
   
    func addressBookDidSelectContact(_ contact: DomainLayer.DTO.Contact) {
        recipientAddressView.setupText(contact.address, animation: false)
        acceptAddress(contact.address)
        validateAddress()
        clearGatewayAndUpdateInputAmount()
    }
}

//MARK: - UIScrollViewDelegate
extension SendViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}

//MARK: - Validation
private extension SendViewController {

    var isNeedGenerateMoneroAddress: Bool {
        if selectedAsset?.asset.isMonero == true && isValidCryptocyrrencyAddress && moneroPaymentIdView.isValidPaymentID {
            return moneroAddress.count == 0
        }
        return false
    }
    
    var isValidPaymentMoneroID: Bool {
    
        if selectedAsset?.asset.isMonero == true && isValidCryptocyrrencyAddress {
            return moneroPaymentIdView.isValidPaymentID
        }
        return true
    }
    
    var isValidMinMaxGatewayAmount: Bool {
        guard let amount = amount else { return false }

        if isValidCryptocyrrencyAddress {
            if amount.amount >= (gateWayInfo?.minAmount.amount ?? 0) &&
                amount.amount <= (gateWayInfo?.maxAmount.amount ?? 0) {
                return true
            }
            return false
        }
        return true
    }
    
    var isValidAmount: Bool {
        guard let amount = amount else { return false }
        if selectedAsset?.asset.isWaves == true {
            return availableBalance.amount >= amount.amount
        }
        
        return availableBalance.amount >= amount.amount &&
            (wavesAsset?.avaliableBalance ?? 0) >= wavesFee.amount
    }
    
    var canValidateAliasOnServer: Bool {
        let alias = recipientAddressView.text
        return alias.count >= Send.ViewModel.minimumAliasLength &&
        alias.count <= Send.ViewModel.maximumAliasLength
    }

    var isValidLocalAddress: Bool {
        return Address.isValidAddress(address: recipientAddressView.text)
    }
    
    var isValidCryptocyrrencyAddress: Bool {
        let address = recipientAddressView.text

        if let regExp = selectedAsset?.asset.addressRegEx, regExp.count > 0 {
            return NSPredicate(format: "SELF MATCHES %@", regExp).evaluate(with: address) &&
                selectedAsset?.asset.isGateway == true &&
                selectedAsset?.asset.isFiat == false
        }
        return false
    }

    var validationAddressAsset: DomainLayer.DTO.Asset? {
        if selectedAsset == nil {
            switch inputModel! {
            case .resendTransaction(let tx):
                return tx.asset
            
            default:
                break
            }
        }
        
        return selectedAsset?.asset
    }

    func isValidAddress(_ address: String) -> Bool {
        guard let asset = validationAddressAsset else { return true }

        if asset.isWaves || asset.isWavesToken || asset.isFiat {
            return isValidLocalAddress || isValidAlias
        }
        else {
            return isValidLocalAddress || isValidCryptocyrrencyAddress || isValidAlias
        }
    }

    func canInputOnlyLocalAddressOrAlias(_ asset: DomainLayer.DTO.Asset) -> Bool {
         return asset.isWaves || asset.isWavesToken || asset.isFiat
    }
    
    func isCryptoCurrencyAsset(_ asset: DomainLayer.DTO.Asset) -> Bool {
        return asset.isGateway && !asset.isFiat
    }
    
    func addressNotRequireMinimumLength(_ address: String) -> Bool {
        return address.count > 0 && address.count < Send.ViewModel.minimumAliasLength
    }
    
    func validateAddress() {
        let address = recipientAddressView.text
        guard let asset = validationAddressAsset else { return }

        if addressNotRequireMinimumLength(address) {
            recipientAddressView.checkIfValidAddress()
            return
        }

        if canInputOnlyLocalAddressOrAlias(asset) {
            if !isValidLocalAddress && !isValidAlias && canValidateAliasOnServer {
                sendEvent.accept(.checkValidationAlias)
                recipientAddressView.showLoadingState()
            }
            else {
                recipientAddressView.checkIfValidAddress()
            }
        }
        else if isCryptoCurrencyAsset(asset) {
            if !isValidLocalAddress {
                if isValidCryptocyrrencyAddress {
                    if gateWayInfo == nil {
                        sendEvent.accept(.getGatewayInfo)
                        showLoadingGatewayInfo()
                    }
                    recipientAddressView.checkIfValidAddress()
                }
                else {
                    if !isValidAlias && canValidateAliasOnServer {
                        sendEvent.accept(.checkValidationAlias)
                        recipientAddressView.showLoadingState()
                    }
                    else {
                        recipientAddressView.checkIfValidAddress()
                    }
                }
            }
            else {
                recipientAddressView.checkIfValidAddress()
            }
        }
        else {
            recipientAddressView.checkIfValidAddress()
        }
    }
}

