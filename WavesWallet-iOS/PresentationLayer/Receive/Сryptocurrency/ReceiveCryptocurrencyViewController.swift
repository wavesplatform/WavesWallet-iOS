//
//  ReceiveСryptocurrencyViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxFeedback
import RxSwift


final class ReceiveCryptocurrencyViewController: UIViewController {

    @IBOutlet private weak var assetView: AssetSelectView!
    
    @IBOutlet private weak var viewWarning: UIView!
    
    @IBOutlet private weak var labelTitleMinimumAmount: UILabel!
    @IBOutlet private weak var labelWarningMinimumAmount: UILabel!
    @IBOutlet private weak var labelTitleSendOnlyDeposit: UILabel!
    @IBOutlet private weak var labelWarningSendOnlyDeposit: UILabel!
    @IBOutlet private weak var buttonCotinue: HighlightedButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
  
//    private var selectedAsset: Receive.DTO.Asset?

    private var selectedAsset: DomainLayer.DTO.AssetBalance?
    private var displayInfo: ReceiveCryptocurrency.DTO.DisplayInfo?
    
    private let sendEvent: PublishRelay<ReceiveCryptocurrency.Event> = PublishRelay<ReceiveCryptocurrency.Event>()
    var presenter: ReceiveCryptocurrencyPresenterProtocol!
    
    var input: AssetList.DTO.Input!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assetView.delegate = self
        setupLocalization()
        setupButtonState()
        setupFeedBack()
        viewWarning.isHidden = true
        
        if let asset = input.selectedAsset {
            setupAssetInfo(asset)
        }
    }

    @IBAction private func continueTapped(_ sender: Any) {
        
        guard let info = displayInfo else { return }
        let vc = ReceiveGenerateAddressModuleBuilder().build(input: .cryptoCurrency(info))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupAssetInfo(_ asset: DomainLayer.DTO.AssetBalance) {
        selectedAsset = asset
        assetView.update(with: asset)
        setupLoadingState()
        setupButtonState()
        
        if let asset = asset.asset {
            sendEvent.accept(.generateAddress(asset: asset))
        }
    }
}


//MARK: - FeedBack
private extension ReceiveCryptocurrencyViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<ReceiveCryptocurrency.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        presenter.system(feedbacks: [feedback])
    }
    
    func events() -> [Signal<ReceiveCryptocurrency.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<ReceiveCryptocurrency.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let strongSelf = self else { return }
                switch state.action {
                case .none:
                    return
                default:
                    break
                }
                
                strongSelf.displayInfo = state.displayInfo

                switch state.action {
                case .addressDidGenerate(let info):
                    strongSelf.setupWarning()
                    strongSelf.setupButtonState()

                case .addressDidFailGenerate(let error):
                    strongSelf.activityIndicatorView.stopAnimating()
                    
                default:
                    break
                }
            })
        
        return [subscriptionSections]
    }
}



//MARK: - SetupUI
private extension ReceiveCryptocurrencyViewController {
    
   
    func setupButtonState() {
        
        let canContinueAction = selectedAsset != nil && displayInfo != nil
        
        buttonCotinue.isUserInteractionEnabled = canContinueAction
        buttonCotinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    func setupLoadingState() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        viewWarning.isHidden = true
    }
    
    func setupWarning() {
        
        guard let info = displayInfo else { return }
        
        activityIndicatorView.stopAnimating()
        viewWarning.isHidden = false
        
        let displayFee = String(info.fee) + " " + info.assetShort
        labelTitleMinimumAmount.text = Localizable.ReceiveCryptocurrency.Label.minumumAmountOfDeposit(displayFee)
        labelWarningMinimumAmount.text = Localizable.ReceiveCryptocurrency.Label.warningMinimumAmountOfDeposit(displayFee)
        labelTitleSendOnlyDeposit.text = Localizable.ReceiveCryptocurrency.Label.sendOnlyOnThisDeposit(info.assetShort)
        labelWarningSendOnlyDeposit.text = Localizable.ReceiveCryptocurrency.Label.warningSendOnlyOnThisDeposit
    }
    
    func setupLocalization() {
        buttonCotinue.setTitle(Localizable.Receive.Button.continue, for: .normal)
    }
}

//MARK: - ReceiveAssetViewDelegate
extension ReceiveCryptocurrencyViewController: AssetSelectViewDelegate {
    
    func assetViewDidTapChangeAsset() {
        
        let assetInput = AssetList.DTO.Input(filters: input.filters, selectedAsset: selectedAsset)
        let vc = AssetListModuleBuilder(output: self).build(input: assetInput)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ReceiveCryptocurrencyViewController: AssetListModuleOutput {
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.AssetBalance) {
        displayInfo = nil
        setupAssetInfo(asset)
    }
}
