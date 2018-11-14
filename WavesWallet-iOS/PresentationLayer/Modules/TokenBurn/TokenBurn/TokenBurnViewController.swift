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
    
    private var amount: Money?
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        createBackButton()
        setupLocalization()
        setupData()
        setupButtonContinue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        hideTopBarLine()
    }
   
    @IBAction private func continueTapped(_ sender: Any) {
        guard let amount = self.amount else { return }
        let vc = StoryboardScene.Asset.tokenBurnConfirmationViewController.instantiate()
        vc.input = .init(asset: asset, amount: amount)
        navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - Data
private extension TokenBurnViewController {
    
    var input: [Money] {
        return [availableBalance]
    }
    
    var availableBalance: Money {
        return Money(asset.avaliableBalance, asset.asset?.precision ?? 0)
    }
    
    var isValidInputAmount: Bool {
        guard let amount = self.amount else { return false }
        return amount.amount <= availableBalance.amount && amount.amount > 0
    }
}

//MARK: - AmountInputViewDelegate
extension TokenBurnViewController: AmountInputViewDelegate {
    
    func amountInputView(didChangeValue value: Money) {
        
        amount = value
        setupButtonContinue()
    }
}

//MARK: - UIScrollViewDelegate
extension TokenBurnViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}

//MARK: - UI
private extension TokenBurnViewController {
    
    func setupButtonContinue() {
        
        buttonContinue.isUserInteractionEnabled = isValidInputAmount
        buttonContinue.backgroundColor = isValidInputAmount ? .submit400 : .submit200
    }
    
    func setupData() {
        assetView.isSelectedAssetMode = false
        assetView.update(with: asset)
        
        amountView.delegate = self
        amountView.setDecimals(asset.asset?.precision ?? 0, forceUpdateMoney: false)
        
        if !availableBalance.isZero {
            amountView.input = { [weak self] in
                return self?.input ?? []
            }
            amountView.update(with: [Localizable.Waves.Send.Button.useTotalBalanace])
        }
    }
    
    func setupLocalization() {
        title = Localizable.Waves.Tokenburn.Label.tokenBurn
        amountView.setupRightLabelText(asset.asset?.displayName ?? "")
        amountView.setupTitle(Localizable.Waves.Tokenburn.Label.quantityTokensBurned)
        buttonContinue.setTitle(Localizable.Waves.Send.Button.continue, for: .normal)
        labelTransactionFee.text = Localizable.Waves.Send.Label.transactionFee + " " + "0.001" +  " WAVES"
    }
}
