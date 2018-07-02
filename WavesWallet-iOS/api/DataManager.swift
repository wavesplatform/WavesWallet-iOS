//
//  DataManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 20.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class DataManager: NSObject {

    var orderBooks = [NSDictionary]()
    var verifiedAssets: NSDictionary! = nil
    
    var bestBid = [String: Int64]()
    var bestAsk = [String: Int64]()
    
    static let shared = DataManager()
    
    func getTickersTitle(item: NSDictionary) -> String {
        let amountLabel = item["amountTicker"] ?? verifiedAssets[item["amountAsset"]!] ?? item["amountAssetName"]!
        let priceLabel = item["priceTicker"] ?? verifiedAssets[item["priceAsset"]!] ?? item["priceAssetName"]!

        return "\(amountLabel) / \(priceLabel)"
    }
    
    func isVerified(asset: String) -> Bool {
        return verifiedAssets != nil && verifiedAssets[asset] != nil
    }
    
    func getTicker(_ asset: Any?) -> String? {
        if verifiedAssets != nil, let key = asset, let tck = verifiedAssets[safe: key] {
            return tck as? String
        } else {
            return nil
        }
    }
    
    class func withLoadedVerifiedAssets(_ complete: @escaping (_ assets: NSDictionary?, _ errorMessage: String?) -> Void) {
        if DataManager.shared.verifiedAssets == nil {
            NetworkManager.getVerifiedAssets {(assets, errorMessage) in
                if let assets = assets {
                    shared.verifiedAssets = assets
                }
                complete(assets, errorMessage)
            }
        } else {
            complete(shared.verifiedAssets, nil)
        }
    }
    
    class func getCandleTimeFrame() -> Int {
        
        let timeFrame = UserDefaults.standard.integer(forKey: "candleTimeFrame")
        
        if timeFrame > 0 {
            return timeFrame
        }
        
        return 15
    }
    
    class func setCandleTimeFrame(_ timeFrame : Int) {
        UserDefaults.standard.set(timeFrame, forKey: "candleTimeFrame")
        UserDefaults.standard.synchronize()
    }
    
    class func isShowBarChart() -> Bool {
        return UserDefaults.standard.bool(forKey: "isShowBarChart")
    }
    
    class func setShowBarChart(isShow: Bool) {
        UserDefaults.standard.set(isShow, forKey: "isShowBarChart")
        UserDefaults.standard.synchronize()
    }
 
    class func getWavesWbtcPair() -> NSDictionary {
        
        let priceAsset = Environments.current.isTestNet ? "Fmg13HEHJHuZYbtJq8Da8wifJENq8uBxDuWoP9pVe2Qe" : "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS"
        
        return  ["amountAsset" : "WAVES",
                "amountAssetName" : "WAVES",
                "amountTicker" : "WAVES",
                "amountAssetInfo" : ["decimals" : 8],
                "priceAsset" : priceAsset,
                "priceAssetInfo" : ["decimals" : 8],
                "priceAssetName" : "Bitcoin",
                "priceTicker" : "BTC"]
    }
    
    class func addPair(_ item: NSDictionary) {
        
        if isWavesWbtcPair(item) {
            return
        }
        
        let array = NSMutableArray()
        array.addObjects(from: getDexPairs() as! [Any])
        
        let newItem = NSMutableDictionary(dictionary: item)
        newItem["isTest"] = Environments.current.isTestNet ? true : false
        array.add(newItem)
        
        UserDefaults.standard.set(array, forKey: "dexPairs")
        UserDefaults.standard.synchronize()
    }
    
    
    class func removePair(_ item: NSDictionary) {
        
        if isWavesWbtcPair(item) {
            return
        }
        
        let array = NSMutableArray()
        array.addObjects(from: getDexPairs() as! [Any])
        
        for _item in array as! [NSDictionary] {
        
            if _item["amountAsset"] as? String == item["amountAsset"] as? String &&
                _item["priceAsset"] as? String == item["priceAsset"] as? String{
                array.remove(_item)
                break
            }
        }
        
        UserDefaults.standard.set(array, forKey: "dexPairs")
        UserDefaults.standard.synchronize()
    }
    
    
    class func isWavesWbtcPair(_ item: NSDictionary) -> Bool {
     
        if item["amountAsset"] as? String == getWavesWbtcPair()["amountAsset"] as? String &&
            item["priceAsset"] as? String == getWavesWbtcPair()["priceAsset"] as? String{
            return true
        }
        
        return false
    }
    
    class func hasPair(_ item: NSDictionary) -> Bool {

        if isWavesWbtcPair(item) {
            return true
        }
        
        for _item in getDexPairs() as! [NSDictionary] {
            
            if _item["amountAsset"] as? String == item["amountAsset"] as? String &&
                _item["priceAsset"] as? String == item["priceAsset"] as? String{
                return true
            }
        }
        
        return false
    }
    
    class func getDexPairs() -> NSArray {
        
        let pairs = UserDefaults.standard.object(forKey: "dexPairs")
    
        if pairs == nil {
            return []
        }
        
        let array = NSMutableArray()
        
        for item in pairs as! [NSDictionary] {
            
            if Environments.current.isTestNet {
                if item["isTest"] as? Bool == true {
                    array.add(item)
                }
            }
            else {
                if item["isTest"] as? Bool == false {
                    array.add(item)
                }
            }
        }
        
        return array
    }
    
    class func isShowUnverifiedAssets() -> Bool {
        return UserDefaults.standard.bool(forKey: "isShowUnverifiedAssets")
    }
    
    class func setShowUnverifiedAssets(_ show: Bool) {
        UserDefaults.standard.set(show, forKey: "isShowUnverifiedAssets")
        UserDefaults.standard.synchronize()
    }
    
    class func bgColorForCryptoCurrency(_ currency: String) -> UIColor {
        
        let name = String(currency.lowercased().first!)
        if name == "a" {    return UIColor(56, 161, 45) }
        else if name == "b" {   return UIColor(105, 114, 123)    }
        else if name == "c" {   return UIColor(228, 149, 22)    }
        else if name == "d" {   return UIColor(0, 140, 167)    }
        else if name == "e" {   return UIColor(255, 91, 56)    }
        else if name == "f" {   return UIColor(255, 106, 0)    }
        else if name == "g" {   return UIColor(199, 65, 36)    }
        else if name == "h" {   return UIColor(0, 167, 142)    }
        else if name == "i" {   return UIColor(176, 30, 83)    }
        else if name == "j" {   return UIColor(224, 198, 27)    }
        else if name == "k" {   return UIColor(90, 129, 234)    }
        else if name == "l" {   return UIColor(114, 183, 210)    }
        else if name == "m" {   return UIColor(165, 181, 195)    }
        else if name == "n" {   return UIColor(129, 201, 38)    }
        else if name == "o" {   return UIColor(134, 163, 189)    }
        else if name == "p" {   return UIColor(193, 216, 47)    }
        else if name == "q" {   return UIColor(92, 132, 168)    }
        else if name == "r" {   return UIColor(38, 126, 27)    }
        else if name == "s" {   return UIColor(252, 176, 52)    }
        else if name == "t" {   return UIColor(255, 132, 106)    }
        else if name == "u" {   return UIColor(71, 193, 255)    }
        else if name == "v" {   return UIColor(0, 160, 175)    }
        else if name == "w" {   return UIColor(133, 215, 198)    }
        else if name == "x" {   return UIColor(138, 121, 103)    }
        else if name == "y" {   return UIColor(38, 193, 201)    }
        else if name == "z" {   return UIColor(114, 210, 139)    }

        return UIColor(150, 188, 160)
    }
    
    class func logoForCryptoCurrency(_ currency: String) -> String {
        if currency.lowercased() == "waves" {
            return "logoWaves48"
        }
        else if currency.lowercased() == "usd" {
            return "logoUsd48"
        }
        else if currency.lowercased() == "monero" {
            return "logoMonero48"
        }
        else if currency.lowercased() == "litecoin" {
            return "logoLtc48"
        }
        else if currency.lowercased() == "lira" {
            return "logoLira48"
        }
        else if currency.lowercased() == "eur" {
            return "logoEuro48"
        }
        else if currency.lowercased() == "eth" {
            return "logoEthereum48"
        }
        else if currency.lowercased() == "dash" {
            return "logoDash48"
        }
        else if currency.lowercased() == "bitcoin cash" {
            return "logoBitcoincash48"
        }
        else if currency.lowercased() == "bitcoin" {
            return "logoBitcoin48"
        }
        
        return ""
    }
    
    //UI
    
    
    class func attributedBalanceText(text: String, font: UIFont) -> NSAttributedString {
        
        let range = (text as NSString).range(of: ".")
        let attrString = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: font.pointSize, weight: UIFontWeightSemibold)])
        
        if range.location != NSNotFound {
            let length = text.count - range.location
            attrString.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: font.pointSize, weight: UIFontWeightRegular)], range: NSRange(location: range.location, length: length))
        }
        return attrString
    }
    
    
    class func setupTextFieldLabel(textField: UITextField, placeHolderLabel: UILabel) {
        let isShow = textField.text!.count > 0
        
        if isShow {
            if placeHolderLabel.alpha == 0 {
                UIView.animate(withDuration: 0.3) {
                    placeHolderLabel.alpha = 1
                }
            }
        }
        else {
            if placeHolderLabel.alpha > 0 {
                UIView.animate(withDuration: 0.3) {
                    placeHolderLabel.alpha = 0
                }
            }
        }
    }
    
    class func getLanguages() -> [Dictionary<String, String>] {
        
        return [["title" : "English", "icon" : "flag18Britain", "id" : ""],
                ["title" : "Русский", "icon" : "flag18Rus", "id" : ""],
                ["title" : "中文(简体)", "icon" : "flag18China", "id" : ""],
                ["title" : "한국어", "icon" : "flag18Korea", "id" : ""],
                ["title" : "Türkçe", "icon" : "flag18Turkey", "id" : ""],
                ["title" : "हिन्दी", "icon" : "flag18Hindi", "id" : ""],
                ["title" : "Dansk", "icon" : "flag18Danish", "id" : ""],
                ["title" : "Nederlands", "icon" : "flag18Nederland", "id" : ""]]
    }
}
