//
//  NetworkManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 17.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import Alamofire


class NetworkManager: NSObject
{
    fileprivate class func parsedObjectFromResponse(_ responseObject: Any?) -> Any? {
        
        if responseObject is NSDictionary {
            
            let item = responseObject as! NSDictionary
            let newDict = NSMutableDictionary()
            
            let keys = item.allKeys;
            
            for key in keys {
                
                let info = item[key]
                
                if info is NSArray || info is NSDictionary {
                    newDict[key] = parsedObjectFromResponse(info)
                }
                else if !(info is NSNull)
                {
                    if info is String
                    {
                        if info as! String == "null"
                        {
                            continue
                        }
                    }
                    
                    newDict[key] = info
                }
            }
            
            return newDict
        }
        else if responseObject is NSArray
        {
            let array = NSMutableArray()
            
            for info in responseObject as! NSArray {
                array.add(parsedObjectFromResponse(info)!)
            }
            
            return array;
        }
        else if responseObject is NSNull {
            return nil
        }
        
        return responseObject;
    }

    
    @discardableResult fileprivate class func getRequestWithPath(path: String, parameters: Dictionary <String, Any>?, customUrl: String?, complete: @escaping ( _ completeInfo: Any?, _ errorMessage: String?) -> Void) -> DataRequest {
        
        var url = "https://nodes.wavesnodes.com/"
        
        if customUrl != nil {
            url = customUrl!
        }
        
        
        return Alamofire.request(url + path, parameters : parameters)
            
                .responseJSON { response in
                    
                    if response.error != nil {
                        
                        let error = response.error as NSError?

                        if error?.code != NSURLErrorCancelled {
                            complete(nil, response.error?.localizedDescription)
                        }
                    }
                    else if response.response?.statusCode != 200 {
                        complete(nil, (response.result.value as? NSDictionary)?["message"] as? String)
                    }
                    else {
                        
                        if let dict = response.result.value as? NSDictionary {
                            if dict["status"] as? String == "error" {
                                complete (nil, dict["message"] as? String)
                            }
                            else {
                                complete (parsedObjectFromResponse(response.result.value), nil)
                            }
                        }
                        else {
                            complete (parsedObjectFromResponse(response.result.value), nil)
                        }
                    }
        }
    }
    
    fileprivate class func getMarketUrl() -> String {
        return "https://marketdata.wavesplatform.com/api/"
    }
    
    class func getCandles(amountAsset : String, priceAsset : String, timeframe : Int, from : Date, to : Date, complete: @escaping (_ completeInfo: NSArray?, _ errorMessage: String?) -> Void) {
        
        let dateFrom = String.init(format: "%0.f", from.timeIntervalSince1970 * 1000)
        let dateTo =  String.init(format: "%0.f", to.timeIntervalSince1970 * 1000)
        
        getRequestWithPath(path: "candles/\(amountAsset)/\(priceAsset)/\(timeframe)/\(dateFrom)/\(dateTo)", parameters: nil, customUrl: getMarketUrl()) { (info : Any?, errorMessage: String?) in

            complete(info as? NSArray, errorMessage)
        }
    }
    
    
    @discardableResult class func getLastTraderPairPrice(amountAsset : String, priceAsset : String, complete: @escaping (_ price: Double, _ timestamp: Int64, _ errorMessage: String?) -> Void) -> DataRequest {
        
        return getRequestWithPath(path: "trades/\(amountAsset)/\(priceAsset)/1", parameters: nil, customUrl: getMarketUrl()) { (info, errorMessage) in
            
                if let item = (info as? NSArray)?.firstObject as? NSDictionary {
                                        
                    if item["price"] is String {
                        var value = Double(item["price"] as! String)!
                        
//                        if value > 0 && value <= 0.00000009 {
//                            value = 0
//                        }
                        complete(value, item["timestamp"] as! Int64, errorMessage)
                    }
                    else {
                        complete(item["price"] as! Double, item["timestamp"] as! Int64, errorMessage)
                    }
                }
                else {
                    complete(0, 0, errorMessage)
                }
        }
    }
    
    class func getLastTraders(amountAsset: String, priceAsset: String , complete: @escaping (_ items: NSArray?, _ errorMessage: String?) -> Void) {
        
        getRequestWithPath(path: "trades/\(amountAsset)/\(priceAsset)/100", parameters: nil, customUrl: getMarketUrl()) { (info, errorMessage) in
            
            complete(info as? NSArray, errorMessage)
        }
    }
    
    class func getOrderBook(amountAsset: String, priceAsset: String , complete: @escaping (_ info: NSDictionary?, _ errorMessage: String?) -> Void) {
    
        getRequestWithPath(path: "matcher/orderbook/\(amountAsset)/\(priceAsset)", parameters: nil, customUrl: nil) { (info, errorMessage) in
            complete(info as? NSDictionary, errorMessage)
        }
    }
    
    class func getAllOrderBooks (_ complete: @escaping (_ items: NSArray?, _ errorMessage: String?) -> Void) {
    
        getRequestWithPath(path: "matcher/orderbook", parameters: nil, customUrl: nil) { (info, errorMessage) in            
            complete((info as? NSDictionary)?["markets"] as? NSArray, errorMessage)
        }
    }
    
    class func getVerifiedAssets(_ complete: @escaping (_ assets: NSDictionary?, _ errorMessage: String?) -> Void) {
        getRequestWithPath(path: "verified-assets.json", parameters: nil, customUrl: "https://waves-wallet.firebaseio.com/") { (info, errorMessage) in
            complete(info as? NSDictionary, errorMessage)
        }
    }
    
    @discardableResult class func getTickerInfo(amountAsset: String, priceAsset: String , complete: @escaping (_ info: NSDictionary?, _ errorMessage: String?) -> Void) -> DataRequest {

        return getRequestWithPath(path: "ticker/\(amountAsset)/\(priceAsset)", parameters: nil, customUrl: getMarketUrl()) { (info, errorMessage) in
                complete(info as? NSDictionary, errorMessage)
            }
    }
    
    class func getTransactionInfo(asset: String, complete: @escaping (_ info: NSDictionary?, _ errorMessage: String?) -> Void) {
                
        getRequestWithPath(path: "transactions/info/\(asset)", parameters: nil, customUrl: nil) { (info, errorMessage) in
            complete(info as? NSDictionary, errorMessage)
        }
    }
}
