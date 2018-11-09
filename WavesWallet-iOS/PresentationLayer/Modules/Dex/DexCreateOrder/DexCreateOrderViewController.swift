//
//  DexSellBuyViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback


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
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var order: DexCreateOrder.DTO.Order!
    private var isCreatingOrderState: Bool = false
    
    var presenter: DexCreateOrderPresenterProtocol!
    private let sendEvent: PublishRelay<DexCreateOrder.Event> = PublishRelay<DexCreateOrder.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFeedBack()
        setupData()
        setupViews()
        setupLocalization()
        setupButtonSellBuy()
        setupUIForIPhone5IfNeed()
    }
}

//MARK: - UI State
private extension DexCreateOrderViewController {
 
    func setupCreatingOrderState() {
        isCreatingOrderState = true
        setupButtonSellBuy()
        
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func setupDefaultState() {
        isCreatingOrderState = false
        setupButtonSellBuy()
        activityIndicatorView.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

//MARK: - FeedBack
private extension DexCreateOrderViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<DexCreateOrder.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        presenter.system(feedbacks: [feedback])
    }
    
    func events() -> [Signal<DexCreateOrder.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<DexCreateOrder.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let strongSelf = self else { return }
                switch state.action {
                case .none:
                    return
                default:
                    break
                }
                
                switch state.action {
                case .showCreatingOrderState:
                    strongSelf.setupCreatingOrderState()
                    
                case .orderDidFailCreate(let error):
                    strongSelf.setupDefaultState()
                    
                case .orderDidCreate:
                    strongSelf.dismissController()
                    
                default:
                    break
                }
            })
        
        return [subscriptionSections]
    }
}

//MARK: - Validation
private extension DexCreateOrderViewController {
    
    var isValidOrder: Bool {
        return !order.amount.isZero &&
            !order.price.isZero &&
            !order.total.isZero &&
            isValidAmountAssetBalance &&
            isValidPriceAssetBalance &&
            !isCreatingOrderState
    }
    
    var isValidAmountAssetBalance: Bool {
        if order.type == .sell {
            return order.amount.decimalValue <= input.availableAmountAssetBalance.decimalValue
        }
        return true
    }
    
    
    var isValidPriceAssetBalance: Bool {
        if order.type == .buy {
            return order.total.decimalValue <= input.availablePriceAssetBalance.decimalValue
        }
        return true
    }
}

//MARK: - Actions
private extension DexCreateOrderViewController {
    
    func dismissController() {
        if let parent = self.parent as? PopupViewController {
            parent.dismissPopup()
        }
    }
   
    @IBAction func buttonSellBuyTapped(_ sender: UIButton) {
        sendEvent.accept(.createOrder)
    }
    
    @IBAction func changeExpiration(_ sender: UIButton) {
        
        let values = [DexCreateOrder.DTO.Expiration.expiration5m,
                      DexCreateOrder.DTO.Expiration.expiration30m,
                      DexCreateOrder.DTO.Expiration.expiration1h,
                      DexCreateOrder.DTO.Expiration.expiration1d,
                      DexCreateOrder.DTO.Expiration.expiration1w,
                      DexCreateOrder.DTO.Expiration.expiration30d]
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: Localizable.Waves.Dexcreateorder.Button.cancel, style: .cancel, handler: nil)
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
    
    func dexCreateOrderDidChangeType(_ type: Dex.DTO.OrderType) {
        order.type = type
        setupButtonSellBuy()
        setupValidationErrors()
        setupInputAmountData()
        sendEvent.accept(.updateInputOrder(order))
    }
}

//MARK: - DexCreateOrderInputViewDelegate
extension DexCreateOrderViewController: DexCreateOrderInputViewDelegate {

    func dexCreateOrder(inputView: DexCreateOrderInputView, didChangeValue value: Money) {

        if inputView == inputAmount {
            order.amount = value
            
            if !order.price.isZero && !order.amount.isZero {

                let total = order.price.decimalValue * order.amount.decimalValue
                order.total = Money(value: total, order.total.decimals)
                inputTotal.setupValue(order.total)
            }
        }
        else if inputView == inputPrice {
            order.price = value
            
            if !order.price.isZero && !order.amount.isZero {
                
                let total = order.price.decimalValue * order.amount.decimalValue
                order.total = Money(value: total, order.total.decimals)
                inputTotal.setupValue(order.total)
            }
        }
        else if inputView == inputTotal {
            order.total = value
        
            if !order.total.isZero && !order.price.isZero {
                
                let amount = order.total.decimalValue / order.price.decimalValue
                order.amount = Money(value: amount, order.amount.decimals)
                inputAmount.setupValue(order.amount)
            }
        }
     
        setupButtonSellBuy()
        setupValidationErrors()
        sendEvent.accept(.updateInputOrder(order))
    }
}

//MARK: - Setup
private extension DexCreateOrderViewController {
    
    func setupValidationErrors() {
        if order.type == .sell {
            
            inputAmount.showErrorMessage(message: Localizable.Waves.Dexcreateorder.Label.notEnough + " " + input.amountAsset.shortName,
                                         isShow: !isValidAmountAssetBalance)
            
            inputTotal.showErrorMessage(message: Localizable.Waves.Dexcreateorder.Label.bigValue,
                                        isShow: order.total.isBigAmount)
        }
        else {
            
            inputAmount.showErrorMessage(message: Localizable.Waves.Dexcreateorder.Label.bigValue,
                                         isShow: order.amount.isBigAmount)
            
            var totalError = ""
            if order.total.isBigAmount {
                totalError = Localizable.Waves.Dexcreateorder.Label.bigValue
            }
            else if !isValidPriceAssetBalance {
                totalError = Localizable.Waves.Dexcreateorder.Label.notEnough + " " + input.priceAsset.shortName
            }
            
            inputTotal.showErrorMessage(message: totalError,
                                        isShow: !isValidPriceAssetBalance || order.total.isBigAmount)
        }
    }
    
