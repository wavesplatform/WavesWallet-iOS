//
//  ReceiveInvoiceViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ReceiveInvoiceViewController: UIViewController {

    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var viewAmountContainer: UIView!
    @IBOutlet private weak var labelTotalDollar: UILabel!
    @IBOutlet private weak var textFieldMoney: MoneyTextField!
    @IBOutlet private weak var buttonContinue: HighlightedButton!
    @IBOutlet private weak var viewAsset: AssetSelectView!
    
    private var selectedAsset: DomainLayer.DTO.AssetBalance?
    private var generateInfo: ReceiveInvoive.DTO.GenerateInfo?
    private var amount: Money?

    override func viewDidLoad() {
        super.viewDidLoad()

        viewAmountContainer.addTableCellShadowStyle()
        setupLocalication()
        textFieldMoney.moneyDelegate = self
        viewAsset.delegate = self
        setupButtonState()
        calculateTotalDollar()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard let info = generateInfo else { return }
        
        let vc = ReceiveGenerateAddressModuleBuilder().build(input: .invoice(info))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateGenerateInfo() {
        
        guard let balanceAsset = selectedAsset else { return }
        guard let precision = balanceAsset.asset?.precision else { return }
        
        generateInfo = ReceiveInvoive.DTO.GenerateInfo.init(balanceAsset: balanceAsset,
                                                            amount: amount ?? Money(0, precision))
    }
}

//MARK: - AssetSelectView
extension ReceiveInvoiceViewController: AssetSelectViewDelegate {
    
    func assetViewDidTapChangeAsset() {
        let vc = AssetListModuleBuilder(output: self).build(input: .init(filters:[.all], selectedAsset: nil))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ReceiveInvoiceViewController: AssetListModuleOutput {
    
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.AssetBalance) {
        selectedAsset = asset
        updateGenerateInfo()
        setupButtonState()
        viewAsset.update(with: asset)
        textFieldMoney.decimals = asset.asset?.precision ?? 0
    }
}

//MARK: - MoneyTextFieldDelegate
extension ReceiveInvoiceViewController: MoneyTextFieldDelegate {

    func moneyTextField(_ textField: MoneyTextField, didChangeValue value: Money) {
        amount = value
        updateGenerateInfo()
        calculateTotalDollar()
    }
}

//MARK: - UI
private extension ReceiveInvoiceViewController {
    
    
    func setupButtonState() {
        let canContinueAction = generateInfo != nil
        buttonContinue.isUserInteractionEnabled = canContinueAction
        buttonContinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    
    func calculateTotalDollar() {
        labelTotalDollar.text = "≈ " + "0" + " " + Localizable.ReceiveInvoice.Label.dollar
    }
    
    func setupLocalication() {
        labelAmount.text = Localizable.Receive.Label.amount
        buttonContinue.setTitle(Localizable.Receive.Button.continue, for: .normal)
    }
}
