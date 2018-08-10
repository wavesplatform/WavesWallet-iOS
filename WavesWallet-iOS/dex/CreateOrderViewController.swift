//
//  CreateOrderViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 22.08.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import RxSwift
import AppsFlyerLib

protocol CreateOrderViewControllerDelegate: class {
 
    func createOrderViewControllerDidCreateOrder()
}

class CreateOrderViewController: UITableViewController, UITextFieldDelegate, OrderConfirmViewDelegate {
    
    var delegate: CreateOrderViewControllerDelegate?
    
    let SellColor = UIColor(netHex: 0xFB0D00)
    let BuyColor = UIColor(netHex: 0x00AE00)
    let GreyColor = UIColor(netHex: 0xa5a5a5)
    
    let bag = DisposeBag()
    
    @IBOutlet weak var tickerTitleLabel: UILabel!
    @IBOutlet weak var iconPriceAvailable: UIImageView!
    @IBOutlet weak var iconAmountAvailable: UIImageView!
    
    @IBOutlet weak var labelPriceAssetName: UILabel!
    @IBOutlet weak var labelAmountAssetName: UILabel!
    
    @IBOutlet weak var labelPriceAssetName1: UILabel!
    @IBOutlet weak var labelAmountAssetName1: UILabel!
    
    @IBOutlet weak var letterAmountAvailable: UILabel!
    @IBOutlet weak var letterPriceAvailable: UILabel!
    @IBOutlet weak var labelPriceAvailableCount: UILabel!
    @IBOutlet weak var labelAmountAvailableCount: UILabel!
    
    @IBOutlet weak var textFieldPrice: UITextField!
    
    @IBOutlet weak var textFieldAmount: UITextField!
    
    var acitivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var labelTotalPrice: UILabel!
    
    @IBOutlet weak var labelPriceAssetName2: UILabel!
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    var bottomButtons: UIStackView!
    
    @IBOutlet weak var footerView: UIView!
    var priceAsset: String!
    var amountAsset: String!
    var assetPair: AssetPair!
    var priceAssetName: String!
    var amountAssetName: String!
    
    var priceAssetAvailable: Decimal = 0
    var amountAssetAvailable: Decimal = 0
    
    var priceAssetDecimal: Int!
    var amountAssetDecimal: Int!

    @IBOutlet weak var labelFee: UILabel!
    @IBOutlet weak var placeOrder: UIButton!
    
    var amount: Int64?
    var price: Int64?
    var priceChanged = false
    var orderType: OrderType = .buy
    var buyPrice: String!
    var sellPrice: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assetPair = AssetPair(amountAsset: amountAsset, priceAsset: priceAsset)
        title = DataManager.shared.getTickersTitle(item: ["amountAsset": amountAsset, "amountAssetName": amountAssetName, "priceAsset": priceAsset, "priceAssetName": priceAssetName])
        acitivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        acitivityIndicatorView.center = view.center
        self.view.addSubview(acitivityIndicatorView)
        
        labelPriceAssetName.text = priceAssetName
        labelPriceAssetName1.text = priceAssetName
        labelAmountAssetName.text = amountAssetName
        labelAmountAssetName1.text = amountAssetName
        labelPriceAssetName2.text = priceAssetName
        
        textFieldPrice.text = "0"
        textFieldAmount.text = "0"
        
        if price != nil && amount != nil {
            textFieldAmount.text = textFieldFormatString(assetAvailable: amount!, decimals: self.amountAssetDecimal)
            textFieldPrice.text = textFieldFormatString(assetAvailable: price!, decimals: 8 + self.priceAssetDecimal - self.amountAssetDecimal)
            priceChanged = true
        }
        
        labelFee.text = MoneyUtil.getScaledTextTrimZeros(300000, decimals: 8)
        
        calculateTotalPrice()
        
        hideAllSubviews()
        NetworkManager.getBalancePair(priceAsset: priceAsset, amountAsset: amountAsset) { (info, errorMessage) in
            
            self.acitivityIndicatorView.stopAnimating()

            if errorMessage != nil {
                self.presentBasicAlertWithTitle(title: errorMessage!)
            }
            else {
                
                if WalletManager.currentWallet?.matcherKeyAccount == nil {

                    NetworkManager.getMatcherPublicKey(complete: { (key, errorMessage) in
                        if errorMessage != nil {
                            self.presentBasicAlertWithTitle(title: errorMessage!)
                        }
                        else {
                            WalletManager.currentWallet?.matcherKeyAccount = PublicKeyAccount(publicKey: Base58.decode(key!))
                            self.setupInfo(info)
                        }
                    })
                }
                else {
                    self.setupInfo(info)
                }
            }
        }

