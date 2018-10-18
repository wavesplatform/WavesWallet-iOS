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
    private var gatewayInfo: Send.DTO.GatewayInfo?
    private var isLoadingAssetGateWayInfo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Send.Label.send
        createBackButton()
        setupRecipientAddress()
        setupLocalization()
        setupButtonState()
        setupFeedBack()
        hideGatewayInfo()
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
        if asset.isWaves || asset.isWavesToken || asset.isFiat {
            return Address.isValidAddress(address: address)
        }
        else {
            let isValidLocalAddress = Address.isValidAddress(address: address)
            return isValidLocalAddress
        }
    }
    
    private func calculateAmount() {
        
        //TODO: need update calculation
        amountView.setupRightLabelText("≈ " + "0" + " " + Localizable.Send.Label.dollar)
    }
    
    private func setupAssetInfo(_ assetBalance: DomainLayer.DTO.AssetBalance) {
        selectedAsset = assetBalance
        assetView.update(with: assetBalance)
        amountView.setDecimals(assetBalance.asset?.precision ?? 0, forceUpdateMoney: false)
        
        guard let asset = assetBalance.asset else { return }
        let isCryptocurrency = asset.isGateway && !asset.isFiat
        
        if isCryptocurrency {
            showLoadingGatewayInfo()
        }
        else {
            hideGatewayInfo()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.sendEvent.accept(.didChangeAsset(assetBalance, isLoadInfo: isCryptocurrency))
        }
    }

    @IBAction private func continueTapped(_ sender: Any) {
    
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
                    strongSelf.hideGatewayInfo()
            
                case .didGetInfo(let info):
                    strongSelf.showGatewayInfo(info: info)
                    
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
    
    func showLoadingGatewayInfo() {
        viewWarning.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideGatewayInfo() {
        viewWarning.isHidden = true
        activityIndicatorView.stopAnimating()
    }
    
    func showGatewayInfo(info: Send.DTO.GatewayInfo) {
        
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
