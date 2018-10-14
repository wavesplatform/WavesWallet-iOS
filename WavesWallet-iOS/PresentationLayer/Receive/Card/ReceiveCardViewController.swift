//
//  ReceiveCardViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

final class ReceiveCardViewController: UIViewController {

    @IBOutlet private weak var assetView: AssetSelectView!
    @IBOutlet private weak var textFieldMoney: MoneyTextField!
    @IBOutlet private weak var labelAmountIn: UILabel!
    @IBOutlet private weak var labelChangeCurrency: UILabel!
    @IBOutlet private weak var labelTotalAmount: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewWarning: UIView!
    @IBOutlet private weak var acitivityIndicatorAmount: UIActivityIndicatorView!
    @IBOutlet private weak var acitivityIndicatorWarning: UIActivityIndicatorView!
    @IBOutlet private weak var labelWarningMinimumAmount: UILabel!
    @IBOutlet private weak var labelWarningInfo: UILabel!
    @IBOutlet private weak var buttonContinue: HighlightedButton!
    
    private let sendEvent: PublishRelay<ReceiveCard.Event> = PublishRelay<ReceiveCard.Event>()
    var presenter: ReceiveCardPresenterProtocol!
    
    private var selectedFiat = ReceiveCard.DTO.FiatType.usd
    private var amountUSDInfo: ReceiveCard.DTO.AmountInfo?
    private var amountEURInfo: ReceiveCard.DTO.AmountInfo?
    private var asset: DomainLayer.DTO.AssetBalance?
    private var amount: Money = Money(0, ReceiveCard.DTO.fiatDecimals)
    private var urlLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewContainer.addTableCellShadowStyle()
        setupLocalization()
        setupFeedBack()
        setupButtonState()
        setupFiatText()
        assetView.isSelectedAssetMode = false
        assetView.setupAssetWavesMode()
        viewWarning.isHidden = true
        textFieldMoney.moneyDelegate = self
        textFieldMoney.decimals = amount.decimals
    }

    @IBAction private func continueTapped(_ sender: Any) {
    
        //TODO: - Need to show webView screen
        let vc = StoryboardScene.Receive.receiveCardCompleteViewController.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func changeCurrency(_ sender: Any) {
    
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(.init(title: Localizable.ReceiveCard.Button.cancel, style: .cancel, handler: nil))
        
        let actionUSD = UIAlertAction(title: ReceiveCard.DTO.FiatType.usd.text, style: .default) { (action) in
            
            self.selectedFiat = ReceiveCard.DTO.FiatType.usd
            self.setupFiatText()
            self.setupButtonState()
            if let amountInfo = self.amountUSDInfo {
                self.setupAmountInfo(amountInfo)
            }
            else {
                self.sendEvent.accept(.getUSDAmountInfo)
                self.setupLoadingAmountInfo()
            }
        }
        controller.addAction(actionUSD)
        
        let actionEUR = UIAlertAction(title: ReceiveCard.DTO.FiatType.eur.text, style: .default) { (action) in
            self.selectedFiat = ReceiveCard.DTO.FiatType.eur
            self.setupFiatText()
            self.setupButtonState()
            if let amountInfo = self.amountEURInfo {
                self.setupAmountInfo(amountInfo)
            }
            else {
                self.sendEvent.accept(.getEURAmountInfo)
                self.setupLoadingAmountInfo()
            }
        }
        controller.addAction(actionEUR)
        present(controller, animated: true, completion: nil)
    }
}


//MARK: - FeedBack
private extension ReceiveCardViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<ReceiveCard.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        presenter.system(feedbacks: [feedback])
    }
    
    func events() -> [Signal<ReceiveCard.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<ReceiveCard.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let strongSelf = self else { return }
                switch state.action {
                case .none:
                    return
                default:
                    break
                }
                
                strongSelf.amountUSDInfo = state.amountUSDInfo
                strongSelf.amountEURInfo = state.amountEURInfo
                strongSelf.asset = state.assetBalance
                strongSelf.urlLink = state.link
                
                switch state.action {
                    
                case .didGetInfo:
                    strongSelf.setupInfo()

                case .didFailGetInfo(let error):
                    strongSelf.showError(error)

                default:
                    break
                }
            })
        
        return [subscriptionSections]
    }
}

//MARK: - MoneyTextFieldDelegate
extension ReceiveCardViewController: MoneyTextFieldDelegate {
    func moneyTextField(_ textField: MoneyTextField, didChangeValue value: Money) {
        amount = value
        setupButtonState()
        sendEvent.accept(.updateAmount(value))
    }
}

//MARK: - UI
private extension ReceiveCardViewController {
    
    func setupLoadingAmountInfo() {
        acitivityIndicatorWarning.isHidden = false
        acitivityIndicatorWarning.startAnimating()
        viewWarning.isHidden = true
    }
    
    func setupFiatText() {
        labelAmountIn.text = Localizable.Receive.Label.amountIn + " " + selectedFiat.text
    }
    
    func setupAmountInfo(_ amountInfo: ReceiveCard.DTO.AmountInfo) {
        
        let minimum = amountInfo.minAmountString + " " + selectedFiat.text
        let maximum = amountInfo.maxAmountString + " " + selectedFiat.text
        
        labelWarningMinimumAmount.text = Localizable.ReceiveCard.Label.minimunAmountInfo(minimum, maximum)
        viewWarning.isHidden = false
    }
    
    
    func setupInfo() {
        
        guard let asset = asset else { return }

        acitivityIndicatorAmount.stopAnimating()
        acitivityIndicatorWarning.stopAnimating()
        assetView.update(with: asset)
        setupButtonState()
        
        if selectedFiat == .usd {
            guard let amountInfo = amountUSDInfo else { return }
            setupAmountInfo(amountInfo)
        }
        else if selectedFiat == .eur {
            guard let amountInfo = amountEURInfo else { return }
            setupAmountInfo(amountInfo)
        }
    }
    
    func showError(_ error: Error) {
        acitivityIndicatorAmount.stopAnimating()
        acitivityIndicatorWarning.stopAnimating()
    }
    
    func setupButtonState() {
        
        var canContinueAction = false
        if selectedFiat == .usd {
            if let info = amountUSDInfo {
                if amount.decimalValue >= info.minAmount.decimalValue &&
                    amount.decimalValue <= info.maxAmount.decimalValue {
                    canContinueAction = true
                }
            }
        }
        else if selectedFiat == .eur {
            if let info = amountEURInfo {
                if amount.decimalValue >= info.minAmount.decimalValue &&
                    amount.decimalValue <= info.maxAmount.decimalValue {
                    canContinueAction = true
                }
            }
        }
        buttonContinue.isUserInteractionEnabled = canContinueAction
        buttonContinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    func setupLocalization() {
        labelChangeCurrency.text = Localizable.ReceiveCard.Label.changeCurrency
        labelWarningInfo.text = Localizable.ReceiveCard.Label.warningInfo
    }
}
