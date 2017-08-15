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
    class private func getRequestWithPath(path: String, parameters: Dictionary <String, Any>?, customUrl: String?, complete: @escaping ( _ completeInfo: Any?, _ errorMessage: String?) -> Void)  {
        
        var url = "https://nodes.wavesnodes.com/"
        
        if customUrl != nil {
            url = customUrl!
        }
        
        
        Alamofire.request(url + path, parameters : parameters)
            
            .responseJSON { response in
                
                if response.error != nil {
                    complete(nil, response.error?.localizedDescription)
                }
                else {
                    
                    if let dict = response.result.value as? NSDictionary {
                        if dict["status"] as? String == "error" {
                            complete (nil, dict["message"] as? String)
                        }
                        else {
                            complete (response.result.value, nil)
                        }
                    }
                    else {
                        complete (response.result.value, nil)
                    }
                }
        }
    }
    
    class private func getCandleUrl() -> String {
        return "https://marketdata.wavesplatform.com/api/"
    }
    
    class func getCandles(amountAsset : String, priceAsset : String, timeframe : Int, from : Date, to : Date, complete: @escaping (_ completeInfo: NSArray?, _ errorMessage: String?) -> Void) {
        
        let dateFrom = String.init(format: "%0.f", from.timeIntervalSince1970 * 1000)
        let dateTo =  String.init(format: "%0.f", to.timeIntervalSince1970 * 1000)
        
        getRequestWithPath(path: "candles/\(amountAsset)/\(priceAsset)/\(timeframe)/\(dateFrom)/\(dateTo)", parameters: nil, customUrl: getCandleUrl()) { (info : Any?, errorMessage: String?) in
        
            complete(info as? NSArray, errorMessage)
        }
    }
    
    class func getCandleLimitLine(amountAsset : String, priceAsset : String, complete: @escaping (_ price: Double, _ errorMessage: String?) -> Void) {
        
        getRequestWithPath(path: "trades/\(amountAsset)/\(priceAsset)/1", parameters: nil, customUrl: getCandleUrl()) { (info, errorMessage) in
            
            if let item = (info as? NSArray)?.firstObject as? NSDictionary {
                
                if item["price"] is String {
                    complete(Double(item["price"] as! String)!, errorMessage)
                }
                else {
                    complete(item["price"] as! Double, errorMessage)
                }
            }
            else {
                complete(0, errorMessage)
            }
        }
    }
    
    class func getLastTranders(amountAsset: String, priceAsset: String , complete: @escaping (_ items: NSArray?, _ errorMessage: String?) -> Void) {
        
        getRequestWithPath(path: "trades/\(amountAsset)/\(priceAsset)/100", parameters: nil, customUrl: getCandleUrl()) { (info, errorMessage) in
            
            complete(info as? NSArray, errorMessage)
        }
    }
    
    class func getOrderBook(amountAsset: String, priceAsset: String , complete: @escaping (_ items: NSArray?, _ errorMessage: String?) -> Void) {
    
        getRequestWithPath(path: "matcher/orderbook/\(amountAsset)/\(priceAsset)", parameters: nil, customUrl: nil) { (info, errorMessage) in
            print(info, errorMessage)
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
}
