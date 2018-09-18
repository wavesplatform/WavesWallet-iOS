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
    
    static let minusTopOffsetForIPhone5: CGFloat = 13
}

final class DexCreateOrderViewController: UIViewController {

    var input: DexCreateOrder.DTO.Input! {
        didSet {
            
            order = DexCreateOrder.DTO.Order(amountAsset: input.amountAsset, priceAsset: input.priceAsset,
                                             type: input.type,
                                             amount: Money(0, input.amountAsset.decimals),
                                             price: input.price ?? Money(0, input.priceAsset.decimals),
                                             total: Money(0, input.priceAsset.decimals),
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
    @IBOutlet private weak var buttonSellBuy: HighlightedButton!

    @IBOutlet private weak var segmentedTopOffset: NSLayoutConstraint!
    @IBOutlet private weak var inputAmountTopOffset: NSLayoutConstraint!
    @IBOutlet private weak var inputPriceTopOffset: NSLayoutConstraint!
    @IBOutlet private weak var inputTotalTopOffset: NSLayoutConstraint!
    @IBOutlet private weak var viewFeeTopOffset: NSLayoutConstraint!
    @IBOutlet private weak var buttonSellBuyBottomOffset: NSLayoutConstraint!
    
    private var isValidOrder: Bool {
        return !order.amount.isZero && !order.price.isZero && !order.total.isZero
    }
    
    private var order: DexCreateOrder.DTO.Order!
    
    //FIXME: - Update
    private var totalAmountBalance = Money(313240, 8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupViews()
        setupLocalization()
        setupButtonSellBuy()
        setupUIForIPhone5IfNeed()
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
        setupButtonSellBuy()
    }
}

//MARK: - DexCreateOrderInputViewDelegate
extension DexCreateOrderViewController: DexCreateOrderInputViewDelegate {

    func dexCreateOrder(inputView: DexCreateOrderInputView, didChangeValue value: Money) {

        if inputView == inputAmount {
            order.amount = value
            inputView.showErrorMessage(show: value.decimalValue > totalAmountBalance.decimalValue)
            
            if order.price.amount > 0 && order.amount.amount > 0 {

                let total = order.price.decimalValue * order.amount.decimalValue
                order.total = Money(value: total, order.total.decimals)
                inputTotal.setupValue(order.total)
            }
        }
        else if inputView == inputPrice {
            order.price = value
            
            if order.price.amount > 0 && order.amount.amount > 0 {
                
                let total = order.price.decimalValue * order.amount.decimalValue
                order.total = Money(value: total, order.total.decimals)
                inputTotal.setupValue(order.total)
            }
        }
        else if inputView == inputTotal {
            order.total = value
            
            if order.total.amount > 0 && order.price.amount > 0 {
                let amount = order.total.decimalValue * order.price.decimalValue
                order.amount = Money(value: amount, order.amount.decimals)
                inputAmount.setupValue(order.amount)
                inputAmount.showErrorMessage(show: order.amount.decimalValue > totalAmountBalance.decimalValue)
            }
        }
     
        setupButtonSellBuy()
    }
}

//MARK: - Setup
private extension DexCreateOrderViewController {
    
    func setupButtonSellBuy() {
        buttonSellBuy.isUserInteractionEnabled = isValidOrder

        if order.type == .sell {            
            buttonSellBuy.setTitle(Localizable.DexCreateOrder.Button.sell + " " + input.amountAsset.name, for: .normal)
            buttonSellBuy.backgroundColor = isValidOrder ? .error400 : .error100
            buttonSellBuy.highlightedBackground = .error200
        }
        else {
            buttonSellBuy.setTitle(Localizable.DexCreateOrder.Button.buy + " " + input.amountAsset.name, for: .normal)
            buttonSellBuy.backgroundColor = isValidOrder ? .submit400 : .submit200
            buttonSellBuy.highlightedBackground = .submit300
        }
    }
    
    func setupData() {
        
        if !totalAmountBalance.isZero {

            let value1 = Money(value: totalAmountBalance.decimalValue * Decimal(Constants.percent50) / 100, totalAmountBalance.decimals)
            
            let value2 = Money(value: totalAmountBalance.decimalValue * Decimal(Constants.percent10) / 100, totalAmountBalance.decimals)
            
            let value3 = Money(value: totalAmountBalance.decimalValue * Decimal(Constants.percent5) / 100, totalAmountBalance.decimals)

            inputAmount.input = [.init(text: Localizable.DexCreateOrder.Button.useTotalBalanace, value: totalAmountBalance),
                                 .init(text: value1.displayText, value: value1),
                                 .init(text: value2.displayText, value: value2),
                                 .init(text: value3.displayText, value: value3)]
        }

        var inputPriceValues: [DexCreateOrderInputView.Input] = []

        if let bid = input.bid {
            inputPriceValues.append(.init(text: Localizable.DexCreateOrder.Button.bid, value: bid))
        }

        if let ask = input.ask {
            inputPriceValues.append(.init(text: Localizable.DexCreateOrder.Button.ask, value: ask))
        }

        if let last = input.last {
            inputPriceValues.append(.init(text: Localizable.DexCreateOrder.Button.last, value: last))
        }
        
        inputPrice.input = inputPriceValues

        if let price = input.price {
            order.price = price
            inputPrice.setupValue(price)
        }
    }
    
    func setupViews() {
        segmentedControl.type = input.type
        segmentedControl.delegate = self
        
        inputAmount.delegate = self
        inputAmount.maximumFractionDigits = input.amountAsset.decimals
        
        inputPrice.delegate = self
        inputPrice.maximumFractionDigits = input.priceAsset.decimals
        
        inputTotal.delegate = self
        inputTotal.maximumFractionDigits = input.priceAsset.decimals
    }
    
    func setupLocalization() {
        setupLabelExpiration()
        
        labelFee.text = Localizable.DexCreateOrder.Label.fee
        labelExpiration.text = Localizable.DexCreateOrder.Label.expiration
        
        inputAmount.setupTitle(title: Localizable.DexCreateOrder.Label.amountIn + " " + input.amountAsset.name,
                               errorTitle: Localizable.DexCreateOrder.Label.notEnough + " " + input.amountAsset.name)
        
        inputPrice.setupTitle(title: Localizable.DexCreateOrder.Label.limitPriceIn + " " + input.priceAsset.name,
                              errorTitle: nil)
        inputTotal.setupTitle(title: Localizable.DexCreateOrder.Label.totalIn + " " + input.priceAsset.name,
                              errorTitle: nil)
    }
}

//MARK: - Setup UI for iPhone5
private extension DexCreateOrderViewController {
    
    func setupUIForIPhone5IfNeed() {

        if Platform.isIphone5 {
            segmentedTopOffset.constant = 0
            inputAmountTopOffset.constant -= Constants.minusTopOffsetForIPhone5
            inputPriceTopOffset.constant -= Constants.minusTopOffsetForIPhone5
            inputTotalTopOffset.constant -= Constants.minusTopOffsetForIPhone5
            viewFeeTopOffset.constant -= Constants.minusTopOffsetForIPhone5
            buttonSellBuyBottomOffset.constant -= Constants.minusTopOffsetForIPhone5
        }
    }
}
