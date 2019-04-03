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
    @IBOutlet private weak var coinomatErrorView: CoinomatServiceErrorView!
    
    private var selectedAsset: DomainLayer.DTO.SmartAssetBalance?
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
            assetView.isSelectedAssetMode = false
            setupAssetInfo(asset)
        }
    }

    @IBAction private func continueTapped(_ sender: Any) {
        
        guard let info = displayInfo else { return }
        let vc = ReceiveGenerateAddressModuleBuilder().build(input: .cryptoCurrency(info))
        navigationController?.pushViewController(vc, animated: true)
        
        AnalyticManager.trackEvent(.walletAsset(.receiveTap(assetName: info.assetName)))

    }
    
    private func setupAssetInfo(_ asset: DomainLayer.DTO.SmartAssetBalance) {
        selectedAsset = asset
        assetView.update(with: .init(assetBalance: asset, isOnlyBlockMode: input.selectedAsset != nil))
        setupLoadingState()
        setupButtonState()
        
        let asset = asset.asset
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.sendEvent.accept(.generateAddress(asset: asset))
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
                
                guard let self = self else { return }
                switch state.action {
                case .none:
                    return
                default:
                    break
                }
                
                self.displayInfo = state.displayInfo

                switch state.action {
                case .addressDidGenerate:
                    self.setupWarning()
                    self.setupButtonState()

                case .addressDidFailGenerate(let error):
                    
                    switch error {
                    case .internetNotWorking:
                        self.coinomatErrorView.isHidden = true
                        self.showNetworkErrorSnack(error: error,
                                                         customTitle: Localizable.Waves.Receive.Error.serviceUnavailable)
                        
                    default:
                        self.coinomatErrorView.isHidden = false
                    }
                    
                    self.activityIndicatorView.stopAnimating()
                    
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
        coinomatErrorView.isHidden = true
    }
    
    func setupWarning() {
        
        guard let info = displayInfo else { return }
        
        activityIndicatorView.stopAnimating()
        viewWarning.isHidden = false
        coinomatErrorView.isHidden = true

        let displayMin = info.minAmount.displayText + " " + info.assetShort
        labelTitleMinimumAmount.text = Localizable.Waves.Receivecryptocurrency.Label.minumumAmountOfDeposit(displayMin)
        labelWarningMinimumAmount.text = Localizable.Waves.Receivecryptocurrency.Label.warningMinimumAmountOfDeposit(displayMin)
        
        if selectedAsset?.asset.isEthereum == true {
            labelTitleSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label.Warningsmartcontracts.title(info.assetShort, info.assetName)
            labelWarningSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label.Warningsmartcontracts.subtitle(info.assetShort)
        }
        else {
            labelTitleSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label.sendOnlyOnThisDeposit(info.assetShort)
            labelWarningSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label.warningSendOnlyOnThisDeposit
        }
    }
    
    func setupLocalization() {
        buttonCotinue.setTitle(Localizable.Waves.Receive.Button.continue, for: .normal)
    }
}

//MARK: - ReceiveAssetViewDelegate
extension ReceiveCryptocurrencyViewController: AssetSelectViewDelegate {
    
    func assetViewDidTapChangeAsset() {
        
        let assetInput = AssetList.DTO.Input(filters: input.filters,
                                             selectedAsset: selectedAsset,
                                             showAllList: input.showAllList)
        let vc = AssetListModuleBuilder(output: self).build(input: assetInput)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ReceiveCryptocurrencyViewController: AssetListModuleOutput {
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.SmartAssetBalance) {
        displayInfo = nil
        setupAssetInfo(asset)
    }
}
