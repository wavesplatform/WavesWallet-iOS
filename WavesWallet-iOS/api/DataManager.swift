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
    
    static let shared = DataManager()
    
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
        
        return  ["amountAsset" : "WAVES",
                "amountAssetName" : "WAVES",
                "amountAssetInfo" : ["decimals" : 8],
                "priceAsset" : "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
                "priceAssetInfo" : ["decimals" : 8],
                "priceAssetName" : "WBTC"]
    }
    
    class func addPair(_ item: NSDictionary) {
        
        if isWavesWbtcPair(item) {
            return
        }
        
        let array = NSMutableArray()
        array.addObjects(from: getDexPairs() as! [Any])
        array.add(item)
        
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
        
        return pairs as! NSArray
    }
    
    class func isShowUnverifiedAssets() -> Bool {
        return UserDefaults.standard.bool(forKey: "isShowUnverifiedAssets")
    }
    
    class func setShowUnverifiedAssets(_ show: Bool) {
        UserDefaults.standard.set(show, forKey: "isShowUnverifiedAssets")
        UserDefaults.standard.synchronize()
    }
}
