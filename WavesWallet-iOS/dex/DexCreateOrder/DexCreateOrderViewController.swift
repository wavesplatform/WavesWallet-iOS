//
//  DexSellBuyViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexCreateOrderViewController: UIViewController {

    var input: DexCreateOrder.DTO.Input!
    
    @IBOutlet private weak var typeView: DexCreateOrderSegmentedControl!
    @IBOutlet private weak var inputAmount: DexCreateOrderInputView!
    @IBOutlet private weak var inputPrice: DexCreateOrderInputView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupInputViews()
    }
}

//MARK: - DexCreateOrderTypeViewDelegate
extension DexCreateOrderViewController: DexCreateOrderSegmentedControlDelegate {
    
    func dexCreateOrderDidChangeType(_ type: DexCreateOrder.DTO.OrderType) {
        
    }
}

//MARK: - DexCreateOrderInputViewDelegate
extension DexCreateOrderViewController: DexCreateOrderInputViewDelegate {
    func dexCreateOrder(inputView: DexCreateOrderInputView, didChangeValue value: Double) {
        
        if inputView == inputAmount {
            print("amountDidChange", value)
        }
        else if inputView == inputPrice {
            print("priceDidChange", value)
        }
    }
}

//MARK: - Setup
private extension DexCreateOrderViewController {
    func setupViews() {
        typeView.type = input.type
        typeView.delegate = self
        
        inputAmount.delegate = self
        inputPrice.delegate = self
    }
    
    func setupInputViews() {
        inputAmount.setupTitle(title: Localizable.DexCreateOrder.Label.amountIn, input: input)
        inputPrice.setupTitle(title: Localizable.DexCreateOrder.Label.limitPriceIn, input: input)
    }
}
