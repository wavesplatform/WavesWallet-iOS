//
//  ReceiveInvoiceViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

final class ReceiveInvoiceViewController: UIViewController {

    @IBOutlet private weak var buttonContinue: HighlightedButton!
    @IBOutlet private weak var viewAsset: AssetSelectView!
    
    private let interator: ReceiveInvoiceInteractorProtocol = ReceiveInvoiceInteractor()

    private var selectedAsset: DomainLayer.DTO.SmartAssetBalance?
    private var amount: Money?
    private var displayInfo: ReceiveInvoice.DTO.DisplayInfo?
    
    var input: AssetList.DTO.Input!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalication()
        viewAsset.delegate = self
        setupButtonState()
        
        if let asset = input.selectedAsset {
            viewAsset.isSelectedAssetMode = false
            setupInfo(asset: asset)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // обновление нужно делать каждый раз,когда возвращаемся на экран, тк на нем завязана активность кнопки "продолжить"
        updateDisplayInfo()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard let info = displayInfo else { return }
        
        let vc = ReceiveGenerateAddressModuleBuilder().build(input: .invoice(info))
        navigationController?.pushViewController(vc, animated: true)
        
        UseCasesFactory.instance.analyticManager.trackEvent(.receive(.receiveTap(assetName: info.assetName)))
    }
    
    private func setupInfo(asset: DomainLayer.DTO.SmartAssetBalance) {
        selectedAsset = asset
        viewAsset.update(with: .init(assetBalance: asset, isOnlyBlockMode: input.selectedAsset != nil))
    }
    
    private func updateDisplayInfo() {
        
        displayInfo = nil
        setupButtonState()
        guard let asset = selectedAsset?.asset else { return }

        interator.displayInfo(asset: asset, amount: Money(value: 0, 0)).subscribe(onNext: { [weak self] displayInfo in
            
            guard let self = self else { return }
            self.displayInfo = displayInfo
            self.setupButtonState()

        }).dispose()
    }
}

// MARK: - AssetSelectView
extension ReceiveInvoiceViewController: AssetSelectViewDelegate {
    
    // TODO: Coordinator
    func assetViewDidTapChangeAsset() {
        let assetInput = AssetList.DTO.Input(filters: input.filters,
                                             selectedAsset: selectedAsset,
                                             showAllList: input.showAllList)
        
        let vc = AssetListModuleBuilder(output: self).build(input: assetInput)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ReceiveInvoiceViewController: AssetListModuleOutput {
    
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.SmartAssetBalance) {
        setupInfo(asset: asset)
    }
}

// MARK: - MoneyTextFieldDelegate
extension ReceiveInvoiceViewController: MoneyTextFieldDelegate {

    func moneyTextField(_ textField: MoneyTextField, didChangeValue value: Money) {
        amount = value
        updateDisplayInfo()
    }
    func moneyTextFieldShouldReturn() -> Bool { true }
}

// MARK: - UI
private extension ReceiveInvoiceViewController {
    func setupButtonState() {
        let canContinueAction = displayInfo != nil
        buttonContinue.isUserInteractionEnabled = canContinueAction
        buttonContinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }
    
    func setupLocalication() {        
        buttonContinue.setTitle(Localizable.Waves.Receive.Button.continue, for: .normal)
    }
}
