//
//  CreateOrderViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 22.08.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class CreateOrderViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var labelPriceAssetName: UILabel!
    
    @IBOutlet weak var labelAmountAssetName: UILabel!
    
    @IBOutlet weak var labelPriceAvailableCount: UILabel!
    @IBOutlet weak var labelAmountAvailableCount: UILabel!
    
    @IBOutlet weak var textFieldPrice: UITextField!
    
    @IBOutlet weak var textFieldAmount: UITextField!
    
    @IBOutlet weak var acitivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var labelTotalPrice: UILabel!
    
    
    var priceAsset: String!
    var amountAsset: String!
    var priceAssetName: String!
    var amountAssetName: String!
    
    var priceAssetAvailable: Double = 0
    var amountAssetAvailable: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Place Order"
        
        labelPriceAssetName.text = priceAssetName
        labelAmountAssetName.text = amountAssetName

        hideAllSubviews()
        NetworkManager.getBalancePair(priceAsset: priceAsset, amountAsset: amountAsset) { (info, errorMessage) in
            
            self.acitivityIndicatorView.stopAnimating()

            if errorMessage != nil {
                self.presentBasicAlertWithTitle(title: errorMessage!)
            }
            else {
                self.showAllSubviews()
                
                self.priceAssetAvailable = info![self.priceAsset] as! Double
                self.amountAssetAvailable = info![self.amountAsset] as! Double
                
                self.labelPriceAvailableCount.text = "\(self.priceAssetAvailable)"
                self.labelAmountAvailableCount.text = "\(self.amountAssetAvailable)"
            }
        }
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
    
    @IBAction func sellTapped(_ sender: Any) {
    
    }
    
    @IBAction func buyTapped(_ sender: Any) {
    
    }
    
    @IBAction func plusPriceTapped(_ sender: Any) {
        formatPlus(textField: textFieldPrice)
    }
    
    @IBAction func minusPriceTapped(_ sender: Any) {
        formatMinus(textField: textFieldPrice)
    }
    
    @IBAction func plusAmountTapped(_ sender: Any) {
        formatPlus(textField: textFieldAmount)
    }
    
    @IBAction func minusAmountTapped(_ sender: Any) {
        formatMinus(textField: textFieldAmount)
    }
    
    // MARK: CalculateTapped
    
    func countDecimalsFrom(_ value: Double, textField: UITextField) -> Int {
        
        let string: NSString = textField.text! as NSString
        
        var decimals = 0
        let range = string.range(of: ",")
        
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
        var string: NSString = textField.text! as NSString
        string = string.replacingOccurrences(of: ",", with: ".") as NSString
        var value = string.doubleValue
        let decimals = countDecimalsFrom(value, textField: textField)
        value += deltaValueFrom(value, textField: textField)
        textField.text = String(format: "%.0\(decimals)f", value).replacingOccurrences(of: ".", with: ",")
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
        
        textField.text = String(format: "%.0\(decimals)f", value).replacingOccurrences(of: ".", with: ",")
    }
    
    
    //MARK: UITextField
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string == "," {

            if ((textField.text! as NSString).range(of: ",") as NSRange).location != NSNotFound {
                return false
            }
            else if textField.text!.characters.count == 0 {
                textField.text = "0"
            }
        }
        else if string.characters.count > 0 {
            if textField.text!.characters.count == 1 && textField.text! == "0" {
                textField.text = "0,"
            }            
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
