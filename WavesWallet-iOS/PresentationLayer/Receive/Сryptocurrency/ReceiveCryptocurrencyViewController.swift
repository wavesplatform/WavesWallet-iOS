//
//  ReceiveСryptocurrencyViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ReceiveCryptocurrencyViewController: UIViewController {

    @IBOutlet private weak var assetView: AssetSelectView!
    
    @IBOutlet private weak var viewWarning: UIView!
    
    @IBOutlet private weak var labelTitleMinimumAmount: UILabel!
    @IBOutlet private weak var labelWarningMinimumAmount: UILabel!
    @IBOutlet private weak var labelTitleSendOnlyDeposit: UILabel!
    @IBOutlet private weak var labelWarningSendOnlyDeposit: UILabel!
    @IBOutlet private weak var buttonCotinue: HighlightedButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var selectedAsset: DomainLayer.DTO.AssetBalance?

    private var canContinueAction: Bool {
        return selectedAsset != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assetView.delegate = self
        setupLocalization()
        setupButtonState()
        setupViewState()
    }

    @IBAction private func continueTapped(_ sender: Any) {
        
    }
}

//MARK: - SetupUI
private extension ReceiveCryptocurrencyViewController {
    
    func setupViewState() {
        viewWarning.isHidden = !canContinueAction
    }
    
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
extension ReceiveCryptocurrencyViewController: AssetSelectViewDelegate {
    
    func assetViewDidTapChangeAsset() {
        
        let vc = AssetListModuleBuilder(output: self).build(input: .init(filters: [.all], selectedAsset: selectedAsset))
        navigationController?.pushViewController(vc, animated: true)
//        delegate?.receiveCryptocurrencyViewControllerDidChangeAsset(asset)
    }
}

extension ReceiveCryptocurrencyViewController: AssetListModuleOutput {
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.AssetBalance) {
        selectedAsset = asset
        assetView.update(with: asset)
        setupButtonState()
        setupViewState()
    }
}
