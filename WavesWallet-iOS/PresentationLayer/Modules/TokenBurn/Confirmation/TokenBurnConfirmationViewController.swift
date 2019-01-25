//
//  TokenBurnConfirmationViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 2
}

final class TokenBurnConfirmationViewController: UIViewController {

    @IBOutlet private weak var labelFeeLocalization: UILabel!
    @IBOutlet private weak var labelFeeAmount: UILabel!
    @IBOutlet private weak var buttonBurn: HighlightedButton!
    @IBOutlet private weak var viewId: TokenBurnConfirmationIDView!
    @IBOutlet private weak var labelTypeLocalization: UILabel!
    @IBOutlet private weak var labelType: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var tickerView: TickerView!
    @IBOutlet private weak var viewContainer: UIView!
    
    struct Input {
        let asset: DomainLayer.DTO.SmartAssetBalance
        let amount: Money
        let fee: Money
        let delegate: TokenBurnTransactionDelegate?
        let errorDelegate: TokenBurnLoadingViewControllerDelegate?
    }
    
    var input: Input!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createBackWhiteButton()
        setupLocalization()
        setupData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewContainer.createTopCorners(radius: Constants.cornerRadius)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationItem.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction private func burnTapped(_ sender: Any) {
    
        let vc = StoryboardScene.Asset.tokenBurnLoadingViewController.instantiate()
        vc.input = input
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UI
private extension TokenBurnConfirmationViewController {
 
    func setupData() {
        labelFeeAmount.text = input.fee.displayText + " WAVES"
        
        if input.asset.asset.isReusable == true {
            labelType.text = Localizable.Waves.Tokenburn.Label.reissuable
        } else {
            labelType.text = Localizable.Waves.Tokenburn.Label.notReissuable
        }
        
        if let ticker = input.asset.asset.ticker {
            labelAssetName.isHidden = true
            tickerView.update(with: .init(text: ticker, style: .soft))
        }
        else {
            tickerView.isHidden = true
            labelAssetName.text = input.asset.asset.displayName
        }
        
        labelAmount.attributedText = NSAttributedString.styleForBalance(text: input.amount.displayText, font: labelAmount.font)

        viewId.update(with: .init(id: input.asset.assetId, description: input.asset.asset.description))
    }
    
    func setupLocalization() {
        title = Localizable.Waves.Tokenburn.Label.confirmation
        buttonBurn.setTitle(Localizable.Waves.Tokenburn.Button.burn, for: .normal)
        labelFeeLocalization.text = Localizable.Waves.Tokenburn.Label.fee
        labelTypeLocalization.text = Localizable.Waves.Tokenburn.Label.type
   }
}
