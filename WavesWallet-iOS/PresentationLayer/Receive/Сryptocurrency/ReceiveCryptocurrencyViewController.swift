//
//  ReceiveСryptocurrencyViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit


final class ReceiveCryptocurrencyViewController: UIViewController {

    @IBOutlet private weak var assetView: ReceiveAssetView!
    
    @IBOutlet private weak var viewWarningMinimumAmount: UIView!
    @IBOutlet private weak var viewWarningSendOnlyDeposit: UIView!
    @IBOutlet private weak var labelTitleMinimumAmount: UILabel!
    @IBOutlet private weak var labelWarningMinimumAmount: UILabel!
    @IBOutlet private weak var labelTitleSendOnlyDeposit: UILabel!
    @IBOutlet private weak var labelWarningSendOnlyDeposit: UILabel!
    @IBOutlet weak var buttonCotinue: HighlightedButton!
    
    
    private var asset: Receive.DTO.Asset?

    private var canContinueAction: Bool {
        return asset != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assetView.delegate = self
        setupLocalization()
        setupButtonState()
    }

    @IBAction private func continueTapped(_ sender: Any) {
    
    }
}

//MARK: - SetupUI
private extension ReceiveCryptocurrencyViewController {
    
    func setupButtonState() {
        buttonCotinue.isUserInteractionEnabled = canContinueAction
        buttonCotinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    
    func setupLocalization() {
        labelTitleMinimumAmount.text = Localizable.ReceiveCryptocurrency.Label.minumumAmountOfDeposit("0.001 BTC")
        labelWarningMinimumAmount.text = Localizable.ReceiveCryptocurrency.Label.warningMinimumAmountOfDeposit("0.001 BTC")
        labelTitleSendOnlyDeposit.text = Localizable.ReceiveCryptocurrency.Label.sendOnlyOnThisDeposit("BTC")
        labelWarningSendOnlyDeposit.text = Localizable.ReceiveCryptocurrency.Label.warningSendOnlyOnThisDeposit
        
        buttonCotinue.setTitle(Localizable.Receive.Button.continue, for: .normal)
    }
}

//MARK: - ReceiveAssetViewDelegate
extension ReceiveCryptocurrencyViewController: ReceiveAssetViewDelegate {
    
    func receiveAssetViewDidTapChangeAsset() {
//        delegate?.receiveCryptocurrencyViewControllerDidChangeAsset(asset)
    }
}
