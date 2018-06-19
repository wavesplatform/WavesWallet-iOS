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
}