        textFieldPrice.addTarget(self, action: #selector(calculateTotalPrice), for: .editingChanged)
        textFieldAmount.addTarget(self, action: #selector(calculateTotalPrice), for: .editingChanged)
        
        setupAssetIcons()
        setupBuySellButtons()
    }
    
    override func viewDidLayoutSubviews() {
        footerView.frame.size.height = max(self.view.frame.height - footerView.frame.origin.y, CGFloat(135.0))
    }
    
    func toggleBuySellButtons() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        buyButton.borderWidth = orderType == .buy ? 0.0 : 1.0
        let buyTxt = NSAttributedString(string: buyButton.attributedTitle(for: .normal)!.string,
                                        attributes: [
                                            NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium),
                                            NSForegroundColorAttributeName: orderType == .buy ? UIColor.white : GreyColor,
                                            NSParagraphStyleAttributeName: paragraph])
        buyButton.setAttributedTitle(buyTxt, for: .normal)
        buyButton.backgroundColor = orderType == .buy ? BuyColor : .white
        
        sellButton.backgroundColor = orderType == .sell ? SellColor : .white
        sellButton.borderWidth = orderType == .sell ? 0.0 : 1.0
        buyButton.borderWidth = orderType == .buy ? 0.0 : 1.0
        let sellTxt = NSAttributedString(string: sellButton.attributedTitle(for: .normal)!.string,
                                        attributes: [
                                            NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium),
                                            NSForegroundColorAttributeName: orderType == .sell ? UIColor.white : GreyColor,
                                            NSParagraphStyleAttributeName: paragraph])
        sellButton.setAttributedTitle(sellTxt, for: .normal)
        
        if !priceChanged {
            textFieldPrice.text = orderType == .buy ? buyPrice : sellPrice
            calculateTotalPrice()
        }
        
        placeOrder.setTitle("Place \(orderType == .buy ? "Buy" : "Sell") Order", for: .normal)
        placeOrder.backgroundColor = orderType == .buy ? BuyColor : SellColor
        
    }
    
    func setupBuySellButtons() {
        
        buyPrice = MoneyUtil.getScaledText(DataManager.shared.bestAsk[assetPair.key] ?? 0, decimals: priceAssetDecimal, scale: 8 + priceAssetDecimal - amountAssetDecimal)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let buyStr = NSAttributedString(string: "BUY",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium),
                NSForegroundColorAttributeName: UIColor.white,
                NSParagraphStyleAttributeName: paragraph])
        buyButton.setAttributedTitle(buyStr, for: .normal)
        buyButton.borderColor = GreyColor
        
        sellPrice = MoneyUtil.getScaledText(DataManager.shared.bestBid[assetPair.key] ?? 0, decimals: priceAssetDecimal, scale: 8 + priceAssetDecimal - amountAssetDecimal)
        let sellStr = NSAttributedString(string: "SELL",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium),
                NSForegroundColorAttributeName: UIColor.white,
                NSParagraphStyleAttributeName: paragraph])
        sellButton.setAttributedTitle(sellStr, for: .normal)
        sellButton.borderColor = GreyColor
        
        toggleBuySellButtons()
    }
    
    func setupAssetIcons() {
        letterPriceAvailable.text = String(priceAssetName.characters.prefix(1)).capitalized
        letterAmountAvailable.text = String(amountAssetName.characters.prefix(1)).capitalized
        
        if priceAsset == "WAVES" {
            letterPriceAvailable.isHidden = true
            iconPriceAvailable.image = #imageLiteral(resourceName: "icon_waves")
        } else if priceAsset == "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS" {
            letterPriceAvailable.isHidden = true
            iconPriceAvailable.image = #imageLiteral(resourceName: "icon-btc")
        } else if priceAsset == "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu" {
            letterPriceAvailable.isHidden = true
            iconPriceAvailable.image = #imageLiteral(resourceName: "icon-eth")
        } else {
            iconPriceAvailable.isHidden = true
        }
        
        if amountAsset == "WAVES" {
            letterAmountAvailable.isHidden = true
            iconAmountAvailable.image = #imageLiteral(resourceName: "icon_waves")
        } else if priceAsset == "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS" {
            letterAmountAvailable.isHidden = true
            iconAmountAvailable.image = #imageLiteral(resourceName: "icon-btc")
        } else if priceAsset == "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu" {
            letterAmountAvailable.isHidden = true
            iconAmountAvailable.image = #imageLiteral(resourceName: "icon_waves")
        } else {
            iconAmountAvailable.isHidden = true
        }

    }
    
    
    func textFieldFormatString(assetAvailable: Int64, decimals: Int) -> String {
        
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ""
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = 0
        return f.string(from: Decimal(assetAvailable) / pow(10, Int(decimals)) as NSNumber)!
    }

    
    func setupInfo(_ info : NSDictionary?) {
        self.showAllSubviews()
        
        self.priceAssetAvailable = MoneyUtil.getScaledDecimal(info![self.priceAsset] as! Int64, self.priceAssetDecimal)
        self.amountAssetAvailable = MoneyUtil.getScaledDecimal(info![self.amountAsset] as! Int64, self.amountAssetDecimal)
        if (self.amountAsset == "WAVES") {
            self.amountAssetAvailable -= 0.003
        }
        
        self.labelPriceAvailableCount.text = MoneyUtil.formatDecimalTrimZeros(self.priceAssetAvailable, decimals: self.priceAssetDecimal)
        self.labelAmountAvailableCount.text = MoneyUtil.formatDecimalTrimZeros(self.amountAssetAvailable, decimals: self.amountAssetDecimal)
    }
    
    func hideAllSubviews() {
        for _view in view.subviews {
            if !_view.isKind(of: UIActivityIndicatorView.classForCoder()) {
                _view.isHidden = true
            }
        }
    }
    
    func showAllSubviews () {
        
        for _view in view.subviews {
            if !_view.isKind(of: UIActivityIndicatorView.classForCoder()) {
                _view.isHidden = false
            }
        }
    }
    
    
    func getAssetPair() -> AssetPair {
        return AssetPair(amountAsset: amountAsset, priceAsset: priceAsset)
    }
    
    func presentSuccessAlert () {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifDidCreateOrder), object: nil)
        
        let alert = UIAlertController(title: "Order Accepted", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
            self.delegate?.createOrderViewControllerDidCreateOrder()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func orderConfirmViewDidConfirm() {
        executeSellBuyAction()
    }
    
    func trackPlaceOrder(order: Order) {
        AppsFlyerTracker.shared().trackEvent("af_place_order", withValues: [
            "af_order_pair" : order.assetPair.key,
            "af_order_type" : order.orderType.rawValue,
            "af_order_price" : order.price,
            "af_order_amount" : order.amount
            ]);
    }
    
    func executeSellBuyAction() {
        WalletManager.getPrivateKey(complete: { (privateKey) in
            SVProgressHUD.show()
            
            let publicKey = WalletManager.currentWallet!.publicKeyAccount
            let matcherKey =  WalletManager.currentWallet!.matcherKeyAccount!
            
            let price = MoneyUtil.parseUnscaled(self.textFieldPrice.text!, 8 + self.priceAssetDecimal - self.amountAssetDecimal)!
            let amount = MoneyUtil.parseUnscaled(self.textFieldAmount.text!, self.amountAssetDecimal)!
            
            let order = Order(senderPublicKey: publicKey, matcherPublicKey: matcherKey, assetPair: self.getAssetPair(), orderType: self.orderType, price: price, amount: amount)
            order.senderPrivateKey = privateKey
            
            NetworkManager.buySellOrder(order: order, complete: { (errorMessage) in
                SVProgressHUD.dismiss()
                
                if errorMessage != nil {
                    self.presentBasicAlertWithTitle(title: errorMessage!)
                }
                else {
                    self.trackPlaceOrder(order: order)
                    self.presentSuccessAlert()
                }
            })
        }) { (errorMessage) in
            self.presentBasicAlertWithTitle(title: errorMessage)
        }
    }
    
    @IBAction func buySellTapped(_ sender: Any) {
       
        if OrderConfirmView.needShow() {
            let view = OrderConfirmView.show()
            view.delegate = self
        }
        else {
            executeSellBuyAction()
        }
   }
    
    func calculateTotalPrice() {
        
        if let price = MoneyUtil.parseDecimal(textFieldPrice.text!),
            let amount = MoneyUtil.parseDecimal(textFieldAmount.text!) {
        
            let total = price * amount
            labelTotalPrice.text = MoneyUtil.formatDecimals(total, decimals: self.priceAssetDecimal)
        }
    }
    
    @IBAction func onPriceChanged(_ sender: UIStepper) {
        if sender.value > 0 {
            formatPlus(textField: textFieldPrice)
            calculateTotalPrice()
        } else {
            formatMinus(textField: textFieldPrice)
            calculateTotalPrice()
        }
        priceChanged = true
        sender.value = 0
    }
    
    @IBAction func plusPriceTapped(_ sender: Any) {
        formatPlus(textField: textFieldPrice)
        calculateTotalPrice()
    }
    
    @IBAction func minusPriceTapped(_ sender: Any) {
        formatMinus(textField: textFieldPrice)
        calculateTotalPrice()
    }
    
    @IBAction func onAmountChnaged(_ sender: UIStepper) {
        if sender.value > 0 {
            formatPlus(textField: textFieldAmount)
            calculateTotalPrice()
        } else {
            formatMinus(textField: textFieldAmount)
            calculateTotalPrice()
        }
        sender.value = 0
    }
    
    @IBAction func plusAmountTapped(_ sender: Any) {
        formatPlus(textField: textFieldAmount)
        calculateTotalPrice()
    }
    
    @IBAction func minusAmountTapped(_ sender: Any) {
        formatMinus(textField: textFieldAmount)
        calculateTotalPrice()
    }
    
    // MARK: CalculateTapped
    
    func decimalSeparator() -> String {
        return NumberFormatter().decimalSeparator
    }
    
    func countDecimalsFrom(_ value: Double, textField: UITextField) -> Int {
        
        let string: NSString = textField.text! as NSString
        
        var decimals = 0
        var range = string.range(of: ".")
        
        if range.location != NSNotFound {
            let substring = string.substring(from: range.location + 1)
            decimals = substring.characters.count > 0 ? substring.characters.count : 1
        }
        else {
            range = string.range(of: ",")
            if range.location != NSNotFound {
                let substring = string.substring(from: range.location + 1)
                decimals = substring.characters.count > 0 ? substring.characters.count : 1
            }
        }
        
        return decimals
    }
    
    func deltaValueFrom(_ value: Double, textField: UITextField) -> Double {
        
        var deltaValue : Double = 1
        let decimals = countDecimalsFrom(value, textField: textField)
        
        for _ in 0..<decimals {
            deltaValue *= 0.1
        }
        
        return deltaValue
    }
    
    func formatPlus(textField: UITextField) {
        var string: NSString = textField.text! as NSString
        string = string.replacingOccurrences(of: ",", with: ".") as NSString
        
        var value = string.doubleValue
        let decimals = countDecimalsFrom(value, textField: textField)
        value += deltaValueFrom(value, textField: textField)
        
        var text = String(format: "%.0\(decimals)f", value)
        text = text.replacingOccurrences(of: ".", with: "\(decimalSeparator())")
        textField.text = text
    }
    
    func formatMinus(textField: UITextField) {
        var string: NSString = textField.text! as NSString
        string = string.replacingOccurrences(of: ",", with: ".") as NSString

        var value = string.doubleValue
        let decimals = countDecimalsFrom(value, textField: textField)
        value -= deltaValueFrom(value, textField: textField)
        
        if value < 0 {
            value = 0
        }
        
        var text = String(format: "%.0\(decimals)f", value)
        text = text.replacingOccurrences(of: ".", with: "\(decimalSeparator())")
        textField.text = text
    }
    
    
    //MARK: UITextField
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string == "," || string == "." {
            
            if ((textField.text! as NSString).range(of: ".") as NSRange).location != NSNotFound ||
                ((textField.text! as NSString).range(of: ",") as NSRange).location != NSNotFound {
                return false
            }
            else if textField.text!.characters.count == 0 {
                textField.text = "0"
            }
        }
        else if string.characters.count > 0 {
            if textField.text!.characters.count == 1 && textField.text! == "0" {
                textField.text = "0\(decimalSeparator())"
            }            
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            textFieldAmount.text = MoneyUtil.formatDecimalNoGroupingAndZeros(self.amountAssetAvailable, decimals: self.amountAssetDecimal)
            calculateTotalPrice()
        } else if indexPath.section == 0 && indexPath.row == 1 {
            if let price = MoneyUtil.parseDecimal(textFieldPrice.text!), price > 0 {
                textFieldAmount.text = MoneyUtil.formatDecimalNoGroupingAndZeros(self.priceAssetAvailable/price, decimals: self.priceAssetDecimal)
                calculateTotalPrice()
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @IBAction func onBuySelected(_ sender: Any) {
        orderType = .buy
        toggleBuySellButtons()
    }
    
    @IBAction func onSellSelected(_ sender: Any) {
        orderType = .sell
        toggleBuySellButtons()
    }
}