    func setupButtonSellBuy() {
        buttonSellBuy.isUserInteractionEnabled = isValidOrder

        if order.type == .sell {            
            buttonSellBuy.setTitle(Localizable.Waves.Dexcreateorder.Button.sell + " " + input.amountAsset.shortName, for: .normal)
            buttonSellBuy.backgroundColor = isValidOrder ? .error400 : .error100
            buttonSellBuy.highlightedBackground = .error200
        }
        else {
            buttonSellBuy.setTitle(Localizable.Waves.Dexcreateorder.Button.buy + " " + input.amountAsset.shortName, for: .normal)
            buttonSellBuy.backgroundColor = isValidOrder ? .submit400 : .submit200
            buttonSellBuy.highlightedBackground = .submit300
        }
    }
    
    func setupInputAmountData() {
        
        var fields: [String] = []
        
        if order.type == .sell {
            
            guard !input.availableAmountAssetBalance.isZero else {
                inputAmount.update(with: [])
                return
            }
            
            fields.append(Localizable.Waves.Dexcreateorder.Button.useTotalBalanace)
            fields.append(String(Constants.percent50) + "%")
            fields.append(String(Constants.percent10) + "%")
            fields.append(String(Constants.percent5) + "%")
        }
        else {
            
            if order.price.isZero {
                guard !input.availableAmountAssetBalance.isZero else {
                    inputAmount.update(with: [])
                    return
                }
            }
            else {
                guard !input.availablePriceAssetBalance.isZero else {
                    inputAmount.update(with: [])
                    return
                }
            }

            fields.append(Localizable.Waves.Dexcreateorder.Button.useTotalBalanace)
            fields.append(String(Constants.percent50) + "%")
            fields.append(String(Constants.percent10) + "%")
            fields.append(String(Constants.percent5) + "%")
        }
        
        inputAmount.update(with: fields)
    }
    
    func setupData() {
        
        setupInputAmountData()

        inputAmount.input = { [weak self] in
            return self?.amountValues ?? []
        }
        
        inputPrice.input = { [weak self] in
            self?.priceValues ?? []
        }
        
        var fields: [String] = []
        if input.bid != nil {
            fields.append(Localizable.Waves.Dexcreateorder.Button.bid)
        }
        if input.ask != nil {
            fields.append(Localizable.Waves.Dexcreateorder.Button.ask)
        }
        if input.last != nil {
            fields.append(Localizable.Waves.Dexcreateorder.Button.last)
        }
        inputPrice.update(with: fields)
        inputPrice.isShowInputWhenFilled = true
        
        if let price = input.price {
            order.price = price
            inputPrice.setupValue(price)
        }
    }
    
    var amountValues: [Money] {
        var values: [Money] = []
        
        var totalAmount: Int64 = 0
        var decimals: Int = 0

        if order.type == .sell {
            
            guard !input.availableAmountAssetBalance.isZero else { return values }
            
            totalAmount = input.availableAmountAssetBalance.amount
            decimals = input.availableAmountAssetBalance.decimals
        }
        else {
            
            
            if order.price.isZero {
                guard !input.availableAmountAssetBalance.isZero else { return values }
                totalAmount = input.availableAmountAssetBalance.amount
                decimals = input.availableAmountAssetBalance.decimals
            }
            else {
                guard !input.availablePriceAssetBalance.isZero else { return values }
                
                totalAmount = (input.availablePriceAssetBalance.decimalValue / order.price.decimalValue * pow(10, order.price.decimals)).rounded().int64Value
                decimals = input.availablePriceAssetBalance.decimals
            }
        }
        
        let totalAmountMoney = Money(totalAmount, decimals)
        
        let valuePercent50 = Money(totalAmount * Int64(Constants.percent50) / 100, decimals)
        
        let valuePercent10 = Money(totalAmount * Int64(Constants.percent10) / 100, decimals)
        
        let valuePercent5 = Money(totalAmount * Int64(Constants.percent5) / 100, decimals)
        
        values.append(totalAmountMoney)
        values.append(valuePercent50)
        values.append(valuePercent10)
        values.append(valuePercent5)
        
        return values
    }
    
    var priceValues: [Money] {
        
        var values: [Money] = []
        
        if let bid = input.bid {
            values.append(bid)
        }
        
        if let ask = input.ask {
            values.append(ask)
        }
        
        if let last = input.last {
            values.append(last)
        }

        return values
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
        
        labelFee.text = Localizable.Waves.Dexcreateorder.Label.fee
        labelExpiration.text = Localizable.Waves.Dexcreateorder.Label.expiration
        
        inputAmount.setupTitle(title: Localizable.Waves.Dexcreateorder.Label.amountIn + " " + input.amountAsset.shortName)
        inputPrice.setupTitle(title: Localizable.Waves.Dexcreateorder.Label.limitPriceIn + " " + input.priceAsset.shortName)
        inputTotal.setupTitle(title: Localizable.Waves.Dexcreateorder.Label.totalIn + " " + input.priceAsset.shortName)
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
