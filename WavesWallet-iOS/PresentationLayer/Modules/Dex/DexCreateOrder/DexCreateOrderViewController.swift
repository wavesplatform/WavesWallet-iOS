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
                                             amount: input.amount ?? Money(0, input.amountAsset.decimals),
                                             price: input.price ?? Money(0, input.priceAsset.decimals),
                                             total: Money(0, input.priceAsset.decimals),
                                             expiration: DexCreateOrder.DTO.Expiration.expiration29d,
                                             fee: 0)
        }
    }
    
    @IBOutlet private weak var segmentedControl: DexCreateOrderSegmentedControl!
    @IBOutlet private weak var inputAmount: DexCreateOrderInputView!
    @IBOutlet private weak var inputPrice: DexCreateOrderInputView!
    @IBOutlet private weak var inputTotal: DexCreateOrderInputView!
    @IBOutlet private weak var labelFeeLocalization: UILabel!
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
    @IBOutlet private weak var viewErrorFee: UIView!
    @IBOutlet private weak var labelErrorFee: UILabel!
    @IBOutlet private weak var labelFee: UILabel!
    @IBOutlet private weak var activityIndicatorViewFee: UIActivityIndicatorView!
    
    private var order: DexCreateOrder.DTO.Order!
    private var isCreatingOrderState: Bool = false
    private var isDisabledBuySellButton: Bool = false
    private var errorSnackKey: String?
    
    var presenter: DexCreateOrderPresenterProtocol!
    private let sendEvent: PublishRelay<DexCreateOrder.Event> = PublishRelay<DexCreateOrder.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewErrorFee.isHidden = true
        setupFeedBack()
        setupData()
        setupLocalization()
        setupButtonSellBuy()
        setupUIForIPhone5IfNeed()
        labelFee.isHidden = true
    }
}

//MARK: - UI State
private extension DexCreateOrderViewController {
 
    func showFee(fee: Money) {
        activityIndicatorViewFee.stopAnimating()
        labelFee.isHidden = false
        labelFee.text = fee.displayText + " " + "WAVES"
    }
    
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
            return Bindings(subscriptions: owner.subscriptions(state: state), mutations: owner.events())
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

                strongSelf.isDisabledBuySellButton = state.isDisabledSellBuyButton

                strongSelf.setupFeeError(error: state.displayFeeErrorState)

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
                    
                    strongSelf.showNetworkErrorSnack(error: error)
                    strongSelf.setupDefaultState()
                    
                case .orderDidCreate:
                    strongSelf.dismissController()
                    
                case .didGetFee(let fee):
                    strongSelf.showFee(fee: fee)
                    strongSelf.order.fee = fee.amount
                    strongSelf.setupButtonSellBuy()
                    strongSelf.setupValidationErrors()
                    strongSelf.sendEvent.accept(.updateInputOrder(strongSelf.order))

                default:
                    break
                }
            })
        
        return [subscriptionSections]
    }
}

//MARK: - Validation
private extension DexCreateOrderViewController {
    
    var isValidWavesFee: Bool {
        if input.availableWavesBalance.amount >= order.fee {
            return true
        }
        
        if order.amountAsset.id == GlobalConstants.wavesAssetId && order.type == .buy {
            
            if order.amount.isZero {
                return isValidPriceAssetBalance
            }
            return order.amount.amount > order.fee
        }
        else if order.priceAsset.id == GlobalConstants.wavesAssetId && order.type == .sell {
            if order.total.isZero {
                return isValidAmountAssetBalance
            }
            return order.total.amount > order.fee
        }
        return false
    }
    
    var isValidOrder: Bool {
        return !order.amount.isZero &&
            !order.price.isZero &&
            !order.total.isZero &&
            isValidAmountAssetBalance &&
            isValidPriceAssetBalance &&
            !isCreatingOrderState &&
            isValidWavesFee &&
            order.fee > 0 && isDisabledBuySellButton == false
    }
    
