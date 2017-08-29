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


class CreateOrderViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var labelPriceAssetName: UILabel!
    
    @IBOutlet weak var labelAmountAssetName: UILabel!
    
    @IBOutlet weak var labelPriceAvailableCount: UILabel!
    @IBOutlet weak var labelAmountAvailableCount: UILabel!
    
    @IBOutlet weak var textFieldPrice: UITextField!
    
    @IBOutlet weak var textFieldAmount: UITextField!
    
    @IBOutlet weak var acitivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var labelTotalPrice: UILabel!
    
    @IBOutlet weak var labelPriceAssetName2: UILabel!
    
    var priceAsset: String!
    var amountAsset: String!
    var priceAssetName: String!
    var amountAssetName: String!
    
    var priceAssetAvailable: Int64 = 0
    var amountAssetAvailable: Int64 = 0
    
    var priceAssetDecimal: Int!
    var amountAssetDecimal: Int!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Place Order"
        
        labelPriceAssetName.text = priceAssetName
        labelAmountAssetName.text = amountAssetName
        labelPriceAssetName2.text = priceAssetName
        
        textFieldPrice.text = "0"
        textFieldAmount.text = "0"
        calculateTotalPrice()
        
        hideAllSubviews()
        NetworkManager.getBalancePair(priceAsset: priceAsset, amountAsset: amountAsset) { (info, errorMessage) in
            
            self.acitivityIndicatorView.stopAnimating()

            if errorMessage != nil {
                self.presentBasicAlertWithTitle(title: errorMessage!)
            }
            else {
                self.showAllSubviews()
                self.priceAssetAvailable = info![self.priceAsset] as! Int64
                self.amountAssetAvailable = info![self.amountAsset] as! Int64
                
                self.labelPriceAvailableCount.text = MoneyUtil.getScaledTextTrimZeros(self.priceAssetAvailable, decimals: self.priceAssetDecimal)
                self.labelAmountAvailableCount.text = MoneyUtil.getScaledTextTrimZeros(self.amountAssetAvailable, decimals: self.amountAssetDecimal)
            }
        }
        
//
        
        if WalletManager.currentWallet?.matcherKeyAccount == nil {
            let key = "CRxqEuxhdZBEHX42MU4FfyJxuHmbDBTaHMhM3Uki7pLw"
            WalletManager.currentWallet?.matcherKeyAccount = PublicKeyAccount(publicKey: Base58.decode(key))
        }

        textFieldPrice.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textFieldAmount.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        textField.text = textField.text?.replacingOccurrences(of: ",", with: ".")
        
        calculateTotalPrice()
    }
    
    func textFieldFormatString(assetAvailable: Int64, decimals: Int) -> String {

        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ""
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = 0
        return f.string(from: Decimal(assetAvailable) / pow(10, Int(decimals)) as NSNumber)!
    }
    
    @IBAction func amountAvailableTapped(_ sender: Any) {

        textFieldAmount.text = textFieldFormatString(assetAvailable: self.amountAssetAvailable, decimals: self.amountAssetDecimal)
        calculateTotalPrice()
    }
    
    @IBAction func priceAvailableTapped(_ sender: Any) {
        textFieldPrice.text = textFieldFormatString(assetAvailable: self.priceAssetAvailable, decimals: self.priceAssetDecimal)
        calculateTotalPrice()
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
        return  AssetPair(json: ["amountAsset" : amountAsset, "priceAsset" : priceAsset])!
    }
    
    @IBAction func sellTapped(_ sender: Any) {
       
        SVProgressHUD.show()
        WalletManager.restorePrivateKey().bind { (privateKey) in
            
            let publicKey = WalletManager.currentWallet!.publicKeyAccount
            let matcherKey =  WalletManager.currentWallet!.matcherKeyAccount!
            
            let price = MoneyUtil.parseUnscaled(self.textFieldPrice.text!, self.priceAssetDecimal)!
            let amount = MoneyUtil.parseUnscaled(self.textFieldAmount.text!, self.amountAssetDecimal)!
            
            let order = Order(senderPublicKey: publicKey, matcherPublicKey: matcherKey, assetPair: self.getAssetPair(), orderType: OrderType.sell, price: price, amount: amount)
            order.senderPrivateKey = privateKey
    
            NetworkManager.buySellOrder(order: order, complete: { (info, errorMessage) in
                SVProgressHUD.dismiss()
                
            })
        }
    }
  
    @IBAction func buyTapped(_ sender: Any) {
        
        WalletManager.restorePrivateKey().bind { (privateKey) in

            let publicKey = WalletManager.currentWallet!.publicKeyAccount
            let matcherKey =  WalletManager.currentWallet!.matcherKeyAccount!
            
            let price = MoneyUtil.parseUnscaled(self.textFieldPrice.text!, self.priceAssetDecimal)!
            let amount = MoneyUtil.parseUnscaled(self.textFieldAmount.text!, self.amountAssetDecimal)!
            
            let order = Order(senderPublicKey: publicKey, matcherPublicKey: matcherKey, assetPair: self.getAssetPair(), orderType: OrderType.buy, price: price, amount: amount)
            order.senderPrivateKey = privateKey
        
            NetworkManager.buySellOrder(order: order, complete: { (info, errorMessage) in
                SVProgressHUD.dismiss()
                
            })
        }
    }
    
    func calculateTotalPrice() {
        
        let price = MoneyUtil.parseUnscaled(textFieldPrice.text!, priceAssetDecimal - amountAssetDecimal)!
        let amount = MoneyUtil.parseUnscaled(self.textFieldAmount.text!, self.amountAssetDecimal)!
        
        let total = price * amount
        labelTotalPrice.text = MoneyUtil.getScaledTextTrimZeros(total, decimals: self.priceAssetDecimal)
    }
    
    @IBAction func plusPriceTapped(_ sender: Any) {
        formatPlus(textField: textFieldPrice)
        calculateTotalPrice()
    }
    
    @IBAction func minusPriceTapped(_ sender: Any) {
        formatMinus(textField: textFieldPrice)
        calculateTotalPrice()
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
    
    func countDecimalsFrom(_ value: Double, textField: UITextField) -> Int {
        
        let string: NSString = textField.text! as NSString
        
        var decimals = 0
        let range = string.range(of: ".")
        
        if range.location != NSNotFound {
            let substring = string.substring(from: range.location + 1)
            decimals = substring.characters.count > 0 ? substring.characters.count : 1
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
        let string: NSString = textField.text! as NSString
        var value = string.doubleValue
        let decimals = countDecimalsFrom(value, textField: textField)
        value += deltaValueFrom(value, textField: textField)
        textField.text = String(format: "%.0\(decimals)f", value)
    }
    
    func formatMinus(textField: UITextField) {
        let string: NSString = textField.text! as NSString
        var value = string.doubleValue
        let decimals = countDecimalsFrom(value, textField: textField)
        value -= deltaValueFrom(value, textField: textField)
        
        if value < 0 {
            value = 0
        }
        
        textField.text = String(format: "%.0\(decimals)f", value)
    }
    
    
    //MARK: UITextField
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string == "," || string == "." {
            
            if ((textField.text! as NSString).range(of: ".") as NSRange).location != NSNotFound {
                return false
            }
            else if textField.text!.characters.count == 0 {
                textField.text = "0"
            }
        }
        else if string.characters.count > 0 {
            if textField.text!.characters.count == 1 && textField.text! == "0" {
                textField.text = "0."
            }            
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
