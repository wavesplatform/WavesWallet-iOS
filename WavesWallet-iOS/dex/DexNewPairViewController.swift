//
//  DexNewPairViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 17.08.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import SVProgressHUD


class DexNewPairViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var textFieldPrice: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add New Market"
        
        buttonAdd.isEnabled = false
    }

    @IBAction func textFieldDidChange(_ sender: Any) {
    
        buttonAdd.isEnabled = textFieldAmount.text!.characters.count > 0 && textFieldPrice.text!.characters.count > 0
    }
    
    @IBAction func addTapped(_ sender: Any) {
    
        SVProgressHUD.show()
        
        NetworkManager.getOrderBook(amountAsset: textFieldAmount.text!, priceAsset: textFieldPrice.text!) { (info, errorMessage) in
            
            if errorMessage != nil {
                SVProgressHUD.dismiss()
                self.presentBasicAlertWithTitle(title: errorMessage!)
            }
            else {
                
                if let amountAsset = (info?["pair"] as? NSDictionary)?["amountAsset"] as? String,
                   let priceAsset = (info?["pair"] as? NSDictionary)?["priceAsset"] as? String {
                    
                    NetworkManager.getTransactionInfo(asset: amountAsset, complete: { (info, errorMessage) in
                    
                        if errorMessage != nil {
                            SVProgressHUD.dismiss()
                            self.presentBasicAlertWithTitle(title: errorMessage!)
                        }
                        else {
                            
                            let amountInfo  = ["amountAsset" : info?["assetId"],
                                              "amountAssetName" : info?["name"],
                                              "amountAssetInfo" : ["decimals" : info?["decimals"]]]
                            
                            
                            NetworkManager.getTransactionInfo(asset: priceAsset, complete: { (info, errorMessage) in

                                SVProgressHUD.dismiss()
                                if errorMessage != nil {
                                    self.presentBasicAlertWithTitle(title: errorMessage!)
                                }
                                else {
                                    
                                    let priceInfo = ["priceAsset" : info?["assetId"],
                                                      "priceAssetName" : info?["name"],
                                                      "priceAssetInfo" : ["decimals" : info?["decimals"]]]
                                    
                                    let dict = NSMutableDictionary(dictionary: amountInfo)
                                    dict.addEntries(from: priceInfo)
                                    
                                    if !DataManager.hasPair(dict) {
                                        DataManager.addPair(dict)
                                    }
                                    
                                    NotificationCenter.default.post(name: Notification.Name(rawValue:kNotifDidChangeDexItems), object: nil)
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                            })
                        }
                    })
                }
                else {
                    SVProgressHUD.dismiss()
                    self.presentBasicAlertWithTitle(title: "Error")
                }
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
}
