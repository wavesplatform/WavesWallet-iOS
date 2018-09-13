//
//  DexSellBuyViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let percent50 = 50
    static let percent10 = 10
    static let percent5 = 5
}

final class DexCreateOrderViewController: UIViewController {

    var input: DexCreateOrder.DTO.Input! {
        didSet {
            order = DexCreateOrder.DTO.Order(amountAsset: input.amountAsset,
                                             priceAsset: input.priceAsset,
                                             type: input.type,
                                             amount: 0,
                                             price: 0,
                                             total: 0,
                                             expiration: DexCreateOrder.DTO.Expiration.expiration30d)
        }
    }
    
    @IBOutlet private weak var segmentedControl: DexCreateOrderSegmentedControl!
    @IBOutlet private weak var inputAmount: DexCreateOrderInputView!
    @IBOutlet private weak var inputPrice: DexCreateOrderInputView!
    @IBOutlet private weak var inputTotal: DexCreateOrderInputView!
    @IBOutlet private weak var labelFee: UILabel!
    @IBOutlet private weak var labelExpiration: UILabel!
    @IBOutlet private weak var labelExpirationDays: UILabel!
    @IBOutlet private weak var buttonBuy: HighlightedButton!

    private var isValidOrder: Bool {
        guard order != nil else { return false }
        return order.amount > 0 && order.price > 0 && order.total > 0
    }
    
    private var order: DexCreateOrder.DTO.Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupViews()
        setupLocalization()
        setupButtonBuyState()
    }
}


//MARK: - Actions
private extension DexCreateOrderViewController {
    
    @IBAction func changeExpiration(_ sender: UIButton) {
        
        let values = [DexCreateOrder.DTO.Expiration.expiration5m,
                      DexCreateOrder.DTO.Expiration.expiration30m,
                      DexCreateOrder.DTO.Expiration.expiration1h,
                      DexCreateOrder.DTO.Expiration.expiration1d,
                      DexCreateOrder.DTO.Expiration.expiration1w,
                      DexCreateOrder.DTO.Expiration.expiration30d]
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: Localizable.DexCreateOrder.Button.cancel, style: .cancel, handler: nil)
        controller.addAction(cancel)
        
        for value in values {
            let action = UIAlertAction(title: value.text, style: .default) { (action) in
                
                if self.order.expiration != value {
                    self.order.expiration = value
                    self.setupLabelExpiration()
                }
            }
            controller.addAction(action)
        }
        present(controller, animated: true, completion: nil)
    }
    
    func setupLabelExpiration() {
        labelExpirationDays.text = order.expiration.text
    }
}

//MARK: - DexCreateOrderSegmentedControlDelegate
extension DexCreateOrderViewController: DexCreateOrderSegmentedControlDelegate {
    func dexCreateOrderDidChangeType(_ type: DexCreateOrder.DTO.OrderType) {
        order.type = type
    }
}

//MARK: - DexCreateOrderInputViewDelegate
extension DexCreateOrderViewController: DexCreateOrderInputViewDelegate {

    func dexCreateOrder(inputView: DexCreateOrderInputView, didChangeValue value: Double) {
        if inputView == inputAmount {
            order.amount = value
        }
        else if inputView == inputPrice {
            order.price = value
        }
        else if inputView == inputTotal {
            order.total = value
        }
     
        print(order.price)
        setupButtonBuyState()
    }
}

//MARK: - Setup
private extension DexCreateOrderViewController {
    
    func setupButtonBuyState() {
        buttonBuy.isUserInteractionEnabled = isValidOrder
        buttonBuy.backgroundColor = isValidOrder ? . submit400 : .submit200
    }
    
    func setupData() {
        let totalBalance = 124.23
        
        let value1 = totalBalance * Double(Constants.percent50) / 100
        let value2 = totalBalance * Double(Constants.percent10) / 100
        let value3 = totalBalance * Double(Constants.percent5) / 100
        
        inputAmount.input = [.init(text: Localizable.DexCreateOrder.Button.useTotalBalanace, value: totalBalance),
                             .init(text: String(value1), value: value1),
                             .init(text: String(value2), value: value2),
                             .init(text: String(value3), value: value3)]
        
        inputPrice.input = [.init(text: Localizable.DexCreateOrder.Button.bid, value: value1),
                            .init(text: Localizable.DexCreateOrder.Button.ask, value: value2),
                            .init(text: Localizable.DexCreateOrder.Button.last, value: value3)]
        
        if let price = input.price {
            order.price = price.doubleValue
            inputPrice.setupValue(price.doubleValue)
        }
    }
    
    func setupViews() {
        segmentedControl.type = input.type
        segmentedControl.delegate = self
        
        inputAmount.delegate = self
        inputPrice.delegate = self
        inputTotal.delegate = self
    }
    
    func setupLocalization() {
        setupLabelExpiration()
        buttonBuy.setTitle(Localizable.DexCreateOrder.Button.buy + " " + input.amountAsset.name, for: .normal)
        labelFee.text = Localizable.DexCreateOrder.Label.fee
        labelExpiration.text = Localizable.DexCreateOrder.Label.expiration
        inputAmount.setupTitle(title: Localizable.DexCreateOrder.Label.amountIn + " " + input.amountAsset.name)
        inputPrice.setupTitle(title: Localizable.DexCreateOrder.Label.limitPriceIn + " " + input.priceAsset.name)
        inputTotal.setupTitle(title: Localizable.DexCreateOrder.Label.totalIn + " " + input.priceAsset.name)
    }
}
