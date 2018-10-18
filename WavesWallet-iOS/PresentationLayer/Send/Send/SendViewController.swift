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

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
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
    
    private var selectedAsset: DomainLayer.DTO.AssetBalance?
    private var amount: Money?
    
    private let sendEvent: PublishRelay<Send.Event> = PublishRelay<Send.Event>()
    var presenter: SendPresenterProtocol!

    var input: AssetList.DTO.Input!
    private var isValidAlias: Bool = false
    private var gateWayInfo: Send.DTO.GatewayInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Send.Label.send
        createBackButton()
        setupRecipientAddress()
        setupLocalization()
        setupButtonState()
        setupFeedBack()
        hideGatewayInfo(animation: false)
        assetView.delegate = self
        amountView.delegate = self
        
        if let asset = input.selectedAsset {
            assetView.isSelectedAssetMode = false
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.setupAssetInfo(asset)
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.continueTapped(UIButton())
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
    }
    
    private func calculateAmount() {
        
        //TODO: need update calculation
        amountView.setupRightLabelText("≈ " + "0" + " " + Localizable.Send.Label.dollar)
    }
    
    private func setupAssetInfo(_ assetBalance: DomainLayer.DTO.AssetBalance) {
        gateWayInfo = nil
        
        selectedAsset = assetBalance
        assetView.update(with: assetBalance)
        amountView.setDecimals(assetBalance.asset?.precision ?? 0, forceUpdateMoney: false)
        
        setupButtonState()

        let loadGateway = self.isValidCryptocyrrencyAddress && !self.isValidLocalAddress
        sendEvent.accept(.didSelectAsset(assetBalance, loadGatewayInfo: loadGateway))
        if loadGateway {
            showLoadingGatewayInfo()
        }
        else {
            hideGatewayInfo(animation: false)
        }
    }

    @IBAction private func continueTapped(_ sender: Any) {
    
        let vc = StoryboardScene.Send.sendConfirmationViewController.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - FeedBack
private extension SendViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<Send.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        presenter.system(feedbacks: [feedback])
    }
    
    func events() -> [Signal<Send.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<Send.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let strongSelf = self else { return }
                switch state.action {
                case .none:
                    return
                default:
                    break
                }
                
                switch state.action {
                case .didFailInfo(let error):
                    strongSelf.hideGatewayInfo(animation: true)
            
                case .didGetInfo(let info):
                    strongSelf.showGatewayInfo(info: info)
                    
                case .aliasDidFinishCheckValidation(let isValidAlias):
                    strongSelf.hideCheckingAliasState(isValidAlias: isValidAlias)

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
        calculateAmount()
    }
}

//MARK: - AssetListModuleOutput
extension SendViewController: AssetListModuleOutput {
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.AssetBalance) {
        setupAssetInfo(asset)
        validateAddress()
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
        
        var isValidateGateway = true
        if isValidCryptocyrrencyAddress && gateWayInfo == nil {
            isValidateGateway = false
        }
        let canContinueAction = isValidateGateway && isValidAddress(recipientAddressView.text) && selectedAsset != nil
        buttonContinue.isUserInteractionEnabled = canContinueAction
        buttonContinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    func showLoadingGatewayInfo() {
        viewWarning.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideGatewayInfo(animation: Bool) {
        if viewWarning.isHidden {
            return
        }
        viewWarning.isHidden = true
        activityIndicatorView.stopAnimating()
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
        
        labelWarningTitle.text = Localizable.Send.Label.gatewayFee + " " + info.fee.displayText + " " + info.assetShortName
        
        let min = info.minAmount.displayText + " " + info.assetShortName
        let max = info.maxAmount.displayText + " " + info.assetShortName

        labelWarningSubtitle.text = Localizable.Send.Label.Warning.subtitle(info.assetName, min, max)
        labelWarningDescription.text = Localizable.Send.Label.Warning.description(info.assetName)
        
        viewWarning.isHidden = false
        viewWarning.alpha = 0
        activityIndicatorView.stopAnimating()
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.viewWarning.alpha = 1
            self.view.layoutIfNeeded()
        })
        setupButtonState()
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
        amountView.activateTextField()
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
    
    func addressInputViewDidScanAddress(_ address: String) {
        acceptAddress(address)
        
        if !recipientAddressView.isKeyboardShow {
            validateAddress()
        }
    }
    
    func addressInputViewDidDeleteAddress() {
        acceptAddress("")
        
        if !recipientAddressView.isKeyboardShow {
            hideGatewayInfo(animation: true)
        }
    }
    
    func addressInputViewDidChangeAddress(_ address: String) {
        acceptAddress(address)
    }
    
    func addressInputViewDidSelectContactAtIndex(_ index: Int) {
        
    }
    
    private func acceptAddress(_ address: String) {
        isValidAlias = false
        setupButtonState()
        sendEvent.accept(.didChangeRecipient(address))
    }
}


//MARK: - AddressBookModuleOutput

extension SendViewController: AddressBookModuleOutput {
   
    func addressBookDidSelectContact(_ contact: DomainLayer.DTO.Contact) {
        isValidAlias = false
        recipientAddressView.setupText(contact.address, animation: false)
        setupButtonState()
        sendEvent.accept(.didChangeRecipient(contact.address))
        validateAddress()
    }
}

//MARK: - UIScrollViewDelegate
extension SendViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}

//MARK: - AddressValidation
private extension SendViewController {
    
    var canValidateAlias: Bool {
        let alias = recipientAddressView.text
        return alias.count >= Send.ViewModel.minimumAliasLength &&
        alias.count <= Send.ViewModel.maximumAliasLength
    }
    
    var isValidLocalAddress: Bool {
        return Address.isValidAddress(address: recipientAddressView.text)
    }
    
    var isValidCryptocyrrencyAddress: Bool {
        let address = recipientAddressView.text
        
        if let regExp = selectedAsset?.asset?.regularExpression {
            return NSPredicate(format: "SELF MATCHES %@", regExp).evaluate(with: address)
        }
        return false
    }
    
    func isValidAddress(_ address: String) -> Bool {
        guard let asset = selectedAsset?.asset else { return true }
        
        if asset.isWaves || asset.isWavesToken || asset.isFiat {
            return isValidLocalAddress || isValidAlias
        }
        else {
            return isValidLocalAddress || isValidCryptocyrrencyAddress || isValidAlias
        }
    }
 
    func validateAddress() {
        let address = recipientAddressView.text
        guard let asset = selectedAsset?.asset else { return }
        
        if address.count > 0 && address.count < Send.ViewModel.minimumAliasLength {
            recipientAddressView.checkIfValidAddress()
            return
        }
        
        if asset.isWaves || asset.isWavesToken || asset.isFiat {
            if !isValidLocalAddress && !isValidAlias && canValidateAlias {
                sendEvent.accept(.checkValidationAlias)
                recipientAddressView.showLoadingState()
            }
            else {
                recipientAddressView.checkIfValidAddress()
            }
        }
        else if asset.isGateway && !asset.isFiat {
            if !isValidLocalAddress {
                if isValidCryptocyrrencyAddress {
                    if gateWayInfo == nil {
                        sendEvent.accept(.getGatewayInfo)
                        showLoadingGatewayInfo()
                    }
                    recipientAddressView.checkIfValidAddress()
                }
                else {
                    if !isValidAlias && canValidateAlias {
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
