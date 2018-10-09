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
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
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
    private var hasLoadInfo = false

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
    }

    @IBAction private func continueTapped(_ sender: Any) {
    
    }
    
    @IBAction private func changeCurrency(_ sender: Any) {
    
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(.init(title: Localizable.ReceiveCard.Button.cancel, style: .cancel, handler: nil))
        
        let actionUSD = UIAlertAction(title: ReceiveCard.DTO.FiatType.usd.text, style: .default) { (action) in
            self.selectedFiat = ReceiveCard.DTO.FiatType.usd
            self.setupFiatText()
        }
        controller.addAction(actionUSD)
        
        let actionEUR = UIAlertAction(title: ReceiveCard.DTO.FiatType.eur.text, style: .default) { (action) in
            self.selectedFiat = ReceiveCard.DTO.FiatType.eur
            self.setupFiatText()
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
                
                switch state.action {
                case .didGetInfo(let info):
                    strongSelf.setupInfo(info)
                    
                case .didFailGetInfo(let error):
                    strongSelf.showError(error)
                    
                default:
                    break
                }
            })
        
        return [subscriptionSections]
    }
}


//MARK: - UI
private extension ReceiveCardViewController {
    
    func setupFiatText() {
        labelAmountIn.text = Localizable.Receive.Label.amountIn + " " + selectedFiat.text
    }
    
    func setupInfo(_ info: ReceiveCard.DTO.Info) {
        
        hasLoadInfo = true
        
        acitivityIndicatorAmount.stopAnimating()
        acitivityIndicatorWarning.stopAnimating()
        
        let minimum = info.minimumAmount.displayText + " " + selectedFiat.text
        let maximum = info.maximumAmount.displayText + " " + selectedFiat.text
        
        labelWarningMinimumAmount.text = Localizable.ReceiveCard.Label.minimunAmountInfo(minimum, maximum)
        viewWarning.isHidden = false
        setupButtonState()
        assetView.update(with: info.asset)
    
    }
    
    func showError(_ error: Error) {
        activityIndicatorView.stopAnimating()
    }
    
    func setupButtonState() {
        let canContinueAction = hasLoadInfo
        buttonContinue.isUserInteractionEnabled = canContinueAction
        buttonContinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    func setupLocalization() {
        labelChangeCurrency.text = Localizable.ReceiveCard.Label.changeCurrency
        labelWarningInfo.text = Localizable.ReceiveCard.Label.warningInfo
    }
}
