//
//  ReceiveCardViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ReceiveCardViewController: UIViewController {

    @IBOutlet private weak var assetView: AssetSelectView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var labelAmountIn: UILabel!
    @IBOutlet private weak var labelChangeCurrency: UILabel!
    @IBOutlet private weak var labelTotalAmount: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewWarning: UIView!
    @IBOutlet private weak var acitivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var labelWarningMinimumAmount: UILabel!
    @IBOutlet private weak var labelWarningInfo: UILabel!
    @IBOutlet private weak var buttonContinue: HighlightedButton!
    
//    private var minimumAmount: Money = 0
//    private var maximumAmount: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewContainer.addTableCellShadowStyle()
        setupLocalization()
    
        assetView.isSelectedAssetMode = false
        assetView.setupAssetWavesMode()
        setupButtonState()
        viewWarning.isHidden = true
    }

    @IBAction private func continueTapped(_ sender: Any) {
    
    }
    
    @IBAction private func changeCurrency(_ sender: Any) {
    
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(.init(title: Localizable.ReceiveCard.Button.cancel, style: .cancel, handler: nil))
        
        let actionUSD = UIAlertAction(title: ReceiveCard.DTO.FiatType.usd.text, style: .default) { (action) in
            
        }
        controller.addAction(actionUSD)
        
        let actionEUR = UIAlertAction(title: ReceiveCard.DTO.FiatType.eur.text, style: .default) { (action) in
            
        }
        controller.addAction(actionEUR)
        present(controller, animated: true, completion: nil)
    }
}

//MARK: - UI
private extension ReceiveCardViewController {
    
    func setupWarningInfo() {
        activityIndicatorView.stopAnimating()
        labelWarningMinimumAmount.text = Localizable.ReceiveCard.Label.minimunAmountInfo("30 USD", "200 USD")
    }
    
    func setupButtonState() {
        let canContinueAction = false
        buttonContinue.isUserInteractionEnabled = canContinueAction
        buttonContinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    func setupLocalization() {
        labelChangeCurrency.text = Localizable.ReceiveCard.Label.changeCurrency
        labelWarningInfo.text = Localizable.ReceiveCard.Label.warningInfo
    }
}
