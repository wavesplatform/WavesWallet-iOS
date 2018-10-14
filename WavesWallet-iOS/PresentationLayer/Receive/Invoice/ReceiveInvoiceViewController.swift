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
    
    private let interator: ReceiveInvoiceInteractorProtocol = ReceiveInvoiceInteractor()

    private var selectedAsset: DomainLayer.DTO.AssetBalance?
    private var amount: Decimal = 0
    private var displayInfo: ReceiveInvoice.DTO.DisplayInfo?
    
    var input: AssetList.DTO.Input!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewAmountContainer.addTableCellShadowStyle()
        setupLocalication()
        textFieldMoney.moneyDelegate = self
        viewAsset.delegate = self
        setupButtonState()
        calculateTotalDollar()
        
        if let asset = input.selectedAsset {
            viewAsset.isSelectedAssetMode = false
            setupInfo(asset: asset)
        }
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard let info = displayInfo else { return }
        
        let vc = ReceiveGenerateAddressModuleBuilder().build(input: .invoice(info))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupInfo(asset: DomainLayer.DTO.AssetBalance) {
        selectedAsset = asset

        updateDisplayInfo()
        viewAsset.update(with: asset)
        textFieldMoney.decimals = asset.asset?.precision ?? 0
    }
    
    private func updateDisplayInfo() {
        
        displayInfo = nil
        setupButtonState()
        guard let asset = selectedAsset?.asset else { return }
        
        let money = Money(value: amount, asset.precision)
        
        interator.displayInfo(asset: asset, amount: money).subscribe(onNext: { [weak self] displayInfo in
            
            guard let strongSelf = self else { return }
            strongSelf.displayInfo = displayInfo
            strongSelf.setupButtonState()

        }).dispose()
    }
}

//MARK: - AssetSelectView
extension ReceiveInvoiceViewController: AssetSelectViewDelegate {
    
    func assetViewDidTapChangeAsset() {
        let assetInput = AssetList.DTO.Input(filters: input.filters, selectedAsset: selectedAsset)
        let vc = AssetListModuleBuilder(output: self).build(input: assetInput)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ReceiveInvoiceViewController: AssetListModuleOutput {
    
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.AssetBalance) {
        setupInfo(asset: asset)
    }
}

//MARK: - MoneyTextFieldDelegate
extension ReceiveInvoiceViewController: MoneyTextFieldDelegate {

    func moneyTextField(_ textField: MoneyTextField, didChangeValue value: Money) {
        amount = textField.decimalValue
        updateDisplayInfo()
        calculateTotalDollar()
    }
}

//MARK: - UI
private extension ReceiveInvoiceViewController {
    
    
    func setupButtonState() {
        let canContinueAction = displayInfo != nil
        buttonContinue.isUserInteractionEnabled = canContinueAction
        buttonContinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    
    func calculateTotalDollar() {
        //TODO: - Need to calculate amount in dollars
        labelTotalDollar.text = "≈ " + "0" + " " + Localizable.ReceiveInvoice.Label.dollar
    }
    
    func setupLocalication() {
        labelAmount.text = Localizable.Receive.Label.amount
        buttonContinue.setTitle(Localizable.Receive.Button.continue, for: .normal)
    }
}
