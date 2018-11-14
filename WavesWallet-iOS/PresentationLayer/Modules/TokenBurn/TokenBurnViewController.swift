//
//  TokenBurnViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TokenBurnViewController: UIViewController {

    @IBOutlet private weak var assetView: AssetSelectView!
    @IBOutlet private weak var amountView: AmountInputView!
    @IBOutlet private weak var buttonContinue: HighlightedButton!
    @IBOutlet private weak var labelTransactionFee: UILabel!
    
    var asset: DomainLayer.DTO.AssetBalance!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        title = Localizable.Waves.Tokenburn.Label.tokenBurn
        createBackButton()
        setupLocalization()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        hideTopBarLine()
    }
   
}


//MARK: - DATA
private extension TokenBurnViewController {
    
    var input: [Money] {
        return [availableBalance]
    }
    
    var availableBalance: Money {
        return Money(asset.avaliableBalance, asset.asset?.precision ?? 0)
    }
}

//MARK: - AmountInputViewDelegate
extension TokenBurnViewController: AmountInputViewDelegate {
    
    func amountInputView(didChangeValue value: Money) {
        
    }
}

//MARK: - UI
private extension TokenBurnViewController {
    
    func setupData() {
        assetView.isSelectedAssetMode = false
        assetView.update(with: asset)
        
        amountView.delegate = self
        amountView.setDecimals(asset.asset?.precision ?? 0, forceUpdateMoney: false)
        
        if !availableBalance.isZero {
            amountView.input = { [weak self] in
                return self?.input ?? []
            }
            amountView.update(with: [Localizable.Waves.Tokenburn.Button.useTotalBalance])
        }
    }
    
    func setupLocalization() {
        amountView.setupRightLabelText(asset.asset?.displayName ?? "")
        amountView.setupTitle(Localizable.Waves.Tokenburn.Label.quantityTokensBurned)
        buttonContinue.setTitle(Localizable.Waves.Tokenburn.Button.continue, for: .normal)
        labelTransactionFee.text = Localizable.Waves.Tokenburn.Label.transactionFee + "0.001 WAVES"
    }
}