    var availableAmountAssetBalance: Money {
        if order.amountAsset.id == GlobalConstants.wavesAssetId {
            let amount = input.availableAmountAssetBalance.amount - Int64(order.fee)
            return Money(amount < 0 ? 0 : amount, input.availableAmountAssetBalance.decimals)
        }
        return input.availableAmountAssetBalance
    }
    
    var availablePriceAssetBalance: Money {
        if order.priceAsset.id == GlobalConstants.wavesAssetId {
            let amount = input.availablePriceAssetBalance.amount - Int64(order.fee)
            return Money(amount < 0 ? 0 : amount, input.availablePriceAssetBalance.decimals)
        }
        return input.availablePriceAssetBalance
    }
    
    var isValidAmountAssetBalance: Bool {
        if order.type == .sell {
            return order.amount.decimalValue <= availableAmountAssetBalance.decimalValue
        }
        return true
    }
    
    
    var isValidPriceAssetBalance: Bool {
        if order.type == .buy {
            return order.total.decimalValue <= availablePriceAssetBalance.decimalValue
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
                      DexCreateOrder.DTO.Expiration.expiration29d]
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: Localizable.Waves.Dexcreateorder.Button.cancel, style: .cancel, handler: nil)
        controller.addAction(cancel)
        
        for value in values {
            let action = UIAlertAction(title: value.text, style: .default) { (action) in
                
                if self.order.expiration != value {
                    self.order.expiration = value
                    self.setupLabelExpiration()
                    self.sendEvent.accept(.updateInputOrder(self.order))
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
    
    func dexCreateOrderDidChangeType(_ type: DomainLayer.DTO.Dex.OrderType) {
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

    func setupFeeError(error: DisplayErrorState) {

        switch error {
        case .error(let error):

            switch error {
            case .globalError(let isInternetNotWorking):

                if isInternetNotWorking {
                    errorSnackKey = showWithoutInternetSnack { [weak self] in
                        self?.sendEvent.accept(.refreshFee)
                    }
                } else {
                    errorSnackKey = showErrorNotFoundSnack(didTap: { [weak self] in
                        self?.sendEvent.accept(.refreshFee)
                    })
                }
            case .internetNotWorking:
                errorSnackKey = showWithoutInternetSnack { [weak self] in
                    self?.sendEvent.accept(.refreshFee)
                }

            case .message(let text):
                errorSnackKey = showErrorSnack(title: text, didTap: { [weak self] in
                    self?.sendEvent.accept(.refreshFee)
                })

            case .notFound, .scriptError:
                errorSnackKey = showErrorNotFoundSnack(didTap: { [weak self] in
                    self?.sendEvent.accept(.refreshFee)
                })
            }

        case .none:
            if let errorSnackKey = errorSnackKey {
                hideSnack(key: errorSnackKey)
            }

        case .waiting:
            break
        }
        
    }

    func setupValidationErrors() {
        if order.type == .sell {
            
            inputAmount.showErrorMessage(message: Localizable.Waves.Dexcreateorder.Label.notEnough + " " + input.amountAsset.shortName,
                                         isShow: !isValidAmountAssetBalance)
            
           
            var message = ""
            if order.total.isBigAmount {
                message = Localizable.Waves.Dexcreateorder.Label.bigValue
            }
            else if order.total.isSmallAmount {
                message = Localizable.Waves.Dexcreateorder.Label.smallValue
            }
            
            inputTotal.showErrorMessage(message: message,
                                        isShow: order.total.isBigAmount || order.total.isSmallAmount)
        }
        else {
            
            var amountError = ""
            if order.total.isBigAmount {
                amountError = Localizable.Waves.Dexcreateorder.Label.bigValue
            }
            else if order.total.isSmallAmount {
                amountError = Localizable.Waves.Dexcreateorder.Label.smallValue
            }
            
            inputAmount.showErrorMessage(message: amountError,
                                         isShow: order.amount.isBigAmount || order.amount.isSmallAmount)
            
            var totalError = ""
            if order.total.isBigAmount {
                totalError = Localizable.Waves.Dexcreateorder.Label.bigValue
            }
            else if order.total.isSmallAmount {
                totalError = Localizable.Waves.Dexcreateorder.Label.smallValue
            }
            else if !isValidPriceAssetBalance {
                totalError = Localizable.Waves.Dexcreateorder.Label.notEnough + " " + input.priceAsset.shortName
            }
            
            inputTotal.showErrorMessage(message: totalError,
                                        isShow: !isValidPriceAssetBalance || order.total.isBigAmount || order.total.isSmallAmount)
        }
        
        viewErrorFee.isHidden = isValidWavesFee
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
            
            guard !availableAmountAssetBalance.isZero else {
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
                guard !availableAmountAssetBalance.isZero else {
                    inputAmount.update(with: [])
                    return
                }
            }
            else {
                guard !availablePriceAssetBalance.isZero else {
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
        
        segmentedControl.type = input.type
        segmentedControl.delegate = self
        
        inputAmount.delegate = self
        inputAmount.maximumFractionDigits = input.amountAsset.decimals
        
        inputPrice.delegate = self
        inputPrice.maximumFractionDigits = input.priceAsset.decimals
        
        inputTotal.delegate = self
        inputTotal.maximumFractionDigits = input.priceAsset.decimals
        
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
            
            if let amount = input.amount {
                inputAmount.updateAmount(amount)
            }
            setupValidationErrors()
        }
    }
    
    var amountValues: [Money] {
        var values: [Money] = []
        
        var totalAmount: Int64 = 0
        var decimals: Int = 0

        if order.type == .sell {
            
            guard !availableAmountAssetBalance.isZero else { return values }
            
            totalAmount = availableAmountAssetBalance.amount
            decimals = availableAmountAssetBalance.decimals
        }
        else {
            if order.price.isZero {
                guard !availableAmountAssetBalance.isZero else { return values }
                totalAmount = availableAmountAssetBalance.amount
                decimals = availableAmountAssetBalance.decimals
            }
            else {
                
                guard !availablePriceAssetBalance.isZero else { return values }

                totalAmount = ((availablePriceAssetBalance.decimalValue / order.price.decimalValue) * pow(10, availableAmountAssetBalance.decimals)).rounded().int64Value
                decimals = availableAmountAssetBalance.decimals
            }
        }
        
        let totalAmountMoney = Money(totalAmount, decimals)

        let n5 = Decimal(totalAmountMoney.amount) * (Decimal(Constants.percent5) / 100.0)
        let n10 = Decimal(totalAmountMoney.amount) * (Decimal(Constants.percent10) / 100.0)
        let n50 = Decimal(totalAmountMoney.amount) * (Decimal(Constants.percent50) / 100.0)

        let valuePercent50 = Money(n50.int64Value, decimals)
        let valuePercent10 = Money(n10.int64Value, decimals)
        let valuePercent5 = Money(n5.int64Value, decimals)
        
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
    
    func setupLocalization() {
        setupLabelExpiration()
        
        labelFeeLocalization.text = Localizable.Waves.Dexcreateorder.Label.fee
        labelExpiration.text = Localizable.Waves.Dexcreateorder.Label.expiration
        
        inputAmount.setupTitle(title: Localizable.Waves.Dexcreateorder.Label.amountIn + " " + input.amountAsset.shortName)
        inputPrice.setupTitle(title: Localizable.Waves.Dexcreateorder.Label.limitPriceIn + " " + input.priceAsset.shortName)
        inputTotal.setupTitle(title: Localizable.Waves.Dexcreateorder.Label.totalIn + " " + input.priceAsset.shortName)
        labelErrorFee.text = Localizable.Waves.Dexcreateorder.Label.Error.notFundsFee
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
